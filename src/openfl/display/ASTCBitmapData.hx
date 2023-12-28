package openfl.display;

import openfl.astc.ios.AppleASTCEncoder.ASTCEncodeProperties;
import openfl.astc.ASTCLoader;
import openfl.utils.Future;
import openfl.events.IOErrorEvent;
import openfl.net.URLLoaderDataFormat;
import openfl.events.Event;
import openfl.net.URLLoader;
import openfl.net.URLRequest;
import openfl.display3D.textures.TextureBase;
import openfl.display3D.textures.RectangleTexture;
import openfl.display3D.Context3D;
import lime.utils.UInt8Array;
import openfl.astc.ASTCFormat;
import openfl.utils.ByteArray;
import lime.graphics.opengl.GL;
import haxe.io.Bytes;
import openfl.display.BitmapData;

/**
 * ASTC Texture BitmapData. Supports IOS, Android, and HTML5 targets, 
 * But it is still necessary to pay attention to whether the device supports ASTC compressed textures
 */
@:access(openfl.display3D.textures.RectangleTexture)
@:access(openfl.display3D.textures.TextureBase)
class ASTCBitmapData extends BitmapData {
	/**
	 * Check if Zlib compression is used
	 * @param bytes 
	 * @return Bool
	 */
	public static function isZlibFile(bytes:Bytes):Bool {
		var v1 = bytes.get(0);
		var v2 = bytes.get(1);
		if (v1 == 120) {
			switch (v2) {
				case 218:
					return true;
			}
		}
		return false;
	}

	/**
	 * Check it support the current ASTC configuration
	 * @param format 
	 * @return Bool
	 */
	public static function isSupportASTCConfig():Bool {
		var ext:Dynamic = GL.getExtension(#if (lime_opengl || lime_opengles) "KHR_texture_compression_astc_ldr" #else "WEBGL_compressed_texture_astc" #end);
		return ext != null;
	}

	/**
	 * Creates a new BitmapData from bytes (a haxe.io.Bytes or openfl.utils.ByteArray)
	 * synchronously. This means that the BitmapData will be returned immediately (if
	 * supported).
	 * @param bytes A haxe.io.Bytes or openfl.utils.ByteArray, It is ASTC Texture Fromat.
	 * @return ASTCBitmapData
	 */
	public static function fromBytes(bytes:Bytes):ASTCBitmapData {
		if (bytes == null)
			throw "Bytes is null.";
		if (isZlibFile(bytes)) {
			var byteArray = ByteArray.fromBytes(bytes);
			byteArray.uncompress();
		}
		// 读取ASTC纹理的格式 4x4 6x6等信息
		var blockX:Int = bytes.get(0x4);
		var blockY:Int = bytes.get(0x5);
		var isSRGBA = false;
		var astcFormat = ASTCFormat.getFormat(blockX, blockY, 1, isSRGBA);
		var format = isSRGBA ? 'COMPRESSED_SRGB8_ALPHA8_ASTC_${blockX}x${blockY}_KHR' : 'COMPRESSED_RGBA_ASTC_${blockX}x${blockY}_KHR';
		// 纹理的尺寸
		var width:Int = bytes.getUInt16(0x7);
		var height:Int = bytes.getUInt16(0xA);
		// 图片压缩纹理内容，头信息永远为16位，因此只需要偏移16位后的二进制
		var bodyBytes = bytes.sub(16, bytes.length - 16);
		var uint8Array:UInt8Array = UInt8Array.fromBytes(bodyBytes);
		// WEBGL 检查是否支持压缩配置
		var ext:Dynamic = GL.getExtension(#if (lime_opengl || lime_opengles) "KHR_texture_compression_astc_ldr" #else "WEBGL_compressed_texture_astc" #end);
		if (ext == null) {
			throw "Don't support ASTC extension.";
		}
		// 这里要检查是否支持ASTC纹理配置等支持
		var value = Reflect.getProperty(ext, format);
		if (value == null) {
			throw 'Don\'t support ASTC $format extension.';
		}
		var context3D:Context3D = Lib.current.stage.context3D;
		var rectangleTexture:RectangleTexture = new RectangleTexture(context3D, width, height, null, false);
		GL.bindTexture(GL.TEXTURE_2D, rectangleTexture.__textureID);
		rectangleTexture.__format = astcFormat;
		#if (lime_opengl || lime_opengles)
		GL.compressedTexImage2D(GL.TEXTURE_2D, 0, rectangleTexture.__format, rectangleTexture.__width, rectangleTexture.__height, 0, uint8Array.byteLength,
			uint8Array);
		#elseif lime_webgl
		GL.compressedTexImage2DWEBGL(GL.TEXTURE_2D, 0, rectangleTexture.__format, rectangleTexture.__width, rectangleTexture.__height, 0, uint8Array);
		#end
		GL.bindTexture(GL.TEXTURE_2D, null);
		return fromTexture(rectangleTexture);
	}

	/**
	 *	Creates a new ASTCBitmapData instance from a Stage3D rectangle texture.
	 *	This method is not supported by the Flash target.
	 *	@param	texture	A Texture or RectangleTexture instance
	 *	@returns ASTCBitmapData
	 */
	public static function fromTexture(texture:TextureBase):ASTCBitmapData {
		if (texture == null)
			return null;
		var bitmapData = new ASTCBitmapData(texture.__width, texture.__height, true, 0);
		bitmapData.readable = false;
		bitmapData.__texture = texture;
		bitmapData.__textureContext = texture.__textureContext;
		bitmapData.image = null;
		return bitmapData;
	}

	/**
	 * Creates a new BitmapData from a file path or web address asynchronously. The file
	 *	load and image decoding will occur in the background.
	 *	Progress, completion and error callbacks will be dispatched in the current
	 *	thread using callbacks attached to a returned Future object.
	 * #### IOS AppleASTCEncoder support
	 * **IOS** loadFromPngFile
	 * @return ASTCBitmapData
	 */
	public static function loadFromFile(url:String):Future<ASTCBitmapData> {
		return new ASTCLoader(url);
	}

	#if ios
	/**
	 * Load png conver to ASTC texture, Only IOS sdk 10+ version suppport.
	 * @param url 
	 * @return Future<ASTCBitmapData>
	 */
	public static function loadFromPngFile(url:String, ?astcProperties:ASTCEncodeProperties):ASTCBitmapData {
		var bytes = openfl.astc.ios.AppleASTCEncoder.encodeASTCFromFile(url, astcProperties);
		if (bytes == null) {
			trace("Bytes is null.");
			return null;
		}
		return openfl.display.ASTCBitmapData.fromBytes(bytes);
	}
	#end
}
