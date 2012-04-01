package org.axgl.render {
	import flash.display3D.textures.Texture;

	/**
	 * A descriptor holding the required information for a texture uploaded to the GPU.
	 */
	public class AxTexture {
		/**
		 * The internal flash representation of the texture. 
		 */
		public var texture:Texture;
		/**
		 * The width of the texture. 
		 */
		public var width:uint;
		/**
		 * The height of the texture.
		 */
		public var height:uint;
		/**
		 * The raw width of the bitmap used to create this texture. 
		 */
		public var rawWidth:uint;
		/**
		 * The raw height of the bitmap used to create this texture. 
		 */
		public var rawHeight:uint;

		/**
		 * Creates a new AxTexture holding the information required for calculating and drawing the texture.
		 * 
		 * @param texture The texture.
		 * @param width The width in pixels.
		 * @param height The height in pixels.
		 * @param rawWidth The raw width of the bitmap used to create the texture.
		 * @param rawHeight The raw height of the bitmap used to create the texture.
		 */
		public function AxTexture(texture:Texture, width:uint, height:uint, rawWidth:uint, rawHeight:uint) {
			this.texture = texture;
			this.width = width;
			this.height = height;
			this.rawWidth = rawWidth;
			this.rawHeight = rawHeight;
		}
	}
}
