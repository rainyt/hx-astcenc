import haxe.Exception;
import utils.HashCache;
import haxe.Json;
import astc.ASTCEncode;
import sys.FileSystem;
import astc.ASTCJsonConfig;
import openfl.utils.ByteArray;
import sys.io.File;
import haxe.io.Path;

using StringTools;

class Tools {
	public static var astcencPath:String = null;

	public static var cpu:String = "";

	static function main() {
		var args = Sys.args();
		var path = args.pop();
		var current = Sys.getCwd();
		var isWindow = Sys.systemName() == "Windows";
		if (isWindow) {
			cpu = testCPU(current);
		}
		astcencPath = Path.join([current, "./tools/astcenc" + (isWindow ? "-" + cpu + ".exe" : "")]);
		// 是否使用json配置
		if (args[0].indexOf(".json") != -1) {
			Sys.setCwd(path);
			runJson(Json.parse(File.getContent(args[0])));
			return;
		}
		// 是否压缩
		var isBinaryCompression = args[0] == "c";
		if (isBinaryCompression) {
			args.shift();
		}
		Sys.setCwd(path);
		Sys.command(astcencPath, args);
		var bytes = File.getBytes(args[2]);
		if (isBinaryCompression) {
			var byteArray:ByteArray = ByteArray.fromBytes(bytes);
			byteArray.compress();
			File.saveBytes(args[2], byteArray);
			trace("Out file size:" + Math.floor(byteArray.length / 1024) + "kb");
		} else {
			trace("Out file size:" + Math.floor(bytes.length / 1024) + "kb");
		}
	}

	/**
	 * Windows系统需要先检测CPU的兼容性
	 * @param current 
	 * @return String
	 */
	private static function testCPU(current:String):String {
		var code = Sys.command(Path.join([current, "./tools/astcenc-avx2.exe"]));
		if (code == 0)
			return "avx2";
		var code = Sys.command(Path.join([current, "./tools/astcenc-sse4.1.exe"]));
		if (code == 0)
			return "sse4.1";
		return "sse2";
	}

	/**
	 * 通过JSON配置进行转换处理
	 * @param json 
	 */
	public static function runJson(list:Array<ASTCJsonConfig>):Void {
		try {
			for (json in list) {
				converToAstc(json.path, json.output, json);
			}
			HashCache.getInstance().save();
			trace("convered");
		} catch (e:Exception) {
			trace(e.message, e.stack);
		}
	}

	/**
	 * 转换路径为ASTC纹理
	 * @param path 来源路径
	 * @param topath 储存路径
	 * @param json 配置
	 */
	public static function converToAstc(path:String, topath:String, json:ASTCJsonConfig):Void {
		if (FileSystem.isDirectory(path)) {
			var list = FileSystem.readDirectory(path);
			for (file in list) {
				var filePath = Path.join([path, file]);
				var outFilePath = Path.join([topath, file]);
				converToAstc(filePath, outFilePath, json);
			}
			// 删除不存在的png文件，则删除astc文件
			if (FileSystem.exists(topath)) {
				var astclist = FileSystem.readDirectory(topath);
				for (file in astclist) {
					if (!list.contains(StringTools.replace(file, ".astc", ".png"))) {
						// 删除
						var filePath = Path.join([topath, file]);
						if (!FileSystem.isDirectory(filePath)) {
							trace("[D]", filePath);
							if (!FileSystem.isDirectory(filePath)) {
								FileSystem.deleteFile(filePath);
							}
						}
					}
				}
			}
		} else if (path.endsWith(".png")) {
			topath = topath.replace(".png", ".astc");
			if (HashCache.getInstance().isChange(path) || !FileSystem.exists(topath)) {
				// 开始转换为astc格式
				trace("[A]", path, topath);
				var dir = Path.directory(topath);
				if (!FileSystem.exists(dir)) {
					FileSystem.createDirectory(dir);
				}
				try {
					var astcEncode = new ASTCEncode(json.mode, path);
					astcEncode.alphaPremultiply = json.alphaPremultiply;
					astcEncode.zlib = json.zlib;
					astcEncode.encode(topath, json.defaultBlock, json.quality);
					HashCache.getInstance().update(path);
				} catch (e:Exception) {
					if (!json.igroneError) {
						HashCache.getInstance().save();
						throw e;
					}
				}
			} else {
				// trace("Skip", path);
			}
		}
	}
}
