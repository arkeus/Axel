package io.axel.sprite {
	import io.axel.render.AxTexture;

	/**
	 * A class holding the animations for a single AxSprite.
	 */
	public class AxAnimationSet {
		/** The current animation this sprite is playing. */
		public var animation:AxAnimation;
		/** All registered animations of this set. This is a map from animation name to animation. */
		public var animations:Object;
		/** The current frame of the animation. If an animation is not currently playing, the currently showing frame. */
		public var frame:uint;
		/** Read-only. The delay between switching frames used to play the current animation. */
		public var animationDelay:Number;
		/** Read-only. The timer for playing the current animation. */
		public var animationTimer:Number;
		
		/** The number of frames per row in the loaded texture. */
		public var framesPerRow:uint;
		/** The width of the frame for this entity. */
		public var frameWidth:Number;
		/** The height of the frame for this entity. */
		public var frameHeight:Number;
		/** The width of the area in the texture used for these animations that the frame width maps to. */
		public var uvWidth:Number;
		/** The height of the area in the texture used for these animations that the frame height maps to. */
		public var uvHeight:Number;
		/** The location (in whatever texture is being used) where the current frame resides. */
		public var uvOffset:Vector.<Number>;
		
		public function AxAnimationSet() {
			animation = null;
			animations = {};
			frame = 0;
			animationDelay = 0;
			animationTimer = 0;
			
			framesPerRow = 0;
			frameWidth = 0;
			frameHeight = 0;
			uvOffset = new Vector.<Number>(4, true);
		}
		
		/**
		 * Given a texture, calculates the dimensions used in order to calculate the position of each frame for animations in this
		 * set. See <code>setDimensions</code> for more.
		 * 
		 * @param texture The AxTexture to be used to calculate frame dimensions.
		 */
		public function setDimensionsFromTexture(texture:AxTexture, frameWidth:uint = 0, frameHeight:uint = 0):void {
			if (frameWidth == 0 || frameHeight == 0) {
				this.frameWidth = texture.rawWidth;
				this.frameHeight = texture.rawHeight;
			} else {
				this.frameWidth = frameWidth;
				this.frameHeight = frameHeight;
			}
			this.uvWidth = this.frameWidth / texture.width;
			this.uvHeight = this.frameHeight / texture.height;
			framesPerRow = Math.max(1, Math.floor(texture.rawWidth / this.frameWidth));
		}
		
		/**
		 * Sets the dimensions that allow the animation set to calculate the exact position of the current frame that should be
		 * shown. Any sprite that shares these values could theoretically share the same animation set.
		 * 
		 * TODO: Allow sprites of the same type to share the same animation set.
		 * TODO: If we want to allow arbitrary animations anywhere in a texture these needs to be properties of the animation
		 * and not the animation set. Keeping here for now for simplicity.
		 * 
		 * @param framesPerRow The number of frames per row.
		 * @param frameWidth The width of each frame.
		 * @param frameHeight The height of each frame.
		 */
		public function setDimensions(framesPerRow:uint, frameWidth:Number, frameHeight:Number):void {
			this.framesPerRow = framesPerRow;
			this.frameWidth = frameWidth;
			this.frameHeight = frameHeight;
		}
		
		/**
		 * Adds a new animation to this set. The <code>name</code> of the animation is what you will use to access it via the <code>play</code>
		 * function. The <code>frames</code> is an array that lists the frames of the animation in the order they will play. <code>Framerate</code> is
		 * how fast the animation will play; it indicates how many frames will be played per second. If you have a 5 frame animation with a
		 * framerate of 10, it will play the animation twice per second. The <code>looped</code> parameter indicates whether or not this
		 * animation should stop at the end of the animation, or if it should loop repeatedly.
		 * 
		 * @param name The name of the animation.
		 * @param frames The array of frames that make up the animation.
		 * @param framerate The framerate at which the animation should play.
		 * @param looped Whether or not the animation should loop.
		 *
		 * @return The animation set.
		 */
		public function add(name:String, frames:Array, framerate:uint = 15, looped:Boolean = true, callback:Function = null):AxAnimationSet {
			animations[name] = new AxAnimation(name, frames, framerate < 1 ? 15 : framerate, looped, callback);
			return this;
		}
		
		/**
		 * Tells this set to immediately start playing the animation that you passed. If that animation is already playing,
		 * this call will do nothing. If you want to stop the animation and instead show a static frame, use the <code>show</code>
		 * method on AxSprite instead.
		 * 
		 * @param name The name of the animation to play.
		 * @param reset Whether or not to force reset the animation from scratch.
		 */
		public function play(name:String, reset:Boolean = false):void {
			if ((reset || animation == null || (animation != null && animation.name != name)) && animations[name] != null) {
				animation = animations[name];
				animationDelay = 1 / animation.framerate;
				animationTimer = animationDelay;
				frame = 0;
			}
		}
		
		/**
		 * Stops the current animation (if one is playing), and sets the frame to the passed frame.
		 * 
		 * @param frame The frame that should show.
		 */
		public function show(frame:uint):void {
			animation = null;
			this.frame = frame;
		}
		
		public function get current():AxAnimation {
			return animation;
		}
		
		/**
		 * Advances the animation set by the passed amount of time.
		 */
		public function advance(dt:Number):void {
			if (animation != null) {
				animationTimer += dt;
				while (animationTimer >= animationDelay) {
					animationTimer -= animationDelay;
					if (frame + 1 < animation.frames.length || animation.looped) {
						frame = (frame + 1) % animation.frames.length;
					}
					uvOffset[0] = (animation.frames[frame] % framesPerRow) * uvWidth;
					uvOffset[1] = Math.floor(animation.frames[frame] / framesPerRow) * uvHeight;
					if (frame + 1 == animation.frames.length && animation.callback != null) {
						animation.callback();
					}
				}
			} else {
				uvOffset[0] = (frame % framesPerRow) * uvWidth;
				uvOffset[1] = Math.floor(frame / framesPerRow) * uvHeight;
			}
		}
		
		/**
		 * Gets an animation by name.
		 * 
		 * @param name The name of the animation to get.
		 * 
		 * @return The animation with the given name, or null if none exists.
		 */
		public function get(name:String):AxAnimation {
			return animations[name];
		}
		
		/**
		 * Dispose the animation set.
		 */
		public function dispose():void {
			for (var animationName:String in animations) {
				animations[animationName].dispose();
			}
			animations = null;
			animation = null;
			uvOffset = null;
		}
	}
}
