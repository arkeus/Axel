package io.axel.util.debug {
	import io.axel.Ax;

	public class AxDebugBottomLeftLayout extends AxDebugLayout {
		public function AxDebugBottomLeftLayout() {
			dimensions.x = 20;
			dimensions.y = Math.max(30, Ax.height - 215);
			dimensions.width = Math.min(Ax.width - 40, 400);
			dimensions.height = Ax.height - dimensions.y - 15;
		}
	}
}
