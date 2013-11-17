package io.axel.util.debug {
	import io.axel.AxRect;

	/**
	 * Base class for debug layouts. Extend this for creating your own console layout.
	 */
	public class AxDebugLayout {
		/** Dimensions objection used for the default reflow function. */
		protected var dimensions:AxRect = new AxRect;
		
		/**
		 * Flows the console based on the dimensions. You can override this function instead of manually
		 * flow the console, rather than relying on the dimensions.
		 * 
		 * @param console The AxDebugConsole to be reflowed.
		 */
		public function flow(console:AxDebugConsole):void {
			console.background.x = dimensions.x;
			console.background.y = dimensions.y;
			console.background.create(dimensions.width, dimensions.height, AxDebugConsole.CONSOLE_COLOR);
			console.text.x = console.background.x + AxDebugConsole.PADDING;
			console.text.y = console.background.y + AxDebugConsole.PADDING;
			console.text.resize(console.background.width - AxDebugConsole.PADDING * 2);
			console.text.limitStrategy.limit = (console.background.height - AxDebugConsole.PADDING * 2 + 2) / 10;
		}
	}
}
