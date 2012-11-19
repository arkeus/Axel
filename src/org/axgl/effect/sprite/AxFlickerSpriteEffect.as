package org.axgl.effect.sprite {
	public class AxFlickerSpriteEffect extends AxSpriteEffect {
		public static const BLINK:uint = 0;
		public static const FLICKER:uint = 1;
		
		private var savedAlpha:Number;
		private var rate:uint;
		private var rateCounter:int;
		private var type:uint;
		
		public function AxFlickerSpriteEffect(duration:Number, callback:Function, rate:uint, type:uint) {
			super(duration, callback);
			this.rate = this.rateCounter = rate;
			this.type = type;
		}
		
		override public function create():void {
			savedAlpha = sprite.alpha;
			super.create();
		}
		
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
		
		override public function destroy():void {
			sprite.alpha = savedAlpha;
			super.destroy();
		}
	}
}
