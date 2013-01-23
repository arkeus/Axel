package org.axgl.camera {
	import com.adobe.utils.PerspectiveMatrix3D;
	
	import flash.geom.Matrix3D;
	
	import org.axgl.Ax;
	import org.axgl.AxEntity;
	import org.axgl.AxPoint;
	import org.axgl.AxRect;
	import org.axgl.AxSprite;
	import org.axgl.AxU;
	import org.axgl.camera.effect.AxCameraFadeEffect;
	import org.axgl.camera.effect.AxCameraShakeEffect;

	/**
	 * The basic camera that determines what is visible on the screen. The camera also acts as a visible
	 * sprite for effects such as fade and flash.
	 */
	public class AxCamera extends AxEntity {
		public static const HORIZONTAL:uint = 1;
		public static const VERTICAL:uint = 2;
		public static const BOTH_AXES:uint = 3;
		
		/**
		 * The target that the camera is following, null if none.
		 */
		public var target:AxEntity;
		/**
		 * The bounds determining where the camera can move in the world.
		 */
		public var bounds:AxRect;
		/**
		 * The calculated position of the camera, taking into account offsets and effects.
		 */
		public var position:AxPoint;
		/**
		 * Padding to be used when following an object. The padding defines a rectangle where the
		 * followed target is allowed to move without affecting the camera. Once the target moves out
		 * of the padded zone, the camera will follow it.
		 */
		public var padding:AxRect;

		/**
		 * A temporary world view matrix.
		 */
		public var view:PerspectiveMatrix3D;
		/**
		 * The projection matrix to transform an object into screen space.
		 */
		public var projection:Matrix3D;
		/**
		 * The project matrix to transform an object into screen space at 1x zoom.
		 */
		public var baseProjection:Matrix3D;
		
		/**
		 * A class containing all the information on the active shake effect.
		 */
		private var shakeEffect:AxCameraShakeEffect;
		/**
		 * A class containing all the information on the active fade effect.
		 */
		private var fadeEffect:AxCameraFadeEffect;
		/**
		 * The sprite used for camera fade effects.
		 */
		public var sprite:AxSprite;

		/**
		 * Creates a new camera.
		 */
		public function AxCamera() {
			super();
			bounds = new AxRect;
			bounds.x = Number.NEGATIVE_INFINITY;
			bounds.y = Number.NEGATIVE_INFINITY;
			bounds.width = Number.POSITIVE_INFINITY;
			bounds.height = Number.POSITIVE_INFINITY;
			
			position = new AxPoint;

			projection = new Matrix3D;
			view = new PerspectiveMatrix3D;
			baseProjection = new Matrix3D;
			
			shakeEffect = new AxCameraShakeEffect;
			fadeEffect = new AxCameraFadeEffect;

			calculateZoomMatrix();
			calculateProjectionMatrix(baseProjection, 1);
			
			sprite = new AxSprite().create(Ax.viewWidth, Ax.viewHeight, 0xffffffff);
			sprite.alpha = 0;
		}

		/**
		 * Tells the camera to begin following the passed entity.
		 * 
		 * @param target The entity to follow.
		 */
		public function follow(target:AxEntity, padding:AxRect = null):void {
			this.target = target;
			this.padding = padding;
		}

		/**
		 * Updates the camera's coordinates if it is following an entity.
		 */
		override public function update():void {
			if (target != null) {
				if (padding == null) {
					x = (target.x + (target.width - Ax.viewWidth) / 2);
					y = (target.y + (target.height - Ax.viewHeight) / 2);
				} else {
					if (x + padding.x > target.x) {
						x = target.x - padding.x;
					} else if (x + padding.x + padding.width < target.x + target.width) {
						x = target.x + target.width - padding.x - padding.width;
					}
					if (y + padding.y > target.y) {
						y = target.y - padding.y;
					} else if (y + padding.y + padding.height < target.y + target.height) {
						y = target.y + target.height - padding.y - padding.height;
					}
				}
			}
			
			x = AxU.clamp(x, bounds.x, bounds.width - Ax.viewWidth);
			y = AxU.clamp(y, bounds.y, bounds.height - Ax.viewHeight);
			
			if (shakeEffect.active) {
				shakeEffect.update(this);
			}
			if (fadeEffect.active) {
				fadeEffect.update(this);
			}
			
			position.x = x + offset.x + shakeEffect.x;
			position.y = y + offset.y + shakeEffect.y;
		}
		
		/**
		 * Draws the camera overlay effect.
		 */
		override public function draw():void {
			if (sprite.alpha > 0) {
				sprite.x = position.x;
				sprite.y = position.y;
				sprite.draw();
			}
		}
		
		/**
		 * Shakes the entire screen.
		 * 
		 * @param duration The duration, in seconds, to shake for.
		 * @param intensity The intensity of the shake (5 means to shake 5 pixels in each direction).
		 * @param callback The function to call when the effect completes (if any).
		 * @param ease Whether or not to ease the effect out upon completion (the shake gets smaller as it completes).
		 * @param axes The axes to shake (AxCamera.HORIZONTAL, AxCamera.VERTICAL, or AxCamera.BOTH_AXES).
		 */		
		public function shake(duration:Number, intensity:Number, callback:Function = null, ease:Boolean = false, axes:uint = BOTH_AXES):void {
			shakeEffect.shake(duration, intensity, callback, ease, axes);
		}
		
		/**
		 * Fades the entire screen to the passed color. AxCamera.fadeOut and AxCamera.fadeIn can be used to simplify this.
		 * 
		 * @param duration The duration of the fade effect.
		 * @param color The color, in 0xAARRGGBB format, to fade to.
		 * @param callback The function to call upon fade completion.
		 */		
		public function fade(duration:Number, color:uint, callback:Function = null):void {
			fadeEffect.fade(duration, color, this, callback);
		}
		
		/**
		 * Fades the screen out to the passed color. Can be used to fade out between state transition. For example:
		 * 
		 * <listing version="3.0">
		 * Ax.camera.fadeOut(1, 0xff000000, function():void {
		 * 		Ax.switchState(new NewState);
		 * 		Ax.camera.reset(); // optional
		 * 		Ax.camera.fadeIn();
		 * });
		 * </listing>
		 * 
		 * @param duration The duration of the fade effect.
		 * @param color The color, in 0xAARRGGBB format, to fade it.
		 * @param callback The function call upon fade completion.
		 */		
		public function fadeOut(duration:Number = 1, color:uint = 0xff000000, callback:Function = null):void {
			fade(duration, color, callback);
		}
		
		/**
		 * Fades the screen in. Identical to fading to 0x00ffffff. Can be used to fade out between state
		 * transition. For example:
		 * 
		 * <listing version="3.0">
		 * Ax.camera.fadeOut(1, 0xff000000, function():void {
		 * 		Ax.switchState(new NewState);
		 * 		Ax.camera.reset(); // optional
		 * 		Ax.camera.fadeIn();
		 * });
		 * </listing>
		 * 
		 * @param duration The duration of the fade effect.
		 * @param color The color, in 0xAARRGGBB format, to fade it.
		 * @param callback The function call upon fade completion.
		 */	
		public function fadeIn(duration:Number = 1, callback:Function = null):void {
			fade(duration, sprite.color.hex & 0xffffff, callback);
		}
		
		/**
		 * Resets the camera to the default position.
		 */
		public function reset():void {
			target = null;
			x = 0;
			y = 0;
		}

		/**
		 * Calculates the projection matrix based on the current zoom level.
		 */
		public function calculateZoomMatrix():void {
			calculateProjectionMatrix(projection, Ax.zoom);
			Ax.viewWidth = Ax.width / Ax.zoom;
			Ax.viewHeight = Ax.height / Ax.zoom;
		}

		/**
		 * Calculates a projection matrix based on the passed zoom, and stores it in the passed matrix.
		 * 
		 * @param matrix The matrix to place the result in.
		 * @param zoom The zoom level to calculate the projection matrix for.
		 */
		public function calculateProjectionMatrix(matrix:Matrix3D, zoom:Number):void {
			matrix.identity();
			// Flip the y axis so 0,0 is in the upper left like typical screen coordinates
			matrix.appendScale(zoom, -zoom, 1);
			// Move the origin to the bottom left
			matrix.appendTranslation(-Ax.width / 2, Ax.height / 2, 0);
			// Create an orthographic projection the same size as our screen
			view.identity();
			view.orthoLH(Ax.width, Ax.height, 0, 1);
			// Multiply the view by the world transformation
			matrix.append(view);
		}
	}
}
