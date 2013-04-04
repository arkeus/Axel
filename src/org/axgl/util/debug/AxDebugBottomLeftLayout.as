package org.axgl.util.debug {
	import org.axgl.Ax;
	import org.axgl.AxRect;

	public class AxDebugBottomLeftLayout extends AxDebugLayout {
		public function AxDebugBottomLeftLayout() {
			dimensions.x = 20;
			dimensions.y = Math.max(30, Ax.height - 215);
			dimensions.width = Math.min(Ax.width - 40, 400);
			dimensions.height = Ax.height - dimensions.y - 15;
		}
	}
}
