package openfl.astc;

import haxe.Exception;
import openfl.events.IOErrorEvent;
import openfl.events.Event;
import openfl.net.URLLoaderDataFormat;
import openfl.net.URLLoader;
import openfl.net.URLRequest;
import openfl.display.ASTCBitmapData;

/**
 * OpenFl Target loader.
 */
class ASTCLoader extends openfl.utils.Future<ASTCBitmapData> {
	public function new(url:String) {
		super();
		var req = new URLRequest(url);
		var loader:URLLoader = new URLLoader();
		loader.dataFormat = URLLoaderDataFormat.BINARY;
		loader.addEventListener(Event.COMPLETE, e -> {
			try {
				var bitmapData = ASTCBitmapData.fromBytes(loader.data);
				this.value = bitmapData;
				this.isComplete = true;
				if (__completeListeners != null)
					for (call in __completeListeners) {
						call(bitmapData);
					}
			} catch (e:Exception) {
				this.error = e;
				this.isError = true;
				if (__errorListeners != null)
					for (call in __errorListeners) {
						call(e);
					}
			}
		});
		loader.addEventListener(IOErrorEvent.IO_ERROR, e -> {
			this.error = e;
			this.isError = true;
			if (__errorListeners != null)
				for (call in __errorListeners) {
					call(e);
				}
		});
		loader.load(req);
	}
}
