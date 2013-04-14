package org.axgl.util.debug {
	import org.axgl.Ax;
	import org.axgl.AxGroup;
	import org.axgl.AxSprite;
	import org.axgl.resource.AxResource;
	import org.axgl.text.AxText;
	import org.axgl.text.AxTextLimitStrategy;
	import org.axgl.util.AxLogger;

	/**
	 * A debug console that contains all the log messages on screen. You can adjust the layout of
	 * the debug console via Ax.options, or by calling Ax.debugger.customReflow passing in your own
	 * custom debug window layout.
	 */
	public class AxDebugConsole extends AxGroup {
		/** Lays the debug console on the bottom left in a small window. */
		public static const BOTTOM_LEFT_LAYOUT:uint = 0;
		/** Lays the debug console on the left side of the screen, full height. */
		public static const LEFT_SIDE_LAYOUT:uint = 1;
		/** Lays the debug console on the entire screen between the two debug bars. */
		public static const FULL_SCREEN_LAYOUT:uint = 2;
		
		public static const CONSOLE_COLOR:uint = 0x77000000;
		public static const PADDING:uint = 6;
		
		public var background:AxSprite;
		public var text:AxText;
		public var messages:Vector.<String> = new Vector.<String>;
		
		public function AxDebugConsole() {
			this.add(background = new AxSprite(0, 0));
			this.add(text = new AxText(5, 5, AxResource.font, "", Ax.viewWidth - 20));
			background.scroll.x = background.scroll.y = 0;
			text.scroll.x = text.scroll.y = 0;
			background.zooms = text.zooms = false;
			visible = false;
			text.limitStrategy = new AxTextLimitStrategy(3, AxTextLimitStrategy.END);
			reflow(BOTTOM_LEFT_LAYOUT);
		}
		
		/**
		 * Reflows the debug window based on a built in layout.
		 * 
		 * @param layout The layout to use when reflowing the debug console.
		 */
		public function reflow(layout:uint):void {
			switch (layout) {
				case BOTTOM_LEFT_LAYOUT:
					customReflow(new AxDebugBottomLeftLayout);
				break;
				case LEFT_SIDE_LAYOUT:
					customReflow(new AxDebugLeftSideLayout);
				break;
				case FULL_SCREEN_LAYOUT:
					customReflow(new AxDebugFullScreenLayout);
				break;
			}
		}
		
		/**
		 * Reflows the debug window based on an AxDebugLayout. You can call this to reflow
		 * based on a custom debug layout.
		 */
		public function customReflow(layout:AxDebugLayout):void {
			layout.flow(this);
		}
		
		/**
		 * Logs a message to the debug console. Unless necessary, you should typically be calling
		 * functions on Ax.logger rather than this class directly.
		 * 
		 * @param level The log level to use.
		 * @param message The message to log.
		 */
		public function log(level:String, message:String):void {
			visible = true;
			messages.push(getDateTag() + " " + getLogTag(level) + " " + message);
			if (messages.length > text.limitStrategy.limit) {
				messages.splice(0, messages.length - text.limitStrategy.limit);
			}
			text.text = messages.join("\n");
		}
		
		private static const INFO_TAG:String = "@[ffffff][@[89ee9c]INFO@[ffffff]]";
		private static const WARN_TAG:String = "@[ffffff][@[ffb93f]WARN@[ffffff]]";
		private static const ERROR_TAG:String = "@[ffffff][@[ff3f3f]ERROR@[ffffff]]";
		private function getLogTag(level:String):String {
			switch (level) {
				case AxLogger.ERROR: return ERROR_TAG;
				case AxLogger.WARN: return WARN_TAG;
				default: return INFO_TAG;
			}
		}
		
		private function getDateTag():String {
			var date:Date = new Date;
			var dateString:String = date.hours + "@[ffffff]:@[aaaaaa]" + (date.minutes < 10 ? "0" + date.minutes : date.minutes) + "@[ffffff]:@[aaaaaa]" + (date.seconds < 10 ? "0" + date.seconds : date.seconds);
			return "@[ffffff][@[aaaaaa]" + dateString + "@[ffffff]]";
		}
	}
}
