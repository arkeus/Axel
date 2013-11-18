package io.axel.sprite.effect {
	import io.axel.sprite.AxSprite;

	/**
	 * A class encapsulating the sprite effects for a single sprite.
	 */
	public class AxSpriteEffectSet {
		/** The list of effects currently active for this sprite. Will be null if no effects have been added. */
		public var effects:Vector.<AxSpriteEffect>;
		/** The internal flicker effect used for the startFlicker and stopFlicker functions. */
		private var flickerEffect:AxFlickerSpriteEffect;
		/** The internal alpha effect used for the fadeIn and fadeOut functions. */
		private var fadeEffect:AxAlphaSpriteEffect;
		/** The internal scale effect used for the grow function. */
		private var growEffect:AxScaleSpriteEffect;
		/** The internal flash effect used for the flash function. */
		private var flashEffect:AxFlashSpriteEffect;
		/** The sprite this effect set is to be applied to. */
		private var sprite:AxSprite;
		
		/**
		 * Creates a new set of effects for the given sprite.
		 */
		public function AxSpriteEffectSet(sprite:AxSprite) {
			this.sprite = sprite;
		}
		
		
		/**
		 * Updates all active effects on the sprite.
		 */
		public function update():void {
			if (effects != null) {
				for each(var effect:AxSpriteEffect in effects) {
					if (effect.active) {
						effect.update();
					}
				}
			}
		}
		
		/**
		 * Manually adds an effect to this sprites effect list. Used to add custom effects. When using
		 * built in effects, unless you know what you are doing, you typically want to use the
		 * corresponding function such as startFlicker().
		 * 
		 * @param effect The effect to add to the sprite.
		 * 
		 * @return The effect set.
		 */
		public function add(effect:AxSpriteEffect):AxSpriteEffectSet {
			if (effects == null) {
				effects = new Vector.<AxSpriteEffect>;
			}
			
			effect.setSprite(sprite);
			effect.create();
			effects.push(effect);
			return this;
		}
		
		/**
		 * Clears all effects from this sprite (if there are any). If skipCallback is false, it will
		 * trigger the callback that would typically finish when the effect completes.
		 * 
		 * @param skipCallback Whether to skip running the callback for each active effect or not.
		 * 
		 * @return The effect set.
		 */
		public function clear(skipCallback:Boolean = false):AxSpriteEffectSet {
			if (effects == null) {
				return this;
			}
			
			for each(var effect:AxSpriteEffect in effects) {
				if (effect.active) {
					if (skipCallback) {
						effect.active = false;
					} else {
						effect.destroy();
					}
				}
			}
			effects.length = 0;
			return this;
		}
		
		/**
		 * Starts flickering this sprite, and continues for <code>duration</code> seconds. When complete, if
		 * <code>callback</code> is not null, it will run the callback function. <code>Rate</code> determines
		 * how often the opacity changes (1 meaning once per frame, 2 meaning once every other frame, and so
		 * on). Type should be either AxFlickerSpriteEffect.BLINK, which means the sprite should blink back
		 * and forth from 0 to 1 opacity, or AxFlickerSpriteEffect.FLICKER, meaning the sprite will flicker
		 * at random opacities between 0.25 and 0.75.
		 * 
		 * @param duration How long to flicker for, in seconds.
		 * @param callback The callback to run when complete, if any.
		 * @param rate How many frames in between changing the opacity of the sprite.
		 * @param type Which type of flicker, either AxFlickerSpriteEffect.BLINK or AxFlickerSpriteEffect.FLICKER.
		 * 
		 * @return The effect set.
		 */
		public function startFlicker(duration:Number = 0, callback:Function = null, rate:uint = 1, type:uint = 0):AxSpriteEffectSet {
			if (flickerEffect != null && flickerEffect.active) {
				flickerEffect.destroy();
			}
			add(flickerEffect = new AxFlickerSpriteEffect(duration, callback, rate, type));
			return this;
		}
		
		/**
		 * Stops the sprite from flickering, if it is currently flickering.
		 * 
		 * @return The sprite.
		 */
		public function stopFlicker():AxSpriteEffectSet {
			if (flickerEffect != null) {
				flickerEffect.destroy();
			}
			return this;
		}
		
		/**
		 * Fades out the sprite to the specified opacity over the given duration. For example, if duration is 1
		 * and targetAlpha is 0, the sprite will fade out to be invisible over the course of 1 second. If a
		 * callback function is passed, it will be run on completion.
		 * 
		 * @param duration How long the fade effect should last, in seconds.
		 * @param targetAlpha The target alpha to fade to, default 0.
		 * @param callback The callback function to run when the fade is complete.
		 * 
		 * @return The effect set.
		 */
		public function fadeOut(duration:Number = 1, targetAlpha:Number = 0, callback:Function = null):AxSpriteEffectSet {
			if (fadeEffect != null && fadeEffect.active) {
				fadeEffect.destroy();
			}
			add(fadeEffect = new AxAlphaSpriteEffect(duration, callback, targetAlpha));
			return this;
		}
		
		/**
		 * Fades in the sprite to the specified opacity over the given duration. For example, if duration is 1
		 * and targetAlpha is 1, the sprite will fade out to be complete visible over the course of 1 second. If a
		 * callback function is passed, it will be run on completion.
		 * 
		 * @param duration How long the fade effect should last, in seconds.
		 * @param targetAlpha The target alpha to fade to, default 1.
		 * @param callback The callback function to run when the fade is complete.
		 * 
		 * @return The effect set.
		 */
		public function fadeIn(duration:Number = 1, targetAlpha:Number = 1, callback:Function = null):AxSpriteEffectSet {
			// todo: should this just alias fadeOut?
			if (fadeEffect != null && fadeEffect.active) {
				fadeEffect.destroy();
			}
			add(fadeEffect = new AxAlphaSpriteEffect(duration, callback, targetAlpha));
			return this;
		}
		
		/**
		 * Scales the sprite over the passed duration. For example, if duration is 1 and target x and y scale are 2,
		 * the sprite will grow to be twice the normal size over the course of 1 second. If a callback function is
		 * passed, it will be run on completion.
		 * 
		 * @param duration How long the grow effect should last, in seconds.
		 * @param targetXScale How big the x scale should be on completion of the effect.
		 * @param targetYScale How big the y scale should be on completion of the effect.
		 * @param callback The callback function to run when the grow is complete.
		 * 
		 * @return The effect set.
		 */
		public function grow(duration:Number = 1, targetXScale:Number = 2, targetYScale:Number = 2, callback:Function = null):AxSpriteEffectSet {
			if (growEffect != null && growEffect.active) {
				growEffect.destroy();
			}
			add(growEffect = new AxScaleSpriteEffect(duration, callback, targetXScale, targetYScale));
			return this;
		}
		
		/**
		 * Flashes the sprite to a given color for the passed duration. For example, if the duration is 1 and the color
		 * is 0xffff0000, the sprite's color will be set to red for 1 second. Color is in 0xAARRGGBB format. If a callback
		 * is passed, it will be run on completion.
		 * 
		 * @param duration How long the flash effect should last, in seconds.
		 * @param color What color the sprite should flash, in 0xAARRGGBB format.
		 * @param callback The callback function to run when the flash is complete.
		 * 
		 * @return The effect set.
		 */
		public function flash(duration:Number = 0.1, color:uint = 0xffff0000, callback:Function = null):AxSpriteEffectSet {
			if (flashEffect != null && flashEffect.active) {
				flashEffect.destroy();
			}
			add(flashEffect = new AxFlashSpriteEffect(duration, callback, color));
			return this;
		}
		
		/**
		 * Disposes of any resources used in this instance.
		 */
		public function dispose():void {
			if (effects != null) {
				effects.length = 0;
				effects = null;
			}
		}
	}
}
