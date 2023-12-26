// package openfl.astc.ios;

// import ios.metal.MTLTextureDescriptor;
// #if hx_ios_uikit
// import ios.metal.MTLCommandEncoder;
// import sys.io.File;
// import ios.objc.CGImageDestination;
// import ios.uikit.UIImage;
// import ios.metal.MTLTexture;

// class AppleASTCLoader {
// 	public static function loadPNGImage(path:String):MTLTexture {
// 		var bytes = File.getBytes(path);
// 		var image = UIImage.imageWithData(bytes);
// 		var width = Math.floor(image.size.width);
// 		var height = Math.floor(image.size.height);
// 		untyped __cpp__('
// 		// 创建一个位图上下文
// 		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
// 		uint8_t *rawData = (uint8_t *)calloc({1} * {0} * 4, sizeof(uint8_t));
// 		CGContextRef context = CGBitmapContextCreate(rawData, {0}, {1}, 8, 4 * {0}, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
// 		CGColorSpaceRelease(colorSpace);
// 		// 将图片绘制到位图上下文中
// 		CGContextDrawImage(context, CGRectMake(0, 0, {0}, {1}), image.CGImage);
// 		CGContextRelease(context);
// 		// 创建一个MTLTextureDescriptor对象，用来描述纹理的属性
// 		MTLTextureDescriptor *textureDescriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRGBA8Unorm width:{0} height:{1} mipmapped:NO];
// 		// 创建一个MTLTexture对象，用来存储图片的数据
// 		id<MTLTexture> texture = [self.device newTextureWithDescriptor:textureDescriptor];
// 		// 将图片的数据复制到MTLTexture对象中
// 		[texture replaceRegion:MTLRegionMake2D(0, 0, {0}, {1}) mipmapLevel:0 withBytes:rawData bytesPerRow:4 * {0}];
// 		// 释放图片的数据
// 		free(rawData);
// 		return texture');
// 		// var textureDescriptor:MTLTextureDescriptor = MTLTextureDescriptor.texture2DDescriptorWithPixelFormatWidthHeightMipmapped(MTLPixelFormatRGBA8Unorm,
// 			// width, height, false);
// 		return null;
// 	}

// 	/**
// 	 * 将纹理转换成ASTC纹理
// 	 * @param texture 
// 	 */
// 	public static function convertTextureToASTC(texture:Dynamic):Void {
// 		untyped __cpp__('
// 		// 创建一个MTLTextureDescriptor对象，用来描述astc压缩纹理的属性
// 		MTLTextureDescriptor *textureDescriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatASTC_8x8_sRGB width:texture.width height:texture.height mipmapped:NO];
// 		// 创建一个MTLTexture对象，用来存储astc压缩纹理的数据
// 		id<MTLTexture> compressedTexture = [self.device newTextureWithDescriptor:textureDescriptor];
// 		// 创建一个MTLBlitCommandEncoder对象，用来执行纹理的复制和转换操作
// 		id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
// 		id<MTLBlitCommandEncoder> blitCommandEncoder = [commandBuffer blitCommandEncoder];
// 		// 将原始纹理的数据复制并转换到astc压缩纹理中
// 		[blitCommandEncoder copyFromTexture:texture sourceSlice:0 sourceLevel:0 sourceOrigin:MTLOriginMake(0, 0, 0) sourceSize:MTLSizeMake(texture.width, texture.height, 1) toTexture:compressedTexture destinationSlice:0 destinationLevel:0 destinationOrigin:MTLOriginMake(0, 0, 0)];
// 		// 结束纹理的复制和转换操作
// 		[blitCommandEncoder endEncoding];
// 		// 提交命令缓冲区并等待完成
// 		[commandBuffer commit];
// 		[commandBuffer waitUntilCompleted];
// 		// 创建一个NSData对象，用来存储astc压缩纹理的数据
// 		NSUInteger dataSize = compressedTexture.width * compressedTexture.height;
// 		NSMutableData *data = [NSMutableData dataWithLength:dataSize];
// 		// 将astc压缩纹理的数据复制到NSData对象中
// 		[compressedTexture getBytes:data.mutableBytes bytesPerRow:compressedTexture.width fromRegion:MTLRegionMake2D(0, 0, compressedTexture.width, compressedTexture.height) mipmapLevel:0];
// 		// 创建一个NSData对象，用来存储astc文件的头部信息
// 		NSMutableData *header = [NSMutableData dataWithLength:16];
// 		uint8_t *headerBytes = header.mutableBytes;
// 		// 设置astc文件的魔数
// 		headerBytes[0] = 0x13;
// 		headerBytes[1] = 0xAB;
// 		headerBytes[2] = 0xA1;
// 		headerBytes[3] = 0x5C;
// 		// 设置astc文件的块大小
// 		headerBytes[4] = 8;
// 		headerBytes[5] = 8;
// 		// 设置astc文件的纹理维度
// 		headerBytes[6] = compressedTexture.width & 0xFF;
// 		headerBytes[7] = (compressedTexture.width >> 8) & 0xFF;
// 		headerBytes[8] = (compressedTexture.width >> 16) & 0xFF;
// 		headerBytes[9] = compressedTexture.height & 0xFF;
// 		headerBytes[10] = (compressedTexture.height >> 8) & 0xFF;
// 		headerBytes[11] = (compressedTexture.height >> 16) & 0xFF;
// 		headerBytes[12] = 1;
// 		headerBytes[13] = 0;
// 		headerBytes[14] = 0;
// 		headerBytes[15] = 0;
// 		// 将astc文件的头部信息和数据拼接起来
// 		[header appendData:data]');
// 	}
// }
// #end
