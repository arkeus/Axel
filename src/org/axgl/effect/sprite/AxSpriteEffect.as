package org.axgl.effect.sprite {
	import org.axgl.Ax;
	import org.axgl.AxSprite;

	/**
	 * A general class for holding common logic between sprite effects.
	 */
	public class AxSpriteEffect {
		/** Whether or not this sprite effect is active. */
		public var active:Boolean;
		
		/** The sprite that this effect is affecting. */
		protected var sprite:AxSprite;
		/** The duration of this effect. */
		protected var duration:Number;
		/** The callback to call once this effect completes. */
		protected var callback:Function;
		
		public function AxSpriteEffect(duration:Number, callback:Function) {
			this.duration = duration;
			this.callback = callback;
		}
		
		/**
		 * Initializes this effect.
		 */		
		public function create():void {
			this.active = true;
		}
		
		/**
		 * Updates this effect on each frame.
		 */
		public function update():void {
			if (duration > 0) {
				this.duration -= Ax.dt;
				if (duration <= 0) {
					destroy();
				}
			}
		}
		
		/**
		 * Destroys this effect, calling the callback if there is one.
		 */
		public function destroy():void {
			active = false;
			if (callback != null) {
				callback();
			}
		}
		
		/**
		 * Sets the sprite that this effect affects.
		 * 
		 * @param sprite The sprite that this effect will affect.
		 */
		public function setSprite(sprite:AxSprite):void {
			this.sprite = sprite;
		}
	}
}
