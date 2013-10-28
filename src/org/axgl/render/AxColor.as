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
		 * Gets the hex value representing this color.
		 *
		 * @return The hex color, as an integer
		 */
		public function get hex():uint {
			return ((int)(0xff * alpha) << 24) + ((int)(0xff * red) << 16) + ((int)(0xff * green) << 8) + (int)(0xff * blue);
		}
		
		/**
		 * Sets this color to the color represented by the passed hex value.
		 * 
		 * @param value The hex value to use, as 0xAARRGGBB
		 */
		public function set hex(value:uint):void {
			alpha = ((value >> 24) & 0xff) / 0xff;
			red = ((value & 0x00ff0000) >> 16) / 0xff;
			green = ((value & 0x0000ff00) >> 8) / 0xff;
			blue = (value & 0x000000ff) / 0xff;
		}
		
		/**
		 * Given a hex value in the form of 0xAARRGGBB, returns a new AxColor.
		 * 
		 * @param hex The hex color, as 0xAARRGGBB
		 */
		public static function fromHex(value:uint):AxColor {
			var color:AxColor = new AxColor;
			color.hex = value;
			return color;
		}
		
		/**
		 * Converts string output to hex format.
		 */
		public function toString():String {
			return hex.toString(16);
		}
	}
}
