package org.axgl.sound {
	import org.axgl.Ax;

	/**
	 * A special instance of an AxSound, which by default will loop.
	 */
	public class AxMusic extends AxSound {
		/**
		 * Creates a new music object, but does not start playing it.
		 * 
		 * @param sound The embedded sound file to play.
		 * @param volume The volume to play the sound at.
		 * @param loop Whether or not the sound should loop.
		 * @param start The time (in ms) of how far into the sound it should start playing.
		 */
		public function AxMusic(sound:Class, volume:Number, loop:Boolean = true, start:Number = 0) {
			super(sound, volume, loop, start);
		}

		/**
		 * @inheritDoc
		 */
		override protected function updateVolume():void {
			soundTransform.volume = Ax.musicMuted ? 0 : volume * Ax.musicVolume;
			soundChannel.soundTransform = soundTransform;
		}
	}
}
