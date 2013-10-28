package org.axgl.effect.sprite {
	public class AxFlashSpriteEffect extends AxSpriteEffect {
		/** The target color we're flashing the sprite as. */
		private var color:uint;
		/** The origin color of the sprite we'll return it to. */
		private var savedColor:uint;
		
		public function AxFlashSpriteEffect(duration:Number, callback:Function, color:uint) {
			super(duration, callback);
			this.color = color;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function create():void {
			savedColor = sprite.color.hex;
			sprite.color.hex = color;
			super.create();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function destroy():void {
			sprite.color.hex = savedColor;
			super.destroy();
		}
	}
}

