package org.axgl.effect.sprite {
	public class AxFlickerSpriteEffect extends AxSpriteEffect {
		/** A blink effect that causes the sprite to swap between 0 and 1 alpha. */
		public static const BLINK:uint = 0;
		/** A flicker effect that causes the sprite to flicker randomly between 0.25 and 0.75 alpha. */
		public static const FLICKER:uint = 1;
		
		/** The alpha before the effect started, used to restore upon completion. */
		private var savedAlpha:Number;
		/** The rate we're flickering. */
		private var rate:uint;
		/** A counter used to control our flicker rate. */
		private var rateCounter:int;
		/** The flicker type we're using, eg. BLINK or FLICKER. */
		private var type:uint;
		
		public function AxFlickerSpriteEffect(duration:Number, callback:Function, rate:uint, type:uint) {
			super(duration, callback);
			this.rate = this.rateCounter = rate;
			this.type = type;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function create():void {
			savedAlpha = sprite.alpha;
			super.create();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function update():void {
			rateCounter--;
			if (rateCounter <= 0) {
				if (type == BLINK) {
					sprite.alpha = sprite.alpha == 0 ? savedAlpha : 0;
				} else if (type == FLICKER) {
					sprite.alpha = Math.random() / 2 + 0.25;
				}
				super.update();
				rateCounter = rate;
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function destroy():void {
			sprite.alpha = savedAlpha;
			super.destroy();
		}
	}
}
