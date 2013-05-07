package org.axgl.util.debug {
	import org.axgl.Ax;
	
	public class AxDebugFullScreenLayout extends AxDebugLayout {		
		public function AxDebugFullScreenLayout() {
			dimensions.x = 0;
			dimensions.y = AxDebugger.BAR_HEIGHT;
			dimensions.width = Ax.width;
			dimensions.height = Ax.height - AxDebugger.BAR_HEIGHT * 2;
		}
	}
}
