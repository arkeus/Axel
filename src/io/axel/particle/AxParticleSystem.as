package io.axel.particle {
	import flash.utils.Dictionary;
	
	import io.axel.AxEntity;
	import io.axel.AxGroup;

	/**
	 * A generic particle system to keep track of your particle effects, and allow you to create your effects
	 * from anywhere within the game.
	 */
	public class AxParticleSystem {
		/**
		 * A mapping of all your particle effects by name.
		 */
		private static var effects:Dictionary = new Dictionary;
		/**
		 * An internal counter used to "randomize" which instance of a particle effect is shown. 
		 */
		private static var counter:Number = 0;

		/**
		 * Registers a new particle effect. After creating an effect, you must register it before you can
		 * use it in your game.
		 * 
		 * @param effect The effect to register.
		 *
		 * @return The group containing all the created instances of your effect.
		 */
		public static function register(effect:AxParticleEffect):AxGroup {
			var set:AxGroup = new AxGroup;
			var particleCloud:AxParticleCloud = new AxParticleCloud(effect).build();
			for (var i:uint = 0; i < effect.max - 1; i++) {
				set.add(particleCloud.clone());
			}
			set.add(particleCloud);
			effects[effect.name] = set;
			return set;
		}

		/**
		 * Creates an instance of your particle effect on screen at the location provided. Note that to use this
		 * you must have first registered the particle effect. If you already have more instances of this effect
		 * showing on screen than you allocated, it will destroy one and reuse it for this new effect. If you use
		 * the name of an effect that doesn't exist, nothing will happen.
		 * 
		 * @param name The name of the particle effect to show.
		 * @param x The x-position in world coordinates.
		 * @param y The y-position in world coordinates.
		 *
		 * @return The instance of the particle effect that was placed on screen, null if the effect doesn't exist.
		 */
		public static function emit(name:String, x:Number, y:Number):AxParticleCloud {
			counter++;
			
			if (effects[name] == null) {
				return null;
			}

			var members:Vector.<AxEntity> = effects[name].members;
			var cloud:AxParticleCloud = members[counter % members.length] as AxParticleCloud;
			cloud.reset(x, y);
			return cloud;
		}
	}
}
