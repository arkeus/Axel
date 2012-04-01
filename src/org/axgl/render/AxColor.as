package org.axgl.render {
	/**
	 * A class describing the red, green, blue, and alpha components of a color.
	 */
	public class AxColor {
		/** The red component, between 0 and 1. */
		public var r:Number;
		/** The green component, between 0 and 1. */
		public var g:Number;
		/** The blue component, between 0 and 1. */
		public var b:Number;
		/** The alpha component, between 0 and 1. */
		public var a:Number;
		
		/**
		 * Creates a new color with the given components, defaults to completely opaque white.
		 * 
		 * @param red The red component, between 0 and 1.
		 * @param green The green component, between 0 and 1.
		 * @param blue The blue component, between 0 and 1.
		 * @param alpha The alpha component, between 0 and 1.
		 */
		public function AxColor(red:Number = 1, green:Number = 1, blue:Number = 1, alpha:Number = 1) {
			this.r = red;
			this.g = green;
			this.b = blue;
			this.a = alpha;
		}
		
		/**
		 * Given a hex value in the form of 0xAARRGGBB or 0xRRGGBB, returns a new AxColor.
		 * Note: You cannot specify an alpha of 0 using this function, as 0x00FFFFFF will be treated as
		 * 0xFFFFFF which will have alpha as 1.
		 * 
		 * @param hex The hex color, either as 0xAARRGGBB or 0xRRGGBB
		 */
		public static function fromHex(hex:uint):AxColor {
			var alpha:Number = ((hex & 0xff000000) >> 24) / 0xff;
			var red:Number = ((hex & 0x00ff0000) >> 16) / 0xff;
			var green:Number = ((hex & 0x0000ff00) >> 8) / 0xff;
			var blue:Number = (hex & 0x000000ff) / 0xff;
			return new AxColor(red, green, blue, alpha == 0 ? 1 : alpha);
		}
	}
}
