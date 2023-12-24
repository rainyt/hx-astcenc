import openfl.utils.ByteArray;
import sys.io.File;
import haxe.io.Path;

class Tools {
	static function main() {
		var args = Sys.args();
		var path = args.pop();
		var current = Sys.getCwd();
		// 是否压缩
		var isBinaryCompression = args[0] == "c";
		if (isBinaryCompression) {
			args.shift();
		}
		Sys.setCwd(path);
		Sys.command(Path.join([current, "./tools/astcenc"]), args);
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
}
