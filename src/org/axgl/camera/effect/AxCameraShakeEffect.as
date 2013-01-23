package org.axgl.camera.effect {
	import org.axgl.AxU;
	import org.axgl.camera.AxCamera;

	/**
	 * A general shake effect, to the shake the entire screen for some duration.
	 */
	public class AxCameraShakeEffect extends AxCameraEffect {
		/** Current x offset to apply to the camera. */
		public var x:Number;
		/** Current y offset to apply to the camera. */
		public var y:Number;
		
		/** Which axes to affect. */
		private var axes:uint;
		/** Whether or not to ease out as you complete the effect. */
		private var ease:Boolean;
		/** The intensity of the shake. */
		private var intensity:Number;
		
		public function AxCameraShakeEffect() {
			this.x = 0;
			this.y = 0;
		}
		
		/**
		 * Shakes the entire screen.
		 * 
		 * @param duration The duration to shake for.
		 * @param intensity The intensity of the shake.
		 * @param callback The callback to call upon completion.
		 * @param ease Whether or not to ease the effect off as it completes.
		 * @param axes The axes to shake.
		 */		
		public function shake(duration:Number, intensity:Number, callback:Function, ease:Boolean, axes:uint):void {
			initialize(duration, callback);
			this.intensity = intensity;
			this.ease = ease;
			this.axes = axes;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function update(camera:AxCamera):void {
			if (axes & AxCamera.HORIZONTAL > 0) {
				x = AxU.randf(-intensity, intensity) * (ease ? remaining / duration : 1);
			}
			if (axes & AxCamera.VERTICAL > 0) {
				y = AxU.randf(-intensity, intensity) * (ease ? remaining / duration : 1);
			}
			
			super.update(camera);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function deactivate():void {
			x = y = 0;
			super.deactivate();
		}
	}
}
