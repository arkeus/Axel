package org.axgl.particle
{
	public class AxParticleEffectAnimated extends AxParticleEffect
	{
		private var resources:Vector.<Class>;
		private var framerate:Number;
		
		private var startedAnimatingTime:Number;
		
		public function AxParticleEffectAnimated(name:String, resources:Vector.<Class>, framerate:Number, max:uint=10)
		{
			super(name, null, max);
			
			this.resources = resources;
			this.framerate = framerate;
		}
		
		public function getCurrentResource( currentPlayDuration:Number ):Class
		{
			var frameIndex:uint = ( currentPlayDuration * framerate ) % resources.length;
			return resources[ frameIndex ];
		}
		
	}
}