package org.axgl.util {
	import flash.external.ExternalInterface;

	public class AxLogger {
		public static const DEBUG:String = "debug";
		public static const LOG:String = "log";
		public static const WARN:String = "warn";
		public static const ERROR:String = "error";
		
		private var external:Boolean = false;
		
		public function AxLogger() {
			this.external = ExternalInterface.available;
		}
		
		public function debug(... arguments):void {
			send(arguments, DEBUG);
		}
		
		public function log(... arguments):void
		{
			send(arguments, LOG);
		}
		
		public function warn(... arguments):void
		{
			send(arguments, WARN);
		}
		
		public function error(... arguments):void
		{
			send(arguments, ERROR);
		}
		
		private function send(arguments:Object, level:String = LOG):void {
			for (var i:String in arguments) {
				if (external && level != DEBUG) {
					ExternalInterface.call("console." + level, arguments[i]);
				}
				trace(arguments[i]);
			}
		}
	}
}
