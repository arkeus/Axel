package org.axgl.render {
	import flash.display3D.Context3DBlendFactor;

	/**
	 * A class describing a blend mode by declaring both the source and destination modes.
	 */
	public class AxBlendMode {
		/**
		 * Source blend factor.
		 */
		public var source:String;
		/**
		 * Destination blend factor. 
		 */
		public var destination:String;

		/**
		 * Creates a new AxBlendMode with the two blend factors passed.
		 * 
		 * @param source The source blend factor.
		 * @param destination The destination blend factor.
		 */
		public function AxBlendMode(source:String, destination:String) {
			this.source = source;
			this.destination = destination;
		}

		/* Useful general blend modes keyed by name */
		public static const ADD:AxBlendMode = new AxBlendMode(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE);
		public static const BLEND:AxBlendMode = new AxBlendMode(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
		public static const FILTER:AxBlendMode = new AxBlendMode(Context3DBlendFactor.DESTINATION_COLOR, Context3DBlendFactor.ZERO);
		public static const MODULATE:AxBlendMode = new AxBlendMode(Context3DBlendFactor.DESTINATION_COLOR, Context3DBlendFactor.ZERO);
		public static const NONE:AxBlendMode = new AxBlendMode(Context3DBlendFactor.ZERO, Context3DBlendFactor.ONE);
		public static const PARTICLE:AxBlendMode = new AxBlendMode(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE);
		/** Useful for drawing images with transparency in the image. Fixes issue with whites becoming blacks when transparent. */
		public static const TRANSPARENT_TEXTURE:AxBlendMode = new AxBlendMode(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
	}
}
