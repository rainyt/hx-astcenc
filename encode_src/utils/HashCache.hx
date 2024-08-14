package utils;

import sys.io.Process;
import haxe.crypto.Md5;
import haxe.Json;
import sys.FileSystem;
import sys.io.File;
import haxe.io.Path;

/**
 * 缓存信息
 */
class HashCache {
	private static var __hashCache:HashCache;

	public static function getInstance():HashCache {
		if (__hashCache != null)
			return __hashCache;
		var hash = Path.join([Sys.getCwd(), "astc.hash"]);
		__hashCache = new HashCache(hash);
		return __hashCache;
	}

	public var map:Dynamic<String> = {};

	private var __error:Array<String> = [];

	public var path:String;

	private function new(path:String) {
		this.path = path;
		if (FileSystem.exists(path)) {
			var data:Dynamic = Json.parse(File.getContent(path));
			if (data.cache == null)
				map = data;
			else
				map = data.cache;
		}
	}

	public function isChange(file:String, topath:String):Bool {
		var data = Reflect.getProperty(map, file);
		if (data != null) {
			var stat = FileSystem.stat(file);
			var date = stat.mtime.toString();
			if (date != data) {
				// 如果不相等，那么可能是文件被修改了，需要重新生成，但是仍然希望使用md5校验一下，提高性能
				#if mac
				return isMd5Change([file, topath]);
				#else
				return true;
				#end
			} else {
				return false;
			}
		}
		return true;
	}

	/**
	 * 通过MD5比对文件列表是否存在变更
	 * @param files 
	 * @return Array<String>
	 */
	public function isMd5Change(files:Array<String>):Bool {
		for (file in files) {
			// 如果是文件夹或者不存在时，则立即返回已变更
			if (!FileSystem.exists(file) || FileSystem.isDirectory(file)) {
				return false;
			}
		}
		var cmd = new Process('md5', files);
		var value = cmd.stdout.readAll().toString();
		var md5s = value.split("\n");
		var all = [];
		for (line in md5s) {
			var value = line.split(" ");
			var md5 = value[value.length - 1];
			if (!all.contains(md5)) {
				all.push(md5);
			}
		}
		cmd.close();
		return all.length > 1;
	}

	public function error(file:String):Void {
		__error.push(file);
	}

	public function update(file:String):Void {
		var stat = FileSystem.stat(file);
		var date = stat.mtime.toString();
		Reflect.setProperty(map, file, date);
	}

	public function save() {
		File.saveContent(path, Json.stringify({
			cache: map,
			error: __error
		}, null, "    "));
	}
}
