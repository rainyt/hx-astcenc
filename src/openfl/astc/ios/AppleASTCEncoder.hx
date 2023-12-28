package openfl.astc.ios;

import openfl.astc.ios.ASTCBlockSize;
import haxe.io.BytesBuffer;
#if hx_ios_uikit
import haxe.io.Path;
import cpp.objc.NSDictionary;
import cpp.objc.NSData;
import haxe.io.Bytes;
import ios.foundation.NSMutableData;
import sys.io.File;
import ios.uikit.UIImage;

/**
 * Apple ASTC Texture encoder.
 */
@:cppFileCode('
#include "UIKit/UIKit.h"
#include "ImageIO/ImageIO.h"
')
class AppleASTCEncoder {
	/**
	 * 通过本地文件提供`PNG`图片路径，进行转换为ASTC纹理
	 * @param path 本地路径
	 * @param astcProperties 对ASTC编码时的参数配置支持
	 * @return Bytes
	 */
	public static function encodeASTCFromFile(path:String, ?astcProperties:ASTCEncodeProperties):Bytes {
		// 兼容IOS
		var bytes = File.getBytes(Path.join(["assets", path]));
		return encodeASTCFromBytes(bytes, astcProperties);
	}

	/**
	 * 通过`PNG`图片二进制数据，进行转换为ASTC纹理
	 * @param bytes 
	 * @param astcProperties 
	 * @return Bytes 当转换成功，则会返回`ASTC`的二进制数据，否则返回`null`
	 */
	public static function encodeASTCFromBytes(bytes:Bytes, ?astcProperties:ASTCEncodeProperties):Bytes {
		var image = UIImage.imageWithData(bytes);
		untyped __cpp__('CGImageRef source = {0}', image.CGImage());
		var data:NSMutableData = NSMutableData.data();
		untyped __cpp__('CGImageDestinationRef destination = {0}',
			untyped __cpp__('CGImageDestinationCreateWithData((CFMutableDataRef){0}, (CFStringRef)@"org.khronos.astc", 1, nil)', data));
		var properties:NSDictionary = NSDictionary.fromDynamic({
			"kCGImagePropertyASTCFlipVertically": astcProperties.filpVertically != null ? astcProperties.filpVertically : false,
			"kCGImagePropertyASTCBlockSize": astcProperties.blockSize != null ? astcProperties.blockSize : 0x88,
			"kCGImageDestinationLossyCompressionQuality": astcProperties.quality != null ? astcProperties.quality : 0,
			"kCGImagePropertyHasAlpha": true,
			"kCGImageAlphaInfo": 2
		});
		untyped __cpp__('
        CGImageDestinationAddImage({0}, {1}, (CFDictionaryRef){2});
		CGImageDestinationFinalize({0})', destination, source, properties);
		var astcNSData:NSData = untyped data;
		var astcBytes = astcNSData.toBytes();
		return astcBytes;
	}
}

/**
 * ASTC解码参数
 */
typedef ASTCEncodeProperties = {
	/**
	 * 是否发生垂直翻转处理，默认为`false`
	 */
	var ?filpVertically:Bool;

	/**
	 * 提供编码的比率，当不提供时，默认值为`ASTCBlockSize.BLOCK_8X8`
	 */
	var ?blockSize:ASTCBlockSize;

	/**
	 * 压缩质量，有效值为`0`-`1`，默认为`0`
	 */
	var ?quality:Float;
}
#end
