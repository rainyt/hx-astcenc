package openfl.astc.ios;

import haxe.io.BytesBuffer;
#if hx_ios_uikit
import haxe.io.Path;
import cpp.objc.NSDictionary;
import cpp.objc.NSData;
import haxe.io.Bytes;
import ios.foundation.NSMutableData;
import sys.io.File;
import ios.uikit.UIImage;

@:cppFileCode('
#include "UIKit/UIKit.h"
#include "ImageIO/ImageIO.h"
')
class AppleASTCLoader {
	/**
		* //             NSMutableData *data = [NSMutableData data];
				// CGImageDestinationRef destination = CGImageDestinationCreateWithData((CFMutableDataRef)data, (CFStringRef)@"org.khronos.ktx", 1, nil);
				// NSDictionary *properties = @{@"kCGImagePropertyASTCBlockSize": @(0x88)};
				// CGImageDestinationAddImage(destination, source, (CFDictionaryRef)properties);
				// CGImageDestinationFinalize(destination);
		* @param url 
		* @return Bytes
	 */
	public static function convertToASTC(url:String):Bytes {
		var bytes = File.getBytes(Path.join(["assets", url]));
		trace("test bytes", bytes.length);
		var image = UIImage.imageWithData(bytes);
		untyped __cpp__('CGImageRef source = {0}', image.CGImage());
		var data:NSMutableData = NSMutableData.data();
		untyped __cpp__('CGImageDestinationRef destination = {0}',
			untyped __cpp__('CGImageDestinationCreateWithData((CFMutableDataRef){0}, (CFStringRef)@"org.khronos.astc", 1, nil)', data));
		var properties:NSDictionary = NSDictionary.fromDynamic({
			"kCGImagePropertyASTCFlipVertically": false,
			"kCGImagePropertyASTCBlockSize": 0x88,
			"kCGImageDestinationLossyCompressionQuality": 0
			// "kCGImagePropertyHasAlpha": true,
			// "kCGImageAlphaInfo": "at_alpha_premultiplied"
		});
		untyped __cpp__('
        CGImageDestinationAddImage({0}, {1}, (CFDictionaryRef){2});
		CGImageDestinationFinalize({0})', destination, source, properties);
		var astcNSData:NSData = untyped data;
		var astcBytes = astcNSData.toBytes();
		trace("astcBytes.length", astcBytes.length);
		return astcBytes;
	}
}
#end
