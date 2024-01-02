# hx-astcenc
 Create ASTC format texture file.

## About
Current only mac support now. About window, Need do `haxe build-window.hxml` to build window target.

# Use
```shell
haxelib run hx-astcenc c -cl ./ChristGiftViewAtlas.png ./texture_zilb.astc 4x4 -exhaustive -pp-premultiply
```

# Json Config
Use Json data create all ASTC file.
```json
[
    {
        "zlib": true,
        "mode": "-cl",
        "defaultBlock": "6x6",
        "quality": "-exhaustive",
        "alphaPremultiply": true,
        "path": "Assets",
        "output": "Assets_astc",
        "igroneError": true
    },
    {
        "zlib": true,
        "mode": "-cl",
        "defaultBlock": "4x4",
        "quality": "-exhaustive",
        "alphaPremultiply": true,
        "path": "../../Assets2",
        "output": "Assets_astc",
        "igroneError": true
    }
]
```
### Command:
```shell
haxelib run hx-astcenc file.json
```

# OpenFL Target ASTC Texture Support
```haxe
import openfl.display.ASTCBitmapData;

// Create from Bytes
ASTCBitmapData.fromBytes(bytes);
if (ASTCBitmapData.isSupportASTCConfig()) {
    trace("Support ASTC Config");
}
// Create from url or local path
ASTCBitmapData.loadFromFile("assets/4x4.astc").onComplete(data -> {
    var bitmap = new Bitmap(data);
    this.addChild(bitmap);
}).onError(err -> {
    trace("Load fail", err);
});
// Create from a BitmapData
ASTCBitmapData.fromBitmapData(bitmapData);
// Create from local path .png format, But it only IOS support.
ASTCBitmapData.loadFromPngFile("assets/4x4.png");
```

##### Display ASTCBitmapData
```haxe
var bitmap = new Bitmap();
bitmap.bitmapData = ASTCBitmapData.fromBytes(bytes);
this.addChild(bitmap);
```