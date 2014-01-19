package io.axel.particle {
	import io.axel.base.AxPoint;
	import io.axel.render.AxBlendMode;
	import io.axel.render.AxColor;
	import io.axel.util.AxRange;

	/**
	 * A class representing a particle effect. After creating one of these and registering it
	 * with AxParticleSystem, you can then emit an effect of this type at any time. Be sure to
	 * change all the options before registering it though, they cannot be changed afterward.
	 */
	public class AxParticleEffect {
		/**
		 * Defines the x spawn window. This is the minimum and maximum offset around the spawn point.
		 * For example, if you emit this effect at 10, 10, and it's x and y ranges are both -5 to 5, then
		 * the particles will spawn anywhere between (5, 5) and (15, 15).
		 * 
		 * @default (0, 0) 
		 */
		public var x:AxRange;
		/**
		 * Defines the y spawn window. This is the minimum and maximum offset around the spawn point.
		 * For example, if you emit this effect at 10, 10, and it's x and y ranges are both -5 to 5, then
		 * the particles will spawn anywhere between (5, 5) and (15, 15).
		 * 
		 * @default (0, 0) 
		 */
		public var y:AxRange;
		/**
		 * The minimum and maximum x velocity that the particles will start out with.
		 * 
		 * @default (-100, 100) 
		 */
		public var xVelocity:AxRange;
		/**
		 * The minimum and maximum y velocity that the particles will start out with.
		 * 
		 * @default (-100, 100) 
		 */
		public var yVelocity:AxRange;
		/**
		 * The minimum and maximum x acceleration that each particle can have.
		 * 
		 * @default (0, 0) 
		 */
		public var xAcceleration:AxRange;
		/**
		 * The minimum and maximum y acceleration that each particle can have.
		 * 
		 * @default (0, 0) 
		 */
		public var yAcceleration:AxRange;
		/**
		 * The minimum and maximum angular velocity. This effects the group as a whole, and not
		 * individual particles.
		 * 
		 * @default (0, 0) 
		 */
		public var aVelocity:AxRange;
		/**
		 * The minimum and maximum scale that each particle will start with.
		 * 
		 * @default (1, 1) 
		 */
		public var startScale:AxRange;
		/**
		 * The minimum and maximum scale that each particle will end with. If this is
		 * larger than the startScale, the particles will grow in size, while if it is
		 * less, they will shrink.
		 * 
		 * @default (1, 1) 
		 */
		public var endScale:AxRange;
		/**
		 * The minimum and maximum alpha value that each particle will start with.
		 * 
		 * @default (1, 1) 
		 */
		public var startAlpha:AxRange;
		/**
		 * The minimum and maximum alpha balue that each particle will end with. If this is
		 * larger than the startAlpha, the particles will fade in, while if it is less, they
		 * will fade out.
		 * 
		 * @default (0, 0) 
		 */
		public var endAlpha:AxRange;
		/**
		 * The minimum and maximum lifetime each particle will have. This is how long the particle
		 * will have before it stops being drawn. It also determines the timeline at which a particle
		 * will scale and fade. If the start alpha is 1, end alpha is 0, and lifetime is 2, that means
		 * that at time = 0, the particle will be fully opaque, and it will fade out over the course of
		 * 2 seconds, and at 2 seconds (the end of its lifetime), it will be fully transparent.
		 * 
		 * @default (1, 2) 
		 */
		public var lifetime:AxRange;
		/**
		 * The amount of particles to emit each time you emit this particle effect.
		 * 
		 * @default 10 
		 */
		public var amount:uint;
		/**
		 * The blend mode to use for the particles.
		 * 
		 * @default AxBlendMode.BLEND
		 */
		public var blend:AxBlendMode;
		/**
		 * The range of the red component of each particle's starting color. Change the starting and ending
		 * colors in bulk using the <code>color</code> method.
		 * 
		 * @default 1 
		 */
		public var startColorRed:AxRange;
		/**
		 * The range of the green component of each particle's starting color. Change the starting and ending
		 * colors in bulk using the <code>color</code> method.
		 * 
		 * @default 1 
		 */
		public var startColorGreen:AxRange;
		/**
		 * The range of the blue component of each particle's starting color. Change the starting and ending
		 * colors in bulk using the <code>color</code> method.
		 * 
		 * @default 1 
		 */
		public var startColorBlue:AxRange;
		/**
		 * The range of the red component of each particle's ending color. Change the starting and ending
		 * colors in bulk using the <code>color</code> method.
		 * 
		 * @default 1 
		 */
		public var endColorRed:AxRange;
		/**
		 * The range of the green component of each particle's ending color. Change the starting and ending
		 * colors in bulk using the <code>color</code> method.
		 * 
		 * @default 1 
		 */
		public var endColorGreen:AxRange;
		/**
		 * The range of the blue component of each particle's ending color. Change the starting and ending
		 * colors in bulk using the <code>color</code> method.
		 * 
		 * @default 1 
		 */
		public var endColorBlue:AxRange;
		/**
		 * If using multiple particle types in your texture, this should represent the size of each particle
		 * frame. Use frame() to set the frame size and range together.
		 */ 
		public var frameSize:AxPoint;
		/**
		 * If using multiple particle types in your texture, this is the range of possible particles that this
		 * effect can have. Use frame() to set the frame size and range together.
		 */
		public var frameRange:AxRange;
		/**
		 * The scroll factor to use for this effect.
		 */
		public var scroll:AxPoint;

		/**
		 * The name of this particle effect. This is what you will use to emit particles of this type once
		 * registered. 
		 */
		public var name:String;
		/**
		 * The embedded image to use for this particle.
		 */
		public var resource:Class;
		/**
		 * The maximum number of effects of this type that can be drawn at a time. If you reach this limit and
		 * emit another one before one of the older ones dies, it will destroy an older one and reuse it for
		 * the new effect. Usually you want this to be around the maximum number that could possibly be activated
		 * at any given time. For example, if you show one effect for each coin collected, but players can't collect
		 * more than 5 coins during the lifetime of a single effect, then 5 is a good limit for this. The lower this
		 * is, the faster the effect will be created when initialized. A large number can greatly slow down effect
		 * construction.
		 * 
		 * @default 10 
		 */
		public var max:uint;

		/**
		 * 
		 * @param name
		 * @param resource
		 * @param max
		 *
		 */
		public function AxParticleEffect(name:String, resource:Class, max:uint = 10) {
			this.name = name;
			this.resource = resource;
			this.max = max;

			// particle effect defaults, you only need to modify values that are different than these
			x = new AxRange(0, 0);
			y = new AxRange(0, 0);
			xVelocity = new AxRange(-100, 100);
			yVelocity = new AxRange(-100, 100);
			xAcceleration = new AxRange(0, 0);
			yAcceleration = new AxRange(0, 0);
			aVelocity = new AxRange(0, 0);
			startScale = new AxRange(1, 1);
			endScale = new AxRange(1, 1);
			startAlpha = new AxRange(1, 1);
			endAlpha = new AxRange(0, 0);
			lifetime = new AxRange(1, 2);
			amount = 10;
			blend = AxBlendMode.BLEND;
			startColorRed = new AxRange(1, 1);
			startColorGreen = new AxRange(1, 1);
			startColorBlue = new AxRange(1, 1);
			endColorRed = new AxRange(1, 1);
			endColorGreen = new AxRange(1, 1);
			endColorBlue = new AxRange(1, 1);
			frameSize = new AxPoint(0, 0);
			frameRange = new AxRange(-1, -1);
			scroll = new AxPoint(1, 1);
		}

		/**
		 * Changes the starting and ending colors in bulk. Note that while each is an AxColor, the alpha component
		 * of these colors is not used. Use startAlpha and endAlpha to modify the starting and ending alpha values.
		 * 
		 * @param startMin The minimum starting value of each red/green/blue component of each particle.
		 * @param startMax The maximum starting value of each red/green/blue component of each particle.
		 * @param endMin The minimum ending value of each red/green/blue component of each particle.
		 * @param endMax The maximum ending value of each red/green/blue component of each particle.
		 *
		 * @return The particle effect.
		 */
		public function color(startMin:AxColor = null, startMax:AxColor = null, endMin:AxColor = null, endMax:AxColor = null):AxParticleEffect {
			if (startMin != null) {
				startColorRed.min = startMin.red;
				startColorGreen.min = startMin.green;
				startColorBlue.min = startMin.blue;
			}

			if (startMax != null) {
				startColorRed.max = startMax.red;
				startColorGreen.max = startMax.green;
				startColorBlue.max = startMax.blue;
			}

			if (endMin != null) {
				endColorRed.min = endMin.red;
				endColorGreen.min = endMin.green;
				endColorBlue.min = endMin.blue;
			}

			if (endMax != null) {
				endColorRed.max = endMax.red;
				endColorGreen.max = endMax.green;
				endColorBlue.max = endMax.blue;
			}

			return this;
		}
		
		/**
		 * Sets the possible frames this particle can use. You can put multiple particles in your image, and using this,
		 * tell it to randomly use one of those particles. You must set the width and the height of each frame, otherwise
		 * it will use the entire image for the particle. If you do not set frameMin and frameMin, it will assume that
		 * it can be any possible particle in the spritesheet.
		 * 
		 * @param frameWidth The width of each frame in your particle sprite sheet.
		 * @param frameHeight The height of each frame in your particle sprite sheet.
		 * 
		 * @return The particle effect.
		 */
		public function frame(frameWidth:uint, frameHeight:uint, frameMin:int = -1, frameMax:int = -1):AxParticleEffect {
			frameSize.x = frameWidth;
			frameSize.y = frameHeight;
			frameRange.min = frameMin;
			frameRange.max = frameMax;
			return this;
		}
	}
}
