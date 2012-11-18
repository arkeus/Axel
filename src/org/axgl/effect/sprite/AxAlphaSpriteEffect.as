package org.axgl.effect.sprite {
	import org.axgl.Ax;
	import org.axgl.AxU;

	public class AxAlphaSpriteEffect extends AxSpriteEffect {
		private var targetAlpha:Number;
		private var delta:Number;
		
		public function AxAlphaSpriteEffect(duration:Number, callback:Function, targetAlpha:Number) {
			super(duration, callback);
			this.targetAlpha = targetAlpha;
		}
		
		override public function create():void {
			delta = (targetAlpha - sprite.alpha) / duration;
			trace("delta", delta);
			super.create();
		}
		
		override public function update():void {
			sprite.alpha += delta * Ax.dt;
			trace(sprite.alpha);
			if ((delta < 0 && sprite.alpha <= targetAlpha) || (delta > 0 && sprite.alpha >= targetAlpha)) {
				sprite.alpha = targetAlpha;
				destroy();
			}
		}
		
		override public function destroy():void {
			super.destroy();
		}
	}
}
