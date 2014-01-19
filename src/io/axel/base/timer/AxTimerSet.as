package io.axel.base.timer {
	/**
	 * A set of timers to be used for an entity. Timers are used to add callbacks that will be called
	 * after a specific amount of time, or to create events that repeat every X seconds.
	 */
	public class AxTimerSet {
		/** The threshold of dead timers required before cleanup happens. */
		private static const DEAD_TIMER_THRESHOLD:uint = 5;
		
		/** List of timers active on this entity. */
		public var timers:Vector.<AxTimer>;
		/** Temporary timer list used to clean up dead timers. */
		public var timersTemp:Vector.<AxTimer>;

		public function AxTimerSet() {
			timers = null;
			timersTemp = null;
		}

		/**
		 * Updates the timers by the specified amount of time. Each of the timers will have their time
		 * decremented, and trigger once they hit zero.
		 * 
		 * @param dt The amount of time to affect the timers by.
		 */
		public function update(dt:Number):void {
			var i:uint;

			if (timers != null) {
				var deadTimers:uint = 0;
				for (i = 0; i < timers.length; i++) {
					if (!timers[i].alive) {
						deadTimers++;
						continue;
					} else if (!timers[i].active) {
						continue;
					}
					timers[i].timer -= dt;
					while (timers[i].timer <= 0) {
						timers[i].timer += timers[i].delay;
						timers[i].repeat--;
						timers[i].callback();
						if (timers[i].repeat <= 0) {
							timers[i].stop();
							break;
						}
					}
				}
				if (deadTimers >= DEAD_TIMER_THRESHOLD) {
					var temp:Vector.<AxTimer> = timersTemp;
					temp.length = 0;
					for (i = 0; i < timers.length; i++) {
						if (timers[i].alive) {
							temp.push(timers[i]);
						}
					}
					timersTemp = timers;
					timers = temp;
				}
			}
		}

		/**
		 * Timers are repeatable functions that can be bound to any AxEntity. Take, for example,
		 * the following:
		 *
		 * <code>sprite.addTimer(5, destroy);</code>
		 *
		 * This would destroy the sprite after 5 seconds. You can also use timers to register repeating
		 * events. For example:
		 *
		 * <code>sprite.addTimer(1, function():void { sprite.visible = !sprite.visible; }, 5, 3);</code>
		 *
		 * This would cause the sprite to flicker visible/invisible 5 times, once per second. The 3 indicates
		 * that the first occurrence would not occur until after 3 seconds, and the following ones would be
		 * spaced 1 second apart.
		 *
		 * @param delay The delay before this fires, or the delay between firing if set to repeat.
		 * @param callback The function called when the timer fires.
		 * @param repeat The number of times to repeat the timer. 0 indiciates repeat forever.
		 * @param start How long to delay the first execution if repeatable.
		 */
		public function add(delay:Number, callback:Function, repeat:uint = 1, start:Number = -1):AxTimer {
			if (timers == null) {
				timers = new Vector.<AxTimer>;
				timersTemp = new Vector.<AxTimer>;
			}

			var timer:AxTimer = new AxTimer(delay, callback, repeat, start);
			timers.push(timer);
			return timer;
		}

		/**
		 * Removes all timers currently set on this object. Does not run the callbacks of any timers currently
		 * in progress.
		 */
		public function clear():void {
			if (timers != null) {
				timers.length = 0;
			}
			if (timersTemp != null) {
				timersTemp.length = 0;
			}
		}
	}
}
