package io.axel.sprite {
	import flash.display.BitmapData;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import io.axel.Ax;
	import io.axel.base.AxCloud;
	import io.axel.base.AxEntity;
	import io.axel.base.AxGroup;
	import io.axel.base.AxModel;
	import io.axel.base.AxPoint;
	import io.axel.base.AxRect;
	import io.axel.AxU;
	import io.axel.render.AxTexture;
	import io.axel.resource.AxResource;
	import io.axel.sprite.effect.AxSpriteEffectSet;
	import io.axel.util.AxCache;

	/**
	 * An <code>AxSprite</code> is the entity that makes up most game objects. You can load an image, rotate it, change
	 * the color, move it, and more. Game objects that will be visible on screen should extend this class.
	 */
	public class AxSprite extends AxModel {
		/** The set of animations, used for adding and playing animations on the sprite. */
		public var animations:AxAnimationSet;
		
		/**
		 * The x and y coordinations of this sprite on the screen. A sprite in the upper left corner of the screen
		 * will have coordinates 0, 0 -- regardless of where the camera is currently at. 
		 */
		public var screen:AxPoint;
		
		/**
		 * The container holding the effects for this sprite.
		 */
		public var effects:AxSpriteEffectSet;

		/**
		 * The direction this sprite is facing. If <code>facing</code> is equal to <code>flip</code>, the sprite
		 * will be flipped horizontally. Set <code>flip</code> to <code>NONE</code> to disable this behavior. If
		 * facing is equal to flip, the origin of scaling will be overriden to be the center of your sprite, regardless
		 * of the current value of origin.
		 * 
		 * @default RIGHT
		 */
		public var facing:uint = RIGHT;
		
		/**
		 * The direction that causes this sprite to be flipped horizontally.
		 * 
		 * @default LEFT
		 * 
		 * @see #facing
		 */
		public var flip:uint = LEFT;

		/**
		 * Creates a new sprite at the given position. Loads the image in graphic using the given frameWidth and frameHeight. If
		 * frameWidth or frameHeight are 0, then the entire image is treated as a single frame. If you do not pass a graphic here,
		 * you should call <code>load</code> with your graphic, otherwise it will use the default Axel logo as the sprite.
		 * 
		 * @param x The initial x value of this sprite.
		 * @param y The initial y value of this sprite.
		 * @param graphic The embedded graphic to use for this sprite.
		 * @param frameWidth The width of each frame in the embedded graphic.
		 * @param frameHeight The height of each frame in the embedded graphic.
		 */
		public function AxSprite(x:Number = 0, y:Number = 0, graphic:Class = null, frameWidth:uint = 0, frameHeight:uint = 0) {
			super(x, y, VERTEX_SHADER, FRAGMENT_SHADER, 4, "AxSprite");

			animations = new AxAnimationSet;
			matrix = new Matrix3D;
			scale = new AxPoint(1, 1);
			colorTransform.fixed = true;
			
			screen = new AxPoint(x - (Ax.camera.x + Ax.camera.offset.x) * scroll.x, y - (Ax.camera.y + Ax.camera.offset.y) * scroll.y);
			effects = new AxSpriteEffectSet(this);

			if (graphic != null) {
				load(graphic, frameWidth, frameHeight);
			}
		}

		/**
		 * Loads a new graphic for this sprite with the specified frame width and height. The graphic can be one of:
		 * class (embedded graphic), an instance of BitmapData, or an AxTexture.
		 * 
		 * @param graphic The graphic to load for this sprite.
		 * @param frameWidth The width of each frame in the graphic.
		 * @param frameHeight The height of each frame in the graphic.
		 *
		 * @return The sprite instance.
		 */
		public function load(graphic:*, frameWidth:uint = 0, frameHeight:uint = 0):AxSprite {
			loadTexture(graphic, frameWidth, frameHeight);
			width = animations.frameWidth;
			height = animations.frameHeight;
			pivot.x = width / 2;
			pivot.y = height / 2;
			buildVertexBuffer(width, height, width / texture.width, height / texture.height);
			return this;
		}
		
		/**
		 * Creates a new graphic for this sprite, filling it with a single color. Use this to create solid colored square
		 * graphics quickly and easily. Color should include alpha and be in the format 0xAARRGGBB.
		 * 
		 * @param width Width of the sprite.
		 * @param height Height of the sprite.
		 * @param color Color of the sprite, including alpha, in the foramt 0xAARRGGBB.
		 *
		 * @return The sprite instance.
		 */
		public function create(width:uint, height:uint, color:uint = 0xff000000):AxSprite {
			var bitmap:BitmapData = new BitmapData(width, height, true, color);
			return load(bitmap, width, height);
		}

		/**
		 * Sets the bounding box for this sprite. This is a helpfer method to set the width, height, and offset values
		 * all at once.
		 * 
		 * <p>If an entity is loaded with an image that is 100x100, you can use <code>offset, width, and height</code> to
		 * change the bounding box that will affect collisions. The width and height determine the size of the bounding box,
		 * and offset determines how far to the right and down the upper left corner of the bounding box is.</p>
		 * 
		 * @param width The width of the bounding box.
		 * @param height The height of the bounding box.
		 * @param offsetX The x offset of the bounding box.
		 * @param offsetY The y offset of the bounding box.
		 *
		 * @return The instance of this sprite.
		 */
		public function bounds(width:uint, height:uint, offsetX:int, offsetY:int):AxSprite {
			this.width = width;
			this.height = height;
			this.offset.x = offsetX;
			this.offset.y = offsetY;
			return this;
		}

		/**
		 * Calculates the texture for the passed graphic. If the same graphic was used to create a texture, pulls it from the
		 * cache. Otherwise, creates a new texture and uploads it to the GPU. Note that that performance reasons, you should
		 * always upload a graphic whose dimensions are a multiple of 2 (eg. 128x64). If you don't, the graphic must be copied
		 * to a temporary bitmap that is a power of 2, before being converted to a texture.
		 * 
		 * @param graphic The graphic to create the texture from.
		 */
		private function loadTexture(graphic:*, frameWidth:uint, frameHeight:uint):void {
			texture = graphic is AxTexture ? graphic : AxCache.texture(graphic);
			animations.setDimensionsFromTexture(texture, frameWidth, frameHeight);
		}

		/**
		 * Tells this sprite to immediately start playing the animation that you passed. If that animation is already playing,
		 * this call will do nothing. If you want to stop the animation and instead show a static frame, use the <code>show</code>
		 * method instead.
		 * 
		 * @param name The name of the animation to play.
		 * @param reset Whether or not to force reset the animation from scratch.
		 *
		 * @return The sprite instance.
		 */
		public function animate(name:String, reset:Boolean = false):AxSprite {
			animations.play(name, reset);
			return this;
		}
		
		/**
		 * Stops the current animation (if one is playing), and tells the sprite to show a static frame. That frame does
		 * not need to be part of any animation.
		 * 
		 * @param frame The frame that should show.
		 *
		 * @return The sprite instance.
		 */
		public function show(frame:uint):AxSprite {
			animations.show(frame);
			return this;
		}
		
		/**
		 * Returns the current frame being shown. If we're showing an animation, it will be the frame being shown and not
		 * the offset into the animation's frames. If you want to know which frame of the animation is playing (eg. the
		 * second animation frame) then use frameOffset.
		 * 
		 * @return The overall frame being shown for this sprite.
		 */
		public function get frame():uint {
			return animations.current == null ? animations.frame : animations.current.frames[animations.frame];
		}
		
		/**
		 * Helper function allowing you to set a frame for this sprite. Simply calls show(frame).
		 * 
		 * @param frameNumber The frame to show (will stop any currently playing animation).
		 */
		public function set frame(frameNumber:uint):void {
			show(frameNumber);
		}
		
		/**
		 * Returns the offset into the current animation being shown. If no animation is being shown, this is the overall
		 * frame in the texture. If an animation is being shown, this is the offset into the list of frames for that animation.
		 * If the animation contains the frames [10, 11, 12] and it was currently on 11, this would return 1, since it's the
		 * second frame of the animation (zero indexed).
		 * 
		 * @return The offset into the animation being played.
		 */
		public function get frameOffset():uint {
			return animations.frame;
		}

		/**
		 * @inheritDoc
		 */
		override public function get left():Number {
			return x;
		}

		/**
		 * @inheritDoc
		 */
		override public function get top():Number {
			return y;
		}

		/**
		 * @inheritDoc
		 */
		override public function get right():Number {
			return x + width * scale.x;
		}

		/**
		 * @inheritDoc
		 */
		override public function get bottom():Number {
			return y + height * scale.y;
		}

		/**
		 * @inheritDoc
		 */
		override public function update():void {
			super.update();

			screen.x = x - (Ax.camera.x + Ax.camera.offset.x) * scroll.x;
			screen.y = y - (Ax.camera.y + Ax.camera.offset.y) * scroll.y;
			
			if (texture == null) {
				load(AxResource.ICON);
			}
			
			effects.update();
			animations.advance(Ax.dt);
		}

		/**
		 * Builds a vertex buffer for the given quad.
		 * 
		 * @param quad The quad defining the vertexes for which to build the vertex buffer.
		 */
		private function buildVertexBuffer(width:uint, height:uint, uvWidth:Number, uvHeight:Number):void {
			if (indexBuffer == null) {
				if (SPRITE_INDEX_BUFFER == null) {
					SPRITE_INDEX_BUFFER = Ax.context.createIndexBuffer(6);
					SPRITE_INDEX_BUFFER.uploadFromVector(Vector.<uint>([0, 1, 2, 1, 2, 3]), 0, 6);
				}
				indexBuffer = SPRITE_INDEX_BUFFER;
			}

			vertexBuffer = AxCache.vertexBuffer(width, height, uvWidth, uvHeight);
			triangles = 2;
		}

		/**
		 * @inheritDoc
		 */
		override public function draw():void {
			if (indexBuffer == null || (zooms && ((screen.x - offset.x) > Ax.viewWidth || (screen.y - offset.y) > Ax.viewHeight || screen.x + animations.frameWidth < 0 || screen.y + animations.frameHeight < 0)) || scale.x == 0 || scale.y == 0) {
				return;
			}
			
			colorTransform[RED] = color.red;
			colorTransform[GREEN] = color.green;
			colorTransform[BLUE] = color.blue;
			colorTransform[ALPHA] = color.alpha * parentEntityAlpha;

			matrix.identity();

			if (angle != 0) {
				matrix.appendRotation(angle, Vector3D.Z_AXIS, pivot);
			}

			var sx:Number = x - offset.x + parentOffset.x;
			var sy:Number = y - offset.y + parentOffset.y;
			var scalex:Number = scale.x;
			var scaley:Number = scale.y;
			var cx:Number = Ax.camera.position.x * scroll.x + Ax.camera.effectOffset.x;
			var cy:Number = Ax.camera.position.y * scroll.y + Ax.camera.effectOffset.y;
			if (facing == flip) {
				matrix.appendScale(scalex * -1, scaley, 1);
				matrix.appendTranslation(Math.round(sx - cx + AxU.EPSILON + animations.frameWidth), Math.round(sy - cy + AxU.EPSILON), 0);
			} else if (scalex != 1 || scaley != 1) {
				matrix.appendTranslation(-origin.x, -origin.y, 0);
				matrix.appendScale(scalex, scaley, 1);
				matrix.appendTranslation(origin.x + Math.round(sx - cx + AxU.EPSILON), origin.y + Math.round(sy - cy + AxU.EPSILON), 0);
			} else {
				matrix.appendTranslation(Math.round(sx - cx + AxU.EPSILON), Math.round(sy - cy + AxU.EPSILON), 0);
			}
			
			matrix.append(zooms ? Ax.camera.projection : Ax.camera.baseProjection);

			if (shader != Ax.shader) {
				Ax.context.setProgram(shader.program);
				Ax.shader = shader;
			}
			
			if (blend == null) {
				Ax.context.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			} else {
				Ax.context.setBlendFactors(blend.source, blend.destination);
			}
			
			Ax.context.setTextureAt(0, texture.texture);
			Ax.context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, matrix, true);
			Ax.context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, animations.uvOffset);
			Ax.context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, colorTransform);
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
		 * @inheritDoc
		 */
		override public function overlaps(other:AxRect):Boolean {
			if (!exists) {
				return false;
			}
			
			var overlapFound:Boolean = false;
			if (other is AxGroup) {
				var objects:Vector.<AxEntity> = (other as AxGroup).members;
				for each (var o:AxEntity in objects) {
					if (o.exists && overlaps(o)) {
						overlapFound = true;
					}
				}
			} else if (other is AxCloud) {
				var sprites:Vector.<AxSprite> = (other as AxCloud).members as Vector.<AxSprite>;
				for each (var s:AxSprite in sprites) {
					if (s.exists && overlaps(s)) {
						overlapFound = true;
					}
				}
			} else if (other != null) {
				overlapFound = super.overlaps(other);
			}
			return overlapFound;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void {
			screen = null;
			animations.dispose();
			animations = null;
			color = null;
			effects.dispose();
			effects = null;
			super.dispose();
		}

		/**
		 * The vertex shader for this sprite.
		 */
		private static const VERTEX_SHADER:Array = [
			"m44 vt0, va0, vc0",
			"add v0, va1, vc4",
			"mov op, vt0"
		];

		/**
		 * The fragment shader for this sprite.
		 */
		private static const FRAGMENT_SHADER:Array = [
			"tex ft0, v0, fs0 <2d,nearest,mipnone>",
			"mul oc, fc0, ft0"
		];

		/**
		 * A static sprite index buffer that all AxSprites will use.
		 */
		public static var SPRITE_INDEX_BUFFER:IndexBuffer3D;
	}
}
