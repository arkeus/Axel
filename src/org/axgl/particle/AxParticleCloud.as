package org.axgl.particle {
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import org.axgl.Ax;
	import org.axgl.AxModel;
	import org.axgl.AxU;
	import org.axgl.util.AxCache;

	/**
	 * A drawable cloud of particles. All particles are batched together in a single call, and all
	 * physics such as velocity and acceleration are calculated on the GPU. Because of this, you can
	 * have thousands of particles rendering easily in real time on modern GPUs.
	 */
	public class AxParticleCloud extends AxModel {
		/**
		 * The effect containing all the settings for this particle cloud.
		 */
		protected var effect:AxParticleEffect;
		/**
		 * A temporary vector used to upload constants to the shaders without needing to create a new
		 * vector object every frame.
		 */
		protected var tempVector:Vector.<Number>;
		/**
		 * The amount of time elapsed since the birth of this effect. This is needed to calculate physical
		 * properties of each particle.
		 */
		public var time:Number;

		/**
		 * Creates a new particle cloud using a particle effect.
		 * 
		 * @param effect The effect that contains all the settings to use for this particle cloud.
		 */
		public function AxParticleCloud(effect:AxParticleEffect) {
			super(0, 0, VERTEX_SHADER, FRAGMENT_SHADER, 19);
			this.effect = effect;
			matrix = new Matrix3D;
			tempVector = new Vector.<Number>(4, true);
			time = 0;
			active = false;
			visible = false;
			scroll = effect.scroll;
		}

		/**
		 * Builds the necessary geometry required to draw this particle cloud.
		 *
		 * @return The particle cloud instance.
		 */
		public function build():AxParticleCloud {
			if (texture == null) {
				texture = AxCache.texture(effect.resource);
			}

			indexData = new Vector.<uint>;
			vertexData = new Vector.<Number>;
			
			var frameWidth:uint = effect.frameSize.x == 0 ? texture.rawWidth : effect.frameSize.x;
			var frameHeight:uint = effect.frameSize.y == 0 ? texture.rawHeight : effect.frameSize.y;
			var uvWidth:Number = frameWidth / texture.width;
			var uvHeight:Number = frameHeight / texture.height;
			var columns:uint = Math.floor(texture.rawWidth / frameWidth);
			var rows:uint = Math.floor(texture.rawHeight / frameHeight);
			var lastFrameIndex:uint = columns * rows - 1;

			for (var i:uint = 0; i < effect.amount; i++) {
				var index:uint = i * 4;
				var tx:int = AxU.rand(effect.x.min, effect.x.max);
				var ty:int = AxU.rand(effect.y.min, effect.y.max);
				
				var vx:Number = effect.xVelocity.randomNumber();
				var vy:Number = effect.yVelocity.randomNumber();
				var ax:Number = effect.xAcceleration.randomNumber();
				var ay:Number = effect.yAcceleration.randomNumber();
				var life:Number = effect.lifetime.randomNumber();
				var ssc:Number = effect.startScale.randomNumber();
				var esc:Number = effect.endScale.randomNumber();
				var csr:Number = effect.startColorRed.randomNumber();
				var csg:Number = effect.startColorGreen.randomNumber();
				var csb:Number = effect.startColorBlue.randomNumber();
				var csa:Number = effect.startAlpha.randomNumber();
				var cer:Number = effect.endColorRed.randomNumber();
				var ceg:Number = effect.endColorGreen.randomNumber();
				var ceb:Number = effect.endColorBlue.randomNumber();
				var cea:Number = effect.endAlpha.randomNumber();
				
				var frame:uint;
				if (effect.frameRange.min < 0 || effect.frameRange.max < 0) {
					frame = AxU.rand(0, lastFrameIndex); 
				} else {
					frame = effect.frameRange.randomInt();
				}
				
				var frameRow:uint = frame / columns;
				var frameCol:uint = frame % columns;
				var u:Number = frameCol * frameWidth / texture.width;
				var v:Number = frameRow * frameHeight / texture.height;
				
				indexData.push(index, index + 1, index + 2, index + 1, index + 2, index + 3);
				vertexData.push(
					tx, 				ty, 				u,				v,				vx, vy, ax, ay, ssc, esc, life, csr, csg, csb, csa, cer, ceg, ceb, cea,
					tx + frameWidth, 	ty, 				u + uvWidth,	v, 				vx, vy, ax, ay, ssc, esc, life, csr, csg, csb, csa, cer, ceg, ceb, cea,
					tx, 				ty + frameHeight, 	u, 				v + uvHeight, 	vx, vy, ax, ay, ssc, esc, life, csr, csg, csb, csa, cer, ceg, ceb, cea,
					tx + frameWidth, 	ty + frameHeight, 	u + uvWidth, 	v + uvHeight, 	vx, vy, ax, ay, ssc, esc, life, csr, csg, csb, csa, cer, ceg, ceb, cea
				);
			}

			var vertexLength:uint = vertexData.length / shader.rowSize;
			indexBuffer = Ax.context.createIndexBuffer(indexData.length);
			indexBuffer.uploadFromVector(indexData, 0, indexData.length);
			vertexBuffer = Ax.context.createVertexBuffer(vertexLength, shader.rowSize);
			vertexBuffer.uploadFromVector(vertexData, 0, vertexLength);
			triangles = indexData.length / 3;

			velocity.a = effect.aVelocity.randomNumber();

			return this;
		}

		override public function update():void {
			if (time > effect.lifetime.max) {
				destroy();
				return;
			}
			super.update();
			time += Ax.dt;
		}

		/**
		 * Moves the cloud to the passed location, and resets it so that it begins drawing the effect from the
		 * beginning.
		 * 
		 * @param x The x-coordinate in world space.
		 * @param y The y-coordinate in world space.
		 */
		public function reset(x:Number, y:Number):void {
			this.x = x;
			this.y = y;
			this.time = 0;
			this.active = true;
			this.visible = true;
			this.exists = true;
		}

		override public function draw():void {
			colorTransform[RED] = color.red;
			colorTransform[GREEN] = color.green;
			colorTransform[BLUE] = color.blue;
			colorTransform[ALPHA] = color.alpha;
			
			matrix.identity();
			matrix.appendRotation(angle, Vector3D.Z_AXIS, pivot);
			matrix.appendTranslation(x - Ax.camera.position.x * scroll.x, y - Ax.camera.position.y * scroll.y, 0);
			matrix.append(zooms ? Ax.camera.projection : Ax.camera.baseProjection);

			if (shader != Ax.shader) {
				Ax.context.setProgram(shader.program);
				Ax.shader = shader;
			}
			
			Ax.context.setTextureAt(0, texture.texture);
			Ax.context.setBlendFactors(effect.blend.source, effect.blend.destination);
			Ax.context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, matrix, true);

			tempVector[0] = time;
			tempVector[1] = time;
			tempVector[2] = time;
			tempVector[3] = time;
			Ax.context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, tempVector);

			tempVector[0] = 0.5 * time * time;
			tempVector[1] = tempVector[0];
			tempVector[2] = tempVector[0];
			tempVector[3] = tempVector[0];
			Ax.context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 5, tempVector);
			
			Ax.context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, colorTransform);
			Ax.context.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
			Ax.context.setVertexBufferAt(1, vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_2);
			Ax.context.setVertexBufferAt(2, vertexBuffer, 4, Context3DVertexBufferFormat.FLOAT_2);
			Ax.context.setVertexBufferAt(3, vertexBuffer, 6, Context3DVertexBufferFormat.FLOAT_2);
			Ax.context.setVertexBufferAt(4, vertexBuffer, 8, Context3DVertexBufferFormat.FLOAT_2);
			Ax.context.setVertexBufferAt(5, vertexBuffer, 10, Context3DVertexBufferFormat.FLOAT_1);
			Ax.context.setVertexBufferAt(6, vertexBuffer, 11, Context3DVertexBufferFormat.FLOAT_4);
			Ax.context.setVertexBufferAt(7, vertexBuffer, 15, Context3DVertexBufferFormat.FLOAT_4);
			Ax.context.drawTriangles(indexBuffer, 0, triangles);
			Ax.context.setVertexBufferAt(0, null, 0, Context3DVertexBufferFormat.FLOAT_2);
			Ax.context.setVertexBufferAt(1, null, 2, Context3DVertexBufferFormat.FLOAT_2);
			Ax.context.setVertexBufferAt(2, null, 4, Context3DVertexBufferFormat.FLOAT_2);
			Ax.context.setVertexBufferAt(3, null, 6, Context3DVertexBufferFormat.FLOAT_2);
			Ax.context.setVertexBufferAt(4, null, 8, Context3DVertexBufferFormat.FLOAT_1);
			Ax.context.setVertexBufferAt(5, null, 10, Context3DVertexBufferFormat.FLOAT_1);
			Ax.context.setVertexBufferAt(6, null, 10, Context3DVertexBufferFormat.FLOAT_4);
			Ax.context.setVertexBufferAt(7, null, 10, Context3DVertexBufferFormat.FLOAT_4);
			
			if (countTris) {
				Ax.debugger.tris += triangles;
			}
		}
		
		/**
		 * Clones this particle effect, creating a new instance that shares the texture, shadeder, and settings.
		 *
		 * @return The cloned particle cloud instance.
		 */
		public function clone():AxParticleCloud {
			var other:AxParticleCloud = new AxParticleCloud(effect);
			other.texture = texture;
			other.shader = shader;
			return other.build();
		}
		
		/**
		 * The vertex shader used to draw particle clouds. 
		 */
		public static const VERTEX_SHADER:Array = [
			// vc0-3 = global transform matrix
			// vc4 = time
			// vc5 = 0.5t^2
			// vc5 = progress (0 - 1)
			// va0 = x, y
			// va1 = u, v
			// va2 = vx, vy
			// va3 = ax, ay
			// va4 = start scale, end scale
			// va5 = lifetime
			// va6 = start color
			// va7 = end color
			"mov v1, 		va1", 					// copy uv to fragment shader
			"mov vt0, 		va0", 					// move x, y to vt0
			// use velocity to adjust position
			"mul vt1, 		va2, 		vc4",		// multiply velocity by time, vt1
			"add vt0.xy, 	vt0.xy,		vt1.xy", 	// add dx.xy to position.xy, vt0
			// use acceleration to adjust position
			"mul vt1,		va3,		vc5", 		// multiply acceleration by 0.5t^2, vt1
			"add vt0.xy,	vt0.xy,		vt1.xy", 	// add dx.xy to position.xy, vt0
			// calculate progress (0 - 1)
			"div vt2,		vc4,		va5", 		// divide time lived by lifetime
			"sat vt2,		vt2", 					// clamp between 0 and 1, vt2.x = progress
			// calculate scale
			"sub vt3.y,		va4.x,		va4.y", 	// find total amount scale should change, vt3.y
			"mul vt3.y,		vt3.y,		vt2.x", 	// multiply progress by scale change
			"mov vt3.z,		va4.x", 				// move start scale into vt3.z
			"sub vt3.z,		vt3.z, 		vt3.y", 	// subtract end scale from vt3.z
			"mul vt0.x,     vt0.x,		vt3.z", 	// multiply current scale by x
			"mul vt0.y,     vt0.y,		vt3.z", 	// multiply current scale by y
			// calculate color and alpha
			"sub vt4,		va6,		va7", 		// find how much each color component should change
			"mul vt4,		vt4,		vt2.xxxx", 	// find how much it has changed so far
			"sub v2,		va6,		vt4", 		// subtract how much it has changed from the start value to get current value
			// apply world transform
			"m44 op, 		vt0, 		vc0"	 	// multiply by global transformation
		];
		
		/**
		 * The fragment shader used to draw particle clouds.
		 */
		public static const FRAGMENT_SHADER:Array = [
			"tex ft0, v1, fs0 <2d,nearest,mipnone>",
			"mul oc, ft0, v2",
		];
	}
}
