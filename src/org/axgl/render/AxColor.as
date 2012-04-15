package org.axgl.render {
	/**
	 * A class describing the red, green, blue, and alpha components of a color.
	 */
	public class AxColor {
		/** The red component, between 0 and 1. */
		public var red:Number;
		/** The green component, between 0 and 1. */
		public var green:Number;
		/** The blue component, between 0 and 1. */
		public var blue:Number;
		/** The alpha component, between 0 and 1. */
		public var alpha:Number;
		
		/**
		 * Creates a new color with the given components, defaults to completely opaque white.
		 * 
		 * @param red The red component, between 0 and 1.
		 * @param green The green component, between 0 and 1.
		 * @param blue The blue component, between 0 and 1.
		 * @param alpha The alpha component, between 0 and 1.
		 */
		public function AxColor(red:Number = 1, green:Number = 1, blue:Number = 1, alpha:Number = 1) {
			this.red = red;
			this.green = green;
			this.blue = blue;
			this.alpha = alpha;
		}
		
		/**
		 * Given a hex value in the form of 0xAARRGGBB, returns a new AxColor.
		 * 
		 * @param hex The hex color, as 0xAARRGGBB
		 */
		public static function fromHex(hex:uint):AxColor {
			var alpha:Number = ((hex & 0xff000000) >> 24) / 0xff;
			var red:Number = ((hex & 0x00ff0000) >> 16) / 0xff;
			var green:Number = ((hex & 0x0000ff00) >> 8) / 0xff;
			var blue:Number = (hex & 0x000000ff) / 0xff;
			return new AxColor(red, green, blue, alpha);
		}
		
		public function toHex():uint {
			return (int)(255 * alpha / 1) << 24 + (int)(255 * red / 1) << 16 + (int)(255 * green / 1) << 8 + (int)(255 * blue / 1);
		}
	}
}
