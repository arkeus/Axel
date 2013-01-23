package org.axgl.effect.sprite {
	import org.axgl.Ax;
	import org.axgl.AxU;

	public class AxAlphaSpriteEffect extends AxSpriteEffect {
		/** The target alpha we're fading to. */
		private var targetAlpha:Number;
		/** The amount the alpha will change per second. */
		private var delta:Number;
		
		public function AxAlphaSpriteEffect(duration:Number, callback:Function, targetAlpha:Number) {
			super(duration, callback);
			this.targetAlpha = targetAlpha;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function create():void {
			delta = (targetAlpha - sprite.alpha) / duration;
			super.create();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function update():void {
			sprite.alpha += delta * Ax.dt;
			if ((delta < 0 && sprite.alpha <= targetAlpha) || (delta > 0 && sprite.alpha >= targetAlpha)) {
				sprite.alpha = targetAlpha;
				destroy();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function destroy():void {
			super.destroy();
		}
	}
}
