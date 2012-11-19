package org.axgl.effect.sprite {
	import org.axgl.Ax;
	import org.axgl.AxSprite;

	public class AxSpriteEffect {
		public var active:Boolean;
		
		protected var sprite:AxSprite;
		protected var duration:Number;
		protected var callback:Function;
		
		public function AxSpriteEffect(duration:Number, callback:Function) {
			this.duration = duration;
			this.callback = callback;
		}
		
		public function create():void {
			this.active = true;
		}
		
		public function update():void {
			if (duration > 0) {
				this.duration -= Ax.dt;
				if (duration <= 0) {
					destroy();
				}
			}
		}
		
		public function destroy():void {
			active = false;
			if (callback != null) {
				callback();
			}
		}
		
		public function setSprite(sprite:AxSprite):void {
			this.sprite = sprite;
		}
	}
}
