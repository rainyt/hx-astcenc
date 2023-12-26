package;

import openfl.display.Bitmap;
import openfl.display.ASTCBitmapData;
import openfl.display.Sprite;

class Main extends Sprite {
	public function new() {
		super();
		// ASTCBitmapData.fromBytes(bytes);
		if (ASTCBitmapData.isSupportASTCConfig()) {
			trace("Support ASTC Config");
		}
		ASTCBitmapData.loadFromFile("assets/4x4.astc").onComplete(data -> {
			var bitmap = new Bitmap(data);
			this.addChild(bitmap);
		}).onError(err -> {
			trace("Load fail", err);
		});
	}
}
