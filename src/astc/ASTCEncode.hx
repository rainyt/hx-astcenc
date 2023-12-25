package astc;

import openfl.utils.ByteArray;
import sys.io.File;
import haxe.io.Bytes;

/**
 * ASTC编码处理
 */
class ASTCEncode {
	/**
	 * 颜色模式
	 */
	public var colorMode:ColorMode;

	/**
	 * 需要编码的文件
	 */
	public var path:String;

	/**
	 * 是否使用zlib压缩
	 */
	public var zlib:Bool = false;

	/**
	 * 二进制数据
	 */
	public var bytes:Bytes;

	/**
	 * 透明预乘处理
	 */
	public var alphaPremultiply:Bool = false;

	/**
	 * ASTC编码
	 * @param colorMode 
	 * @param path 
	 */
	public function new(colorMode:ColorMode, path:String) {
		this.colorMode = colorMode;
		this.path = path;
	}

	/**
	 * 开始编码处理
	 * @param blockdim 
	 * @return Bytes
	 */
	public function encode(saveTo:String, blockdim:BlockDim, quality:Quality):Void {
		var args = [this.colorMode, path, saveTo, blockdim, quality];
		if (alphaPremultiply) {
			args.push("-pp-premultiply");
		}
		trace("run ", args.join(" "));
		Sys.command(Tools.astcencPath, args);
		try {
			if (zlib) {
				bytes = File.getBytes(saveTo);
				var byteArray:ByteArray = ByteArray.fromBytes(bytes);
				byteArray.compress();
				File.saveBytes(saveTo, byteArray);
			}
		} catch (e) {
			trace(e);
		}
	}
}
