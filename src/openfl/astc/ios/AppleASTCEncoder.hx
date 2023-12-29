package openfl.astc.ios;

#if hx_ios_uikit
import haxe.io.Path;
import cpp.objc.NSDictionary;
import cpp.objc.NSData;
import haxe.io.Bytes;
import ios.foundation.NSMutableData;
import sys.io.File;
import ios.uikit.UIImage;
import ios.objc.CGImage;
import openfl.astc.ios.ASTCBlockSize;
#if openfl
import openfl.display.BitmapData;
#end
#if lime
import cpp.UInt32;
import cpp.Pointer;
import cpp.NativeArray;
import lime.graphics.ImageBuffer;
import lime.graphics.Image;
import lime.graphics.PixelFormat;
#end

/**
 * Apple ASTC Texture encoder.
 */
@:cppFileCode('
#include "UIKit/UIKit.h"
#include "ImageIO/ImageIO.h"
')

class AppleASTCEncoder {

	#if openfl
	/**
	 * 通过`BitmapData`对象，进行转换为ASTC纹理
	 * @param bitmapData
	 * @param astcProperties 对ASTC编码时的参数配置支持
	 * @return Null<Bytes>
	 */
	public static function encodeASTCFromBitmapData(bitmapData:BitmapData, ?astcProperties:ASTCEncodeProperties):Null<Bytes> {
		if (bitmapData == null || bitmapData.image == null)
			return null;

		return encodeASTCFromImage(bitmapData.image, astcProperties);
	}
	#end

	#if lime
	public static function encodeASTCFromImage(image:Image, ?astcProperties:ASTCEncodeProperties):Null<Bytes> {
		if (astcProperties == null)
			astcProperties = {};

		var imageBuffer:ImageBuffer = image.buffer;
		astcProperties.alphaPermultiplied = imageBuffer.premultiplied;

		var bitmapInfo:UInt32 = 0;
		var pixelFormat:PixelFormat = imageBuffer.format;
		if(pixelFormat == PixelFormat.ARGB32)
		{
			bitmapInfo = untyped __cpp__("kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Big");
		}else if(pixelFormat == PixelFormat.RGBA32)
		{
			bitmapInfo = untyped __cpp__("kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big");

		}else if(pixelFormat == PixelFormat.BGRA32)
		{
			bitmapInfo = untyped __cpp__("kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little");
		}

		var nativeImageData:Pointer<cpp.UInt8> = NativeArray.address(imageBuffer.data.toBytes().getData(), 0);

		untyped __cpp__("
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef bitmapContext = CGBitmapContextCreate({0}, {1}, {2}, 8, 4 * {1}, colorSpace, {3});
        CGColorSpaceRelease(colorSpace);
        CGImageRef cgImage = CGBitmapContextCreateImage(bitmapContext);
        CGContextRelease(bitmapContext);", nativeImageData, image.width, image.height, bitmapInfo);

		return encodeASTCFromCGImage(untyped __cpp__("cgImage"), astcProperties);
	}
	#end

	/**
	 * 通过本地文件提供`PNG`图片路径，进行转换为ASTC纹理
	 * @param path 本地路径
	 * @param astcProperties 对ASTC编码时的参数配置支持
	 * @return Null<Bytes>
	 */
	public static function encodeASTCFromFile(path:String, ?astcProperties:ASTCEncodeProperties):Null<Bytes> {
		// 兼容IOS
		var bytes = File.getBytes(Path.join(["assets", path]));
		return encodeASTCFromBytes(bytes, astcProperties);
	}

	/**
	 * 通过`PNG`图片二进制数据，进行转换为ASTC纹理
	 * @param bytes
	 * @param astcProperties
	 * @return Null<Bytes>
	 */
	public static function encodeASTCFromBytes(bytes:Bytes, ?astcProperties:ASTCEncodeProperties):Null<Bytes> {
		if (bytes == null)
			return null;

		if (astcProperties == null)
			astcProperties = {};

		var uiimage = UIImage.imageWithData(bytes);
		untyped __cpp__('CGImageRef source = {0}', uiimage.CGImage());

		var astcBytes:Bytes = encodeASTCFromCGImage(untyped __cpp__("source"), astcProperties);
		return astcBytes;
	}

	/**
	 * 通过`CGImage`对象，进行转换为ASTC纹理
	 * @param cgImage
	 * @param astcProperties
	 * @return Null<Bytes>
	 */
	public static function encodeASTCFromCGImage(source:cpp.Pointer<CGImage>, ?astcProperties:ASTCEncodeProperties):Null<Bytes>
	{
		if (source == null)
			return null;

		if (astcProperties == null)
			astcProperties = {};

		if (astcProperties.alphaPermultiplied == null || astcProperties.alphaPermultiplied == true) {
			untyped __cpp__('
			// 获取原始CGImage的其他参数
			size_t width = CGImageGetWidth({0});
			size_t height = CGImageGetHeight({0});
			size_t bitsPerComponent = CGImageGetBitsPerComponent({0});
			size_t bitsPerPixel = CGImageGetBitsPerPixel({0});
			size_t bytesPerRow = CGImageGetBytesPerRow({0});
			CGColorSpaceRef colorSpace = CGImageGetColorSpace({0});
			CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo({0});
			CGDataProviderRef dataProvider = CGImageGetDataProvider({0});
			bool shouldInterpolate = CGImageGetShouldInterpolate({0});
			CGColorRenderingIntent intent = CGImageGetRenderingIntent({0});

			// 创建一个新的CGImage，指定新的alpha信息
			CGImageRef oldImage = {0};
			CGImageRef image = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | (bitmapInfo & kCGBitmapByteOrderMask), dataProvider, CGImageGetDecode({0}), shouldInterpolate, intent);
			{0} = image;
			CGColorSpaceRelease(colorSpace);
			CGDataProviderRelease(dataProvider);
			CGImageRelease(oldImage);', source);
		}

		var data:NSMutableData = NSMutableData.data();
		untyped __cpp__('CGImageDestinationRef destination = {0}',
	untyped __cpp__('CGImageDestinationCreateWithData((CFMutableDataRef){0}, (CFStringRef)@"org.khronos.astc", 1, nil)', data));
		var properties:NSDictionary = NSDictionary.fromDynamic({
			"kCGImagePropertyASTCFlipVertically": astcProperties.filpVertically != null ? astcProperties.filpVertically : false,
			"kCGImagePropertyASTCBlockSize": astcProperties.blockSize != null ? astcProperties.blockSize : 0x88,
			"kCGImageDestinationLossyCompressionQuality": astcProperties.quality != null ? astcProperties.quality : 0
		});
		untyped __cpp__('
        CGImageDestinationAddImage(destination, {0}, (CFDictionaryRef){1});
		CGImageDestinationFinalize(destination);
		CFRelease(destination);', source, properties);
		var astcNSData:NSData = untyped data;
		var astcBytes = astcNSData.toBytes();

		untyped __cpp__('CGImageRelease({0})', source);
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

	/**
	 * 是否开启透明预乘，默认为`true`
	 */
	var ?alphaPermultiplied:Bool;
}
#end
