package org.axgl.input {
	import flash.events.KeyboardEvent;
	
	import org.axgl.Ax;

	/**
	 * The keyboard object allowing you access to check which keys are being used.
	 */
	public class AxKeyboard extends AxInput {
		/**
		 * The number of input buttons for this input object.
		 */
		public static const NUM_INPUTS:uint = 223;

		/**
		 * Creates a new keyboard input object.
		 */
		public function AxKeyboard() {
			super(NUM_INPUTS);
		}

		/**
		 * Event handler for pressing a keyboard button.
		 * 
		 * @param event The keyboard event.
		 */
		public function onKeyDown(event:KeyboardEvent):void {
			if (event.keyCode >= NUM_INPUTS || keys[event.keyCode] > 0) {
				return;
			}
			keys[AxKey.ANY] = keys[event.keyCode] = Ax.now;
		}

		/**
		 * Event handler for releasing a keyboard button.
		 * 
		 * @param event The keyboard event.
		 */
		public function onKeyUp(event:KeyboardEvent):void {
			if (event.keyCode >= NUM_INPUTS) {
				return;
			}
			keys[event.keyCode] = -Ax.now;
		}
	}
}
