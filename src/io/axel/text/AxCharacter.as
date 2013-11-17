package io.axel.text {
	import io.axel.AxRect;

	/**
	 * A class representing the needed variables for each character in an AxFont, including the size of
	 * the character, and the location of the character in the texture.
	 */
	public class AxCharacter {
		/** Width of the character in pixels. */
		public var width:uint;
		/** Height of the character in pixels. */
		public var height:uint;
		/** Location of the character in the font texture. */
		public var uv:AxRect;

		/**
		 * Creates a new character with the passed width, height, and texture coordinates.
		 * 
		 * @param width Width the character in pixels.
		 * @param height Height of the character in pixels.
		 * @param uv Coordinates of the character in the texture.
		 */
		public function AxCharacter(width:uint, height:uint, uv:AxRect) {
			this.width = width;
			this.height = height;
			this.uv = uv;
		}
	}
}
