package org.axgl.util.debug {
	import org.axgl.AxRect;

	public class AxDebugLayout {
		protected var dimensions:AxRect = new AxRect;
		
		public function flow(console:AxDebugConsole):void {
			console.background.x = dimensions.x;
			console.background.y = dimensions.y;
			console.background.create(dimensions.width, dimensions.height, AxDebugConsole.CONSOLE_COLOR);
			console.text.x = console.background.x + AxDebugConsole.PADDING;
			console.text.y = console.background.y + AxDebugConsole.PADDING;
			console.text.resize(console.background.width - AxDebugConsole.PADDING * 2);
		}
	}
}
