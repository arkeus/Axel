package io.axel.util {
	import com.adobe.utils.PerspectiveMatrix3D;

	import flash.geom.Matrix3D;

	import io.axel.Ax;
	import io.axel.AxEntity;
	import io.axel.AxRect;
	import io.axel.AxU;

	/**
	 * The basic camera that determines what is visible on the screen.
	 */
	public class AxCamera extends AxEntity {
		/**
		 * The target that the camera is following, null if none.
		 */
		public var target:AxEntity;
		/**
		 * The bounds determining where the camera can move in the world.
		 */
		public var bounds:AxRect;

		/**
		 * A temporary world view matrix.
		 */
		public var view:PerspectiveMatrix3D;
		/**
		 * The projection matrix to transform an object into screen space.
		 */
		public var projection:Matrix3D;
		/**
		 * The project matrix to transform an object into screen space at 1x zoom.
		 */
		public var baseProjection:Matrix3D;

		/**
		 * Creates a new camera.
		 */
		public function AxCamera() {
			super();
			bounds = new AxRect;
			bounds.x = Number.NEGATIVE_INFINITY;
			bounds.y = Number.NEGATIVE_INFINITY;
			bounds.width = Number.POSITIVE_INFINITY;
			bounds.height = Number.POSITIVE_INFINITY;

			projection = new Matrix3D;
			view = new PerspectiveMatrix3D;
			baseProjection = new Matrix3D;

			calculateZoomMatrix();
			calculateProjectionMatrix(baseProjection, 1);
		}

		/**
		 * Tells the camera to begin following the passed entity.
		 * 
		 * @param target The entity to follow.
		 */
		public function follow(target:AxEntity):void {
			this.target = target;
		}

		/**
		 * Updates the camera's coordinates if it is following an entity.
		 */
		override public function update():void {
			if (target != null) {
				x = (target.x + target.width / 2 - Ax.width / (2 * Ax.zoom));
				y = (target.y + target.height / 2 - Ax.height / (2 * Ax.zoom));

				x = AxU.clamp(x, bounds.x, bounds.width - Ax.width / Ax.zoom);
				y = AxU.clamp(y, bounds.y, bounds.height - Ax.height / Ax.zoom);
			}
		}
		
		/**
		 * Resets the camera to the default position.
		 */
		public function reset():void {
			target = null;
			x = 0;
			y = 0;
		}

		/**
		 * Calculates the projection matrix based on the current zoom level.
		 */
		public function calculateZoomMatrix():void {
			calculateProjectionMatrix(projection, Ax.zoom);
			Ax.viewWidth = Ax.width / Ax.zoom;
			Ax.viewHeight = Ax.height / Ax.zoom;
		}

		/**
		 * Calculates a projection matrix based on the passed zoom, and stores it in the passed matrix.
		 * 
		 * @param matrix The matrix to place the result in.
		 * @param zoom The zoom level to calculate the projection matrix for.
		 */
		public function calculateProjectionMatrix(matrix:Matrix3D, zoom:Number):void {
			matrix.identity();
			// Flip the y axis so 0,0 is in the upper left like typical screen coordinates
			matrix.appendScale(zoom, -zoom, 1);
			// Move the origin to the bottom left
			matrix.appendTranslation(-Ax.width / 2, Ax.height / 2, 0);
			// Create an orthographic projection the same size as our screen
			view.identity();
			view.orthoLH(Ax.width, Ax.height, 0, 1);
			// Multiply the view by the world transformation
			matrix.append(view)
		}
	}
}
