package io.axel.util.debug {
	import io.axel.Ax;
	
	public class AxDebugLeftSideLayout extends AxDebugLayout {		
		public function AxDebugLeftSideLayout() {
			dimensions.x = 0;
			dimensions.y = AxDebugger.BAR_HEIGHT;
			dimensions.width = Math.min(Ax.width / 2, 400);
			dimensions.height = Ax.height - AxDebugger.BAR_HEIGHT * 2;
		}
	}
}
