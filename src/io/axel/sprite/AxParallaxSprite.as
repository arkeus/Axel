package io.axel.sprite {
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.geom.Vector3D;
	
	import io.axel.render.AxQuad;
	import io.axel.util.AxCache;
	import io.axel.Ax;
	import io.axel.AxModel;
	import io.axel.AxU;

	public class AxParallaxSprite extends AxModel {
		public static const NONE:uint = 0;
		public static const HORIZONTAL:uint = 1;
		public static const VERTICAL:uint = 2;
		public static const BOTH:uint = 3;
		
		public var quad:AxQuad;
		public var parallaxMode:uint;
		
		protected var uvParams:Vector.<Number>;
		
		public function AxParallaxSprite(x:Number, y:Number, graphic:*) {
			super(x, y, VERTEX_SHADER, FRAGMENT_SHADER, 4, "AxParallaxSprite");
			load(graphic);
			parallaxMode = BOTH;
		}
		
		private function load(graphic:*):void {
			texture = AxCache.texture(graphic);
			var uvWidth:Number = texture.rawWidth / texture.width;
			var uvHeight:Number = texture.rawHeight / texture.height;
			vertexBuffer = AxCache.vertexBuffer(texture.rawWidth, texture.rawHeight, uvWidth, uvHeight);
			indexBuffer = SPRITE_INDEX_BUFFER;
			uvParams = new Vector.<Number>(4, true); // [uvOffset.x, uvOffset.y, uvWidth, uvHeight]
			uvParams[2] = uvWidth;
			uvParams[3] = uvHeight;
			triangles = 2;
		}
		
		override public function update():void {
			super.update();
		}
		
		override public function draw():void {
			if (indexBuffer == null) {
				if (SPRITE_INDEX_BUFFER == null) {
					SPRITE_INDEX_BUFFER = Ax.context.createIndexBuffer(6);
					SPRITE_INDEX_BUFFER.uploadFromVector(Vector.<uint>([0, 1, 2, 1, 2, 3]), 0, 6);
				}
				indexBuffer = SPRITE_INDEX_BUFFER;
			}
			
			colorTransform[RED] = color.red;
			colorTransform[GREEN] = color.green;
			colorTransform[BLUE] = color.blue;
			colorTransform[ALPHA] = color.alpha;
			
			matrix.identity();
			
			if (angle != 0) {
				matrix.appendRotation(angle, Vector3D.Z_AXIS, pivot);
			}
			
			var sx:Number = x - offset.x + parentOffset.x;
			var sy:Number = y - offset.y + parentOffset.y;
			var scalex:Number = scale.x;
			var scaley:Number = scale.y;
			var cx:Number = (Ax.camera.position.x + Ax.camera.effectOffset.x) * ((parallaxMode & HORIZONTAL) ? 0 : scroll.x);
			var cy:Number = (Ax.camera.position.y + Ax.camera.effectOffset.y) * ((parallaxMode & VERTICAL) ? 0 : scroll.y);
			
			matrix.appendTranslation(Math.round(sx - cx + AxU.EPSILON), Math.round(sy - cy + AxU.EPSILON), 0);
			matrix.append(zooms ? Ax.camera.projection : Ax.camera.baseProjection);
			
			if (shader != Ax.shader) {
				Ax.context.setProgram(shader.program);
				Ax.shader = shader;
			}
			
			uvParams[0] = (parallaxMode & HORIZONTAL) ? (Ax.camera.position.x + Ax.camera.effectOffset.x) / texture.width * scroll.x : 0;
			uvParams[1] = (parallaxMode & VERTICAL) ? (Ax.camera.position.y + Ax.camera.effectOffset.y) / texture.height * scroll.y : 0;
			
			if (blend == null) {
				Ax.context.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			} else {
				Ax.context.setBlendFactors(blend.source, blend.destination);
			}
			
			Ax.context.setTextureAt(0, texture.texture);
			Ax.context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, matrix, true);
			Ax.context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, uvParams);
			Ax.context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, colorTransform);
			Ax.context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 4, uvParams);
			Ax.context.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
			Ax.context.setVertexBufferAt(1, vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_2);
			Ax.context.drawTriangles(indexBuffer, 0, triangles);
			Ax.context.setTextureAt(0, null);
			Ax.context.setVertexBufferAt(0, null, 0, Context3DVertexBufferFormat.FLOAT_2);
			Ax.context.setVertexBufferAt(1, null, 2, Context3DVertexBufferFormat.FLOAT_2);
			
			if (countTris) {
				Ax.debugger.tris += triangles;
			}
		}
		
		/**
		 * The parallax vertex shader for this sprite.
		 */
		private static const VERTEX_SHADER:Array = [
			"add v0.xyzw, va1.xyxy, vc4.xyxy",
			"m44 op, va0, vc0",
		];
		
		/**
		 * The parallax fragment shader for this sprite.
		 */
		private static const FRAGMENT_SHADER:Array = [
			"div ft0.xyxy, v0.xyxy, fc4.zwzw",
			"frc ft0.xyzw, ft0.xyxy",
			"mul ft0.xyxy, ft.xyxy, fc4.zwzw",
			"tex ft0, ft0, fs0 <2d,repeat,nearest>",
			"mul oc, fc0, ft0"
		];
		
		/**
		 * A static sprite index buffer that all AxParallaxSprites will use.
		 */
		public static var SPRITE_INDEX_BUFFER:IndexBuffer3D;
	}
}
