package org.axgl.effect.sprite {
	import org.axgl.Ax;
	
	public class AxScaleSpriteEffect extends AxSpriteEffect {
		/** The target x scale. */
		private var targetXScale:Number;
		/** The target y scale. */
		private var targetYScale:Number;
		/** The amount we're changing the x scale per second. */
		private var deltaX:Number;
		/** The amount we're changing the y scale per second. */
		private var deltaY:Number;
		
		public function AxScaleSpriteEffect(duration:Number, callback:Function, targetXScale:Number, targetYScale:Number) {
			super(duration, callback);
			this.targetXScale = targetXScale;
			this.targetYScale = targetYScale;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function create():void {
			deltaX = (targetXScale - sprite.scale.x) / duration;
			deltaY = (targetYScale - sprite.scale.y) / duration;
			super.create();
		}
		
		/**
		 * @inheritDoc
		 */
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
		
		/**
		 * @inheritDoc
		 */
		override public function destroy():void {
			super.destroy();
		}
	}
}
