package org.axgl.render {
	/**
	 * Describes the properties of an axis-aligned quad used for drawing a sprite.
	 */
	public class AxQuad {
		/** The width of the quad in pixels. */
		public var width:Number;
		/** The height of the quad in pixels. */
		public var height:Number;
		/** The width of the texture area this quad maps to. */
		public var uvWidth:Number;
		/** The height of the texture area this quad maps to. */
		public var uvHeight:Number;

		/**
		 * Creates a new quad.
		 *
		 * @param width The width in pixels.
		 * @param height The height in pixels.
		 * @param uvWidth The width of the texture area this quad maps to.
		 * @param uvHeight The height of the texture area this quad maps to.
		 */
		public function AxQuad(width:Number, height:Number, uvWidth:Number, uvHeight:Number) {
			this.width = width;
			this.height = height;
			this.uvWidth = uvWidth;
			this.uvHeight = uvHeight;
		}
	}
}
