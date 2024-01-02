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
	 * Create a `Bytes` from `BitmapData`, Will do it conver to ASTC Texture bytes.
	 * @param bitmapData A BitmapData
	 * @param astcProperties ASTC Properties
	 * @return Null<Bytes>
	 */
	public static function encodeASTCFromBitmapData(bitmapData:BitmapData, ?astcProperties:ASTCEncodeProperties):Null<Bytes> {
		if (bitmapData == null || bitmapData.image == null)
			return null;

		return encodeASTCFromImage(bitmapData.image, astcProperties);
	}
	#end

	#if lime
	/**
	 * Create a `Bytes` from `lime.graphics.Image`, Will do it conver to ASTC Texture bytes.
	 * @param image
	 * @param astcProperties ASTC Properties
	 * @return Null<Bytes>
	 */
	public static function encodeASTCFromImage(image:Image, ?astcProperties:ASTCEncodeProperties):Null<Bytes> {
		if (astcProperties == null)
			astcProperties = {};

		var imageBuffer:ImageBuffer = image.buffer;

		var bitmapInfo:UInt32 = 0;
		var pixelFormat:PixelFormat = imageBuffer.format;
		if (pixelFormat == PixelFormat.ARGB32) {
			bitmapInfo = untyped __cpp__("kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Big");
		} else if (pixelFormat == PixelFormat.RGBA32) {
			bitmapInfo = untyped __cpp__("kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big");
		} else if (pixelFormat == PixelFormat.BGRA32) {
			bitmapInfo = untyped __cpp__("kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little");
		}

		var nativeImageData:Pointer<cpp.UInt8> = NativeArray.address(imageBuffer.data.toBytes().getData(), 0);

		untyped __cpp__("
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef bitmapContext = CGBitmapContextCreate({0}, {1}, {2}, 8, 4 * {1}, colorSpace, {3});
        CGColorSpaceRelease(colorSpace);
        CGImageRef cgImage = CGBitmapContextCreateImage(bitmapContext);
        CGContextRelease(bitmapContext);", nativeImageData, image.width, image.height, bitmapInfo);
		var bytes = encodeASTCFromCGImage(untyped __cpp__("cgImage"), astcProperties);
		untyped __cpp__("CGImageRelease(cgImage)");
		return bytes;
	}
	#end

	/**
	 * Provide the 'PNG' image path through a local file and convert it to an ASTC texture
	 * @param path Local path
	 * @param astcProperties ASTC Properties
	 * @return Null<Bytes>
	 */
	public static function encodeASTCFromFile(path:String, ?astcProperties:ASTCEncodeProperties):Null<Bytes> {
		// 兼容IOS
		var bytes = File.getBytes(Path.join(["assets", path]));
		return encodeASTCFromBytes(bytes, astcProperties);
	}

	/**
	 * Convert binary data from PNG images to ASTC textures
	 * @param bytes PNG Bytes
	 * @param astcProperties ASTC Properties
	 * @return Null<Bytes>
	 */
	public static function encodeASTCFromBytes(bytes:Bytes, ?astcProperties:ASTCEncodeProperties):Null<Bytes> {
		if (bytes == null)
			return null;

		if (astcProperties == null)
			astcProperties = {};

		var uiimage = UIImage.imageWithData(bytes);
		var source:CGImageRef = uiimage.CGImage();

		if (astcProperties.alphaPermultiplied == null)
			astcProperties.alphaPermultiplied = true;

		var astcBytes:Bytes = encodeASTCFromCGImage(source, astcProperties);
		return astcBytes;
	}

	/**
	 * Convert to ASTC texture through the `CGImage` object
	 * @param cgImage
	 * @param astcProperties
	 * @return Null<Bytes>
	 */
	public static function encodeASTCFromCGImage(source:CGImageRef, ?astcProperties:ASTCEncodeProperties):Null<Bytes> {
		if (source == null)
			return null;

		if (astcProperties == null)
			astcProperties = {};

		var autoRelease = false;

		if (astcProperties.alphaPermultiplied == true) {
			autoRelease = true;
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
			// CGImageRef oldImage = {0};
			CGImageRef image = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | (bitmapInfo & kCGBitmapByteOrderMask), dataProvider, CGImageGetDecode({0}), shouldInterpolate, intent);
			{0} = image;
			// CGImageRelease(oldImage);', source);
		}

		var data:NSMutableData = NSMutableData.data();
		untyped __cpp__('CGImageDestinationRef destination = {0}',
			untyped __cpp__('CGImageDestinationCreateWithData((CFMutableDataRef){0}, (CFStringRef)@"org.khronos.astc", 1, nil)', data));
		var properties:NSDictionary = NSDictionary.fromDynamic({
			"kCGImagePropertyASTCFlipVertically": astcProperties.filpVertically != null ? astcProperties.filpVertically : false,
			"kCGImagePropertyASTCBlockSize": astcProperties.blockSize != null ? astcProperties.blockSize : 0x88,
			"kCGImageDestinationLossyCompressionQuality": astcProperties.quality != null ? astcProperties.quality : 0
		});
		var isFinalize = false;
		untyped __cpp__('
        CGImageDestinationAddImage(destination, {0}, (CFDictionaryRef){1});
		if(CGImageDestinationFinalize(destination)){
			{2} = true;
		};', source, properties, isFinalize);
		if (!isFinalize) {
			return null;
		}
		var astcNSData:NSData = untyped data;
		var astcBytes = astcNSData.toBytes();

		if (autoRelease) {
			untyped __cpp__('
			// Freed all
			CGColorSpaceRef colorSpace = CGImageGetColorSpace({0});
			CGDataProviderRef dataProvider = CGImageGetDataProvider({0});
			CGColorSpaceRelease(colorSpace);
			CGDataProviderRelease(dataProvider);
			CGImageRelease({0})', source);
		}
		// untyped __cpp__('CFRelease(destination)');
		return astcBytes;
	}
}

@:structAccess
@:native("CGImageRef")
@:include("UIKit/UIKit.h")
extern class CGImageRef {}

/**
 * ##### CN
 * ASTC编码属性，它可以控制基本参数，如垂直翻转、透明预乘和压缩纹理的压缩质量。
 * ##### EN
 * ASTC Encode Properties, It can control basic parameters such as vertical flipping, transparent premultiplication, and compression quality of compressed textures.
 */
typedef ASTCEncodeProperties = {
	/**
	 * ###### CN
	 * 是否发生垂直翻转，默认为`false`
	 * ###### EN
	 * Whether vertical flipping occurs, default to `false`
	 */
	var ?filpVertically:Bool;

	/**
	 * ##### CN
	 * 提供编码的比率，当不提供时，默认值为`ASTCBlockSize.BLOCK_8X8`
	 * ##### EN
	 * The ratio for providing encoding, when not provided, defaults to ` ASTCBlockSize BLOCK_ 8X8`
	 */
	var ?blockSize:ASTCBlockSize;

	/**
	 * ##### CN
	 * 压缩质量，有效值为`0`-`1`，默认为`0`
	 * ##### EN
	 * Compression quality, valid values are `0`-`1`, default is `0`
	 */
	var ?quality:Float;

	/**
	 * ##### CN
	 * 是否开启透明预乘，默认为`null`，当为`true`时，则会进行透明预乘格式转换，重新生成一个新的`CGImage`
	 * ##### EN
	 * Whether to enable transparent pre multiplication, default to `null`. When it is `true`,
	 * transparent pre multiplication format conversion will be performed, and a new `CGImage` will be generated
	 */
	var ?alphaPermultiplied:Bool;
}
#end
