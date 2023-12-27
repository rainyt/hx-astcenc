package openfl.astc.ios;

import haxe.io.Path;
import cpp.objc.NSDictionary;
import cpp.objc.NSData;
import haxe.io.Bytes;
import ios.objc.CGImage;
#if hx_ios_uikit
import ios.foundation.NSMutableData;
import ios.metal.MTLTextureDescriptor;
import ios.metal.MTLCommandEncoder;
import sys.io.File;
import ios.objc.CGImageDestination;
import ios.uikit.UIImage;
import ios.metal.MTLTexture;

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
			untyped __cpp__('CGImageDestinationCreateWithData((CFMutableDataRef){0}, (CFStringRef)@"org.khronos.ktx", 1, nil)', data));
		var properties:NSDictionary = NSDictionary.fromDynamic({
			"kCGImagePropertyASTCBlockSize": 0x88
		});
		untyped __cpp__('
        CGImageDestinationAddImage({0}, {1}, (CFDictionaryRef){2});
		CGImageDestinationFinalize({0})', destination, source, properties);
		var astcNSData:NSData = untyped data;
		var astcBytes = astcNSData.toBytes();
		trace("astcBytes.length", astcBytes.length);
		return astcBytes;
	}

	/**
	 * 将纹理转换成ASTC纹理
	 * @param texture 
	 */
	// public static function convertTextureToASTC(texture:Dynamic):Void {
	// 	untyped __cpp__('
	// 	// 创建一个MTLTextureDescriptor对象，用来描述astc压缩纹理的属性
	// 	MTLTextureDescriptor *textureDescriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatASTC_8x8_sRGB width:texture.width height:texture.height mipmapped:NO];
	// 	// 创建一个MTLTexture对象，用来存储astc压缩纹理的数据
	// 	id<MTLTexture> compressedTexture = [self.device newTextureWithDescriptor:textureDescriptor];
	// 	// 创建一个MTLBlitCommandEncoder对象，用来执行纹理的复制和转换操作
	// 	id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
	// 	id<MTLBlitCommandEncoder> blitCommandEncoder = [commandBuffer blitCommandEncoder];
	// 	// 将原始纹理的数据复制并转换到astc压缩纹理中
	// 	[blitCommandEncoder copyFromTexture:texture sourceSlice:0 sourceLevel:0 sourceOrigin:MTLOriginMake(0, 0, 0) sourceSize:MTLSizeMake(texture.width, texture.height, 1) toTexture:compressedTexture destinationSlice:0 destinationLevel:0 destinationOrigin:MTLOriginMake(0, 0, 0)];
	// 	// 结束纹理的复制和转换操作
	// 	[blitCommandEncoder endEncoding];
	// 	// 提交命令缓冲区并等待完成
	// 	[commandBuffer commit];
	// 	[commandBuffer waitUntilCompleted];
	// 	// 创建一个NSData对象，用来存储astc压缩纹理的数据
	// 	NSUInteger dataSize = compressedTexture.width * compressedTexture.height;
	// 	NSMutableData *data = [NSMutableData dataWithLength:dataSize];
	// 	// 将astc压缩纹理的数据复制到NSData对象中
	// 	[compressedTexture getBytes:data.mutableBytes bytesPerRow:compressedTexture.width fromRegion:MTLRegionMake2D(0, 0, compressedTexture.width, compressedTexture.height) mipmapLevel:0];
	// 	// 创建一个NSData对象，用来存储astc文件的头部信息
	// 	NSMutableData *header = [NSMutableData dataWithLength:16];
	// 	uint8_t *headerBytes = header.mutableBytes;
	// 	// 设置astc文件的魔数
	// 	headerBytes[0] = 0x13;
	// 	headerBytes[1] = 0xAB;
	// 	headerBytes[2] = 0xA1;
	// 	headerBytes[3] = 0x5C;
	// 	// 设置astc文件的块大小
	// 	headerBytes[4] = 8;
	// 	headerBytes[5] = 8;
	// 	// 设置astc文件的纹理维度
	// 	headerBytes[6] = compressedTexture.width & 0xFF;
	// 	headerBytes[7] = (compressedTexture.width >> 8) & 0xFF;
	// 	headerBytes[8] = (compressedTexture.width >> 16) & 0xFF;
	// 	headerBytes[9] = compressedTexture.height & 0xFF;
	// 	headerBytes[10] = (compressedTexture.height >> 8) & 0xFF;
	// 	headerBytes[11] = (compressedTexture.height >> 16) & 0xFF;
	// 	headerBytes[12] = 1;
	// 	headerBytes[13] = 0;
	// 	headerBytes[14] = 0;
	// 	headerBytes[15] = 0;
	// 	// 将astc文件的头部信息和数据拼接起来
	// 	[header appendData:data]');
	// }
}
#end
