package org.axgl.input {
	import org.axgl.Ax;

	/**
	 * A generic input class containing general actions used by input devices such as the keyboard and mouse.
	 */
	public class AxInput {
		/**
		 * A list of integers containing information about each key. Each key is indexed into this vector using
		 * the constants declared in AxKey and AxMouseButton.
		 */
		protected var keys:Vector.<int>;

		/**
		 * Creates a new input object.
		 * 
		 * @param inputs The number of input keys for this device.
		 */
		public function AxInput(inputs:uint) {
			keys = new Vector.<int>(inputs, true);
		}

		/**
		 * Returns whether or not the passed key or button is currently being held down.
		 * This method is identical to AxInput.held(). Does NOT work with AxKey.ANY.
		 * 
		 * @param key The key to test.
		 *
		 * @return Whether or not it is being held down.
		 */
		public function down(key:uint):Boolean {
			return keys[key] > 0;
		}
		
		/**
		 * Returns whether or not the passed key or button is currently being held down.
		 * This method is identical to AxInput.down(). Does NOT work with AxKey.ANY.
		 * 
		 * @param key The key to test.
		 *
		 * @return Whether or not it is being held down.
		 */
		public function held(key:uint):Boolean {
			return keys[key] > 0;
		}

		/**
		 * Returns whether or not the passed input was just pressed. Fires once each time
		 * you hold down a button or key.
		 * 
		 * @param key The key to test.
		 *
		 * @return Whether or not the key was just pressed.
		 */
		public function pressed(key:uint):Boolean {
			return keys[key] >= Ax.then && keys[key] < Ax.now && Ax.then > 0;
		}

		/**
		 * Returns whether or not the passed input was just released. Fires once each time
		 * you release a button or key.
		 * 
		 * @param key The key to test.
		 *
		 * @return Whether or not the key was just released. 
		 */
		public function released(key:uint):Boolean {
			return keys[key] <= -Ax.then && keys[key] > -Ax.now && Ax.then > 0;
		}

		/**
		 * Releases every key on this device. Useful when you are changing states so input doesn't fire twice,
		 * or when you want someone to have to press a key again.
		 */
		public function releaseAll():void {
			for (var i:uint = 0; i < keys.length; i++) {
				keys[i] = 0;
			}
		}
	}
}
