package org.axgl.input {
	import flash.events.MouseEvent;
	
	import org.axgl.Ax;
	import org.axgl.AxPoint;

	
	/**
	 * The mouse object used to test for input, and track the location of the pointer.
	 */
	public class AxMouse extends AxInput {
		/**
		 * The number of input buttons for this input object.
		 */
		public static const NUM_INPUTS:uint = 1;

		/**
		 * The x position of the pointer in world coordinates.
		 */
		public var x:Number;
		/**
		 * The y position of the pointer in world coordinates. 
		 */
		public var y:Number;
		/**
		 * The x and y position of the pointer relative to the screen.
		 */
		public var screen:AxPoint;

		/**
		 * Creates a new mouse input object.
		 */
		public function AxMouse() {
			super(NUM_INPUTS);

			x = 0;
			y = 0;
			screen = new AxPoint;
		}

		/**
		 * Event handler for pressing a mouse button.
		 * 
		 * @param event The mouse event.
		 */
		public function onMouseDown(event:MouseEvent):void {
			keys[AxMouseButton.LEFT] = Ax.now;
		}

		/**
		 * Event handler for releasing a mouse button.
		 * 
		 * @param event The mouse event.
		 */
		public function onMouseUp(event:MouseEvent):void {
			keys[AxMouseButton.LEFT] = -Ax.now;
		}

		/**
		 * Updates the mouse's coordinates.
		 * 
		 * @param x The x position in screen space.
		 * @param y The y position in screen space.
		 */
		public function update(x:Number, y:Number):void {
			screen.x = x / Ax.zoom;
			screen.y = y / Ax.zoom;
			this.x = screen.x + Ax.camera.position.x;
			this.y = screen.y + Ax.camera.position.y;
		}
	}
}
