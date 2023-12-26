package utils;

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

	public function isChange(file:String):Bool {
		var data = Reflect.getProperty(map, file);
		if (data != null) {
			var stat = FileSystem.stat(file);
			var date = stat.mtime.toString();
			return date != data;
		}
		return true;
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
