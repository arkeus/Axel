package org.axgl.effect.sprite {
	import org.axgl.Ax;
	import org.axgl.AxU;
	
	public class AxScaleSpriteEffect extends AxSpriteEffect {
		private var targetXScale:Number;
		private var targetYScale:Number;
		private var deltaX:Number;
		private var deltaY:Number;
		
		public function AxScaleSpriteEffect(duration:Number, callback:Function, targetXScale:Number, targetYScale:Number) {
			super(duration, callback);
			this.targetXScale = targetXScale;
			this.targetYScale = targetYScale;
		}
		
		override public function create():void {
			deltaX = (targetXScale - sprite.scale.x) / duration;
			deltaY = (targetYScale - sprite.scale.y) / duration;
			super.create();
		}
		
		override public function update():void {
			sprite.scale.x += deltaX * Ax.dt;
			if ((deltaX < 0 && sprite.scale.x <= targetXScale) || (deltaX > 0 && sprite.scale.x >= targetXScale)) {
				sprite.scale.x = targetXScale;
				deltaX = 0;
			}
			
			sprite.scale.y += deltaY * Ax.dt;
			if ((deltaY < 0 && sprite.scale.y <= targetYScale) || (deltaY > 0 && sprite.scale.y >= targetYScale)) {
				sprite.scale.y = targetYScale;
				deltaY = 0;
			}
			
			if (deltaX == 0 && deltaY == 0){
				destroy();
			}
		}
		
		override public function destroy():void {
			super.destroy();
		}
	}
}
