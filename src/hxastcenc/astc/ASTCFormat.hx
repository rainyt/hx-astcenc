package hxastcenc.astc;

/**
 * All enumerations supported by ASTC texture
 */
enum abstract ASTCFormat(UInt) to UInt from UInt {
	var COMPRESSED_RGBA_ASTC_4x4_KHR = 0x93B0;
	var COMPRESSED_RGBA_ASTC_5x4_KHR = 0x93B1;
	var COMPRESSED_RGBA_ASTC_5x5_KHR = 0x93B2;
	var COMPRESSED_RGBA_ASTC_6x5_KHR = 0x93B3;
	var COMPRESSED_RGBA_ASTC_6x6_KHR = 0x93B4;
	var COMPRESSED_RGBA_ASTC_8x5_KHR = 0x93B5;
	var COMPRESSED_RGBA_ASTC_8x6_KHR = 0x93B6;
	var COMPRESSED_RGBA_ASTC_8x8_KHR = 0x93B7;
	var COMPRESSED_RGBA_ASTC_10x5_KHR = 0x93B8;
	var COMPRESSED_RGBA_ASTC_10x6_KHR = 0x93B9;
	var COMPRESSED_RGBA_ASTC_10x8_KHR = 0x93BA;
	var COMPRESSED_RGBA_ASTC_10x10_KHR = 0x93BB;
	var COMPRESSED_RGBA_ASTC_12x10_KHR = 0x93BC;
	var COMPRESSED_RGBA_ASTC_12x12_KHR = 0x93BD;
	var COMPRESSED_SRGB8_ALPHA8_ASTC_4x4_KHR = 0x93D0;
	var COMPRESSED_SRGB8_ALPHA8_ASTC_5x4_KHR = 0x93D1;
	var COMPRESSED_SRGB8_ALPHA8_ASTC_5x5_KHR = 0x93D2;
	var COMPRESSED_SRGB8_ALPHA8_ASTC_6x5_KHR = 0x93D3;
	var COMPRESSED_SRGB8_ALPHA8_ASTC_6x6_KHR = 0x93D4;
	var COMPRESSED_SRGB8_ALPHA8_ASTC_8x5_KHR = 0x93D5;
	var COMPRESSED_SRGB8_ALPHA8_ASTC_8x6_KHR = 0x93D6;
	var COMPRESSED_SRGB8_ALPHA8_ASTC_8x8_KHR = 0x93D7;
	var COMPRESSED_SRGB8_ALPHA8_ASTC_10x5_KHR = 0x93D8;
	var COMPRESSED_SRGB8_ALPHA8_ASTC_10x6_KHR = 0x93D9;
	var COMPRESSED_SRGB8_ALPHA8_ASTC_10x8_KHR = 0x93DA;
	var COMPRESSED_SRGB8_ALPHA8_ASTC_10x10_KHR = 0x93DB;
	var COMPRESSED_SRGB8_ALPHA8_ASTC_12x10_KHR = 0x93DC;
	var COMPRESSED_SRGB8_ALPHA8_ASTC_12x12_KHR = 0x93DD;

	/**
	 * 获得ASTC压缩格式
	 * @param x 
	 * @param y 
	 * @param z 
	 * @return ASTCFormat
	 */
	public static function getFormat(x:Int, y:Int, z:Int = 1, isAlpha8:Bool = false):ASTCFormat {
		if (isAlpha8) {
			if (x == 4 && y == 4)
				return COMPRESSED_SRGB8_ALPHA8_ASTC_4x4_KHR;
			else if (x == 5 && y == 4)
				return COMPRESSED_SRGB8_ALPHA8_ASTC_5x4_KHR;
			else if (x == 5 && y == 5)
				return COMPRESSED_SRGB8_ALPHA8_ASTC_5x5_KHR;
			else if (x == 6 && y == 5)
				return COMPRESSED_SRGB8_ALPHA8_ASTC_6x5_KHR;
			else if (x == 6 && y == 6)
				return COMPRESSED_SRGB8_ALPHA8_ASTC_6x6_KHR;
			else if (x == 8 && y == 5)
				return COMPRESSED_SRGB8_ALPHA8_ASTC_8x5_KHR;
			else if (x == 8 && y == 6)
				return COMPRESSED_SRGB8_ALPHA8_ASTC_8x6_KHR;
			else if (x == 8 && y == 8)
				return COMPRESSED_SRGB8_ALPHA8_ASTC_8x8_KHR;
			else if (x == 10 && y == 5)
				return COMPRESSED_SRGB8_ALPHA8_ASTC_10x5_KHR;
			else if (x == 10 && y == 6)
				return COMPRESSED_SRGB8_ALPHA8_ASTC_10x6_KHR;
			else if (x == 10 && y == 8)
				return COMPRESSED_SRGB8_ALPHA8_ASTC_10x8_KHR;
			else if (x == 10 && y == 10)
				return COMPRESSED_SRGB8_ALPHA8_ASTC_10x10_KHR;
			else if (x == 12 && y == 10)
				return COMPRESSED_SRGB8_ALPHA8_ASTC_12x10_KHR;
			else if (x == 12 && y == 12)
				return COMPRESSED_SRGB8_ALPHA8_ASTC_12x12_KHR;
		} else {
			if (x == 4 && y == 4)
				return COMPRESSED_RGBA_ASTC_4x4_KHR;
			else if (x == 5 && y == 4)
				return COMPRESSED_RGBA_ASTC_5x4_KHR;
			else if (x == 5 && y == 5)
				return COMPRESSED_RGBA_ASTC_5x5_KHR;
			else if (x == 6 && y == 5)
				return COMPRESSED_RGBA_ASTC_6x5_KHR;
			else if (x == 6 && y == 6)
				return COMPRESSED_RGBA_ASTC_6x6_KHR;
			else if (x == 8 && y == 5)
				return COMPRESSED_RGBA_ASTC_8x5_KHR;
			else if (x == 8 && y == 6)
				return COMPRESSED_RGBA_ASTC_8x6_KHR;
			else if (x == 8 && y == 8)
				return COMPRESSED_RGBA_ASTC_8x8_KHR;
			else if (x == 10 && y == 5)
				return COMPRESSED_RGBA_ASTC_10x5_KHR;
			else if (x == 10 && y == 6)
				return COMPRESSED_RGBA_ASTC_10x6_KHR;
			else if (x == 10 && y == 8)
				return COMPRESSED_RGBA_ASTC_10x8_KHR;
			else if (x == 10 && y == 10)
				return COMPRESSED_RGBA_ASTC_10x10_KHR;
			else if (x == 12 && y == 10)
				return COMPRESSED_RGBA_ASTC_12x10_KHR;
			else if (x == 12 && y == 12)
				return COMPRESSED_RGBA_ASTC_12x12_KHR;
		}
		return 0;
	}
}
