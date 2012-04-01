package org.axgl {
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import org.axgl.render.AxShader;
	import org.axgl.render.AxTexture;
	import org.axgl.util.AxCache;

	/**
	 * An <code>AxModel</code> is an entity that is expected to be drawn on the scene. It does not implement any drawing, but defines
	 * the common functionality used for drawing, such as creating vertex buffers and defining a shader. <code>AxSprite</code> is the
	 * most basic implementation of an <code>AxModel</code>, and should be used for all your basic sprite needs.
	 */
	public class AxModel extends AxEntity {
		/** The vertex shader used to draw this model. */
		protected var vertexShader:Array;
		/** The fragment shader used to draw this model. */
		protected var fragmentShader:Array;
		/** The index data used for the mesh of this model. */
		protected var indexData:Vector.<uint>;
		/** The index buffer used for the mesh of this model. */
		protected var indexBuffer:IndexBuffer3D;
		/** The vertex data used for the mesh of this model. */
		protected var vertexData:Vector.<Number>;
		/** The vertex buffer used to draw this model. */
		protected var vertexBuffer:VertexBuffer3D;
		/** The shader (containing the Program3D) used to draw this model. */
		protected var shader:AxShader;
		/** The number of triangles contained in this model's mesh. */
		protected var triangles:uint;
		/** A matrix containing a generic transformation to apply to this model. */
		protected var matrix:Matrix3D;
		/** A vector containing the red, green, blue, and alpha values to transform this model. */
		protected var colorTransform:Vector.<Number>;
		/** The texture used to draw this model. */
		protected var texture:AxTexture;
		
		/** Whether or not to count the tris of this model for display in the debugger */
		public var countTris:Boolean;
		
		/**
		 * The rate at which this sprite scrolls with the camera. A scroll of 1 means that it will not follow the camera, which
		 * is typical of most objects. A scroll of 0 means that it will not scroll as the camera moves, meaning it will follow
		 * the camera. Most UI elements should use a scroll of 0 so they stay in the same place as the camera moves. A scroll
		 * between 0 and 1 means it will move slower than the camera, but will still move. This is usefull for parallax
		 * backgrounds.
		 * 
		 * @default (1, 1)
		 */
		public var scroll:AxPoint;
		
		/**
		 * Whether or not this sprite zooms with the game's zoom level. If your game dynamically changes zoom, and you have a UI
		 * that should not zoom in, set this to false.
		 * 
		 * @default true
		 */
		public var zooms:Boolean;

		/**
		 * The scale of this model. A scale greater than 1 will increase the size, while a scale between 0 and 1 will
		 * decrease the size.
		 *
		 * @default (1, 1)
		 */
		public var scale:AxPoint

		/**
		 * The pivot point of rotation. When loading a graphic in AxSprite, the pivot point will be set to the center
		 * of the entity (eg. the object will rotate around its center).
		 */
		public var pivot:Vector3D;

		/**
		 * Creates a new AxModel at the position passed, using the shaders supplied.
		 *
		 * @param x The initial x value of the object.
		 * @param y The initial y value of the object.
		 * @param vertexShader The vertex shader used to draw the object.
		 * @param fragmentShader The fragment shader used to draw the object.
		 * @param rowSize The number of values per vertex in the vertex buffer.
		 * @param shaderKey The key to look up or cache the shader by. Uses the fully qualified class name if null.
		 */
		public function AxModel(x:Number, y:Number, vertexShader:Array, fragmentShader:Array, rowSize:uint, shaderKey:* = null) {
			super(x, y);

			shader = AxCache.shader(shaderKey ? shaderKey : this, vertexShader, fragmentShader, rowSize);
			matrix = new Matrix3D;
			colorTransform = new Vector.<Number>(4, true);
			color(1, 1, 1, 1);
			scale = new AxPoint(1, 1);
			pivot = new Vector3D;
			scroll = new AxPoint(1, 1);
			zooms = true;
			countTris = true;
		}

		/**
		 * Sets the color of this object. The color is applies multiplicatively. If the alpha is not passed, does
		 * not change the alpha.
		 *
		 * @param red The red value to use, between 0 and 1.
		 * @param green The green value to use, between 0 and 1.
		 * @param blue The blue value to use, between 0 and 1.
		 * @param alpha The alpha to use, between 0 and 1.
		 *
		 */
		public function color(red:Number, green:Number, blue:Number, alpha:Number = -1):void {
			colorTransform[RED] = red;
			colorTransform[GREEN] = green;
			colorTransform[BLUE] = blue;
			if (alpha != -1) {
				colorTransform[ALPHA] = alpha;
			}
		}
		
		override public function dispose():void {
			vertexShader = null;
			fragmentShader = null;
			indexData = null;
			indexBuffer = null;
			vertexData = null;
			vertexBuffer = null;
			shader = null;
			matrix = null;
			colorTransform = null;
			texture = null;
			super.dispose();
		}

		/** Constant defining the red offset into the <code>colorTransform</code> matrix. */
		protected static const RED:uint = 0;
		/** Constant defining the green offset into the <code>colorTransform</code> matrix. */
		protected static const GREEN:uint = 1;
		/** Constant defining the blue offset into the <code>colorTransform</code> matrix. */
		protected static const BLUE:uint = 2;
		/** Constant defining the alpha offset into the <code>colorTransform</code> matrix. */
		protected static const ALPHA:uint = 3;
	}
}
