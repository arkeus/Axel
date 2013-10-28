package org.axgl.camera.effect {
	import org.axgl.Ax;
	import org.axgl.camera.AxCamera;

	/**
	 * A class containing the common logic between camera effects.
	 */
	public class AxCameraEffect {
		/** Whether or not this effect is currently active. */
		public var active:Boolean;
		
		/** The total duration of this effect. */
		protected var duration:Number;
		/** The remaining duration of this effect. */
		protected var remaining:Number;
		/** The callback for this effect, to be called once this effect completes. */
		protected var callback:Function;
		
		public function AxCameraEffect() {
			this.active = false;
			this.duration = 0;
			this.callback = null;
		}
		
		/**
		 * Initializes the camera effect.
		 * 
		 * @param duration The duration of the effect.
		 * @param callback The callback to be called upon completion.
		 */		 
		public function initialize(duration:Number, callback:Function):void {
			this.duration = duration;
			this.remaining = duration;
			this.callback = callback;
			this.active = true;
		}
		
		/**
		 * Updates the effect every frame, handles duration and completion.
		 * 
		 * @param camera The camera this effect is affecting.
		 */		
		public function update(camera:AxCamera):void {
			remaining -= Ax.dt;
			if (remaining <= 0) {
				deactivate();
			}
		}
		
		/**
		 * Completes this effect, setting it to be inactive and calling the callback if there is one.
		 */		
		public function deactivate():void {
			active = false;
			if (callback != null) {
				callback();
			}
		}
	}
}
