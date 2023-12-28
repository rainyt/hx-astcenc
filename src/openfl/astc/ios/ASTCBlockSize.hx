package openfl.astc.ios;

/**
 * ASTC块比率
 */
enum abstract ASTCBlockSize(UInt) to UInt {
	/**
	 * 8x8 block size
	 */
	var BLOCK_8X8 = 0x88;

	/**
	 * 4x4 block size
	 */
	var BLOCK_4X4 = 0x44;
}
