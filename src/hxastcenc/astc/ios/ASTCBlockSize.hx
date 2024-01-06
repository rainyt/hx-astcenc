package hxastcenc.astc.ios;

/**
 * ASTC块比率
 */
enum abstract ASTCBlockSize(UInt) to UInt {
	/**
	 * 8x8 block size
	 */
	var BLOCK_8X8 = 0x88;

	/**
	 * 6x6 block size
	 */
	var BLOCK_6X6 = 0x66;

	/**
	 * 4x4 block size
	 */
	var BLOCK_4X4 = 0x44;
}
