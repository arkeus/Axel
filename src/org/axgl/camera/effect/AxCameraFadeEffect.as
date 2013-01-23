package org.axgl.camera.effect {
	import org.axgl.Ax;
	import org.axgl.AxU;
	import org.axgl.camera.AxCamera;
	import org.axgl.render.AxColor;

	/**
	 * A camera fade effect. Fades the entire screen to a color. Can be used to fade out the screen
	 * between state transitions, or for visual effects.
	 */
	public class AxCameraFadeEffect extends AxCameraEffect {
		/** The source color of the effect. */
		private var source:AxColor;
		/** The target color of the effect. */
		private var target:AxColor;
		
		/** How much the red channel of the overlay will change per second. */
		private var redDelta:Number = 0;
		/** How much the green channel of the overlay will change per second. */
		private var greenDelta:Number = 0;
		/** How much the blue channel of the overlay will change per second. */
		private var blueDelta:Number = 0;
		/** How much the alpha channel of the overlay will change per second. */
		private var alphaDelta:Number = 0;
		
		public function AxCameraFadeEffect() {
		}
		
		/**
		 * Fades the screen to the passed targetColor over duration seconds. Calls callback
		 * at the end, if not null.
		 * 
		 * @param duration The duration of the effect.
		 * @param targetColor The target color we are fading to.
		 * @param camera The camera we are affecting.
		 * @param callback The callback to call upon completion.
		 */		
		public function fade(duration:Number, targetColor:uint, camera:AxCamera, callback:Function):void {
			initialize(duration, callback);
			source = camera.sprite.color;
			target = AxColor.fromHex(targetColor);
			
			if (source.alpha == 0) {
				// If we're fading in from 0 alpha, you shouldn't notice the previous color
				redDelta = greenDelta = blueDelta = 0;
				camera.sprite.color.red = target.red;
				camera.sprite.color.green = target.green;
				camera.sprite.color.blue = target.blue;
			} else if (target.alpha == 0) {
				// If we're fading to 0 alpha, the color shouldn't change
				// TODO: Any use case to want to fade to a color as you fade out?
				redDelta = greenDelta = blueDelta = 0;
			} else {
				redDelta = (target.red - source.red) / duration;
				greenDelta = (target.green - source.green) / duration;
				blueDelta = (target.blue - source.blue) / duration;
			}
			
			alphaDelta = (target.alpha - source.alpha) / duration;
		}
		
		/**
		 * @inheritDoc
		 */ 
		override public function update(camera:AxCamera):void {
			camera.sprite.color.red += redDelta * Ax.dt;
			camera.sprite.color.green += greenDelta * Ax.dt;
			camera.sprite.color.blue += blueDelta * Ax.dt;
			camera.sprite.color.alpha += alphaDelta * Ax.dt;
			super.update(camera);
		}
	}
}
