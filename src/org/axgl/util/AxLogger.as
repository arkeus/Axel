package org.axgl.util {
	import flash.external.ExternalInterface;

	import org.axgl.Ax;

	public class AxLogger {
		public static const DEBUG:String = "debug";
		public static const INFO:String = "info";
		public static const WARN:String = "warn";
		public static const ERROR:String = "error";

		public var external:Boolean = false;
		public var console:Boolean = false;

		public function AxLogger() {
			this.external = ExternalInterface.available;
		}

		public function debug(... arguments):void {
			send(arguments, DEBUG);
		}

		public function log(... arguments):void {
			info(arguments);
		}

		public function info(... arguments):void {
			send(arguments, INFO);
		}

		public function warn(... arguments):void {
			send(arguments, WARN);
		}

		public function error(... arguments):void {
			send(arguments, ERROR);
		}

		private function send(arguments:Object, level:String = INFO):void {
			for (var i:String in arguments) {
				// log to browser if external logging is enabled
				if (external && level != DEBUG) {
					try {
						ExternalInterface.call("console." + level, arguments[i]);
					} catch (error:Error) {
						trace(error);
					}
				}
				// log to debug console if console is enabled
				if (console) {
					Ax.debugger.log(level, arguments[i]);
				}
				// always trace to debugger
				trace(arguments[i]);
			}
		}
	}
}
