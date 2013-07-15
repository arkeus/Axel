package org.axgl.sound {
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	import org.axgl.Ax;
	import org.axgl.AxEntity;

	/**
	 * A sound object. For simple use cases, this class will be completely managed by Axel. However,
	 * whenever you play a sound or music you will get the instance of this class returned to you in
	 * order to do more advanced effects.
	 */
	public class AxSound extends AxEntity {
		/** The internal flash sound object. */
		private var sound:Sound;
		protected var _soundChannel:SoundChannel;
		/** The internal flash sound transform. */
		protected var soundTransform:SoundTransform;

		/**
		 * The volume of the sound.
		 * @default 1
		 */
		public var volume:Number;
		/**
		 * Whether or not the sound should loop.
		 */
		public var loop:Boolean;
		/**
		 * The time (in ms) of how far into the sound it should start playing.
		 * @default 0
		 */
		public var start:Number;

		/**
		 * Creates a new sound object, but does not start playing the sound.
		 *
		 * @param sound The embedded sound file to play.
		 * @param volume The volume to play the sound at.
		 * @param loop Whether or not the sound should loop.
		 * @param start The time (in ms) of how far into the sound it should start playing.
		 */
		public function AxSound(sound:Class, volume:Number = 1, loop:Boolean = false, start:Number = 0) {
			this.sound = new sound();
			this.volume = volume;
			this.loop = loop;
			this.start = start;
			this.soundTransform = new SoundTransform(volume);
		}

		/** The internal flash sound channel. */
		public function get soundChannel():SoundChannel
		{
			return _soundChannel;
		}

		/**
		 * Plays the sound. If loop is true, will repeat once it reaches the end.
		 *
		 * @return
		 */
		public function play():AxSound {
			_soundChannel = sound.play(start, loop ? int.MAX_VALUE : 0, soundTransform);
			_soundChannel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			return this;
		}
		
		/**
		 * Sound completion callback.
		 * 
		 * @param event The sound completion event.
		 */
		private function onSoundComplete(event:Event):void {
			destroy();
		}

		/**
		 * Destroys the sound, freeing up resources used.
		 */
		override public function destroy():void {
			if( _soundChannel != null )
			{
				_soundChannel.stop();
				_soundChannel.removeEventListener(Event.SOUND_COMPLETE, destroy);
			}
			sound = null;
			_soundChannel = null;
			soundTransform = null;
			Ax.sounds.remove(this);
			super.destroy();
		}

		/**
		 * @inheritDoc
		 */
		override public function update():void {
			updateVolume();
		}

		/**
		 * Updates the sound transform and sound channel after the volume is changed.
		 */
		protected function updateVolume():void {
			soundTransform.volume = Ax.soundMuted ? 0 : volume * Ax.soundVolume;
			_soundChannel.soundTransform = soundTransform;
		}
	}
}
