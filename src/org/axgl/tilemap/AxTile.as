package org.axgl.tilemap {
	import org.axgl.AxEntity;

	/**
	 * A class describing a single tile in a tilemap. Each tilemap will have one of these for each different
	 * type of tile in the map, not for each actual tile.
	 */
	public class AxTile extends AxEntity {
		/**
		 * The tilemap this tile type belongs to.
		 */
		public var map:AxTilemap;
		/**
		 * The possible collision directions for this tile.
		 * TODO: Currently if you set it to NONE it is not solid, anything else is fully solid. Must support partially solid
		 * in the future.
		 */
		public var collision:uint;
		/**
		 * The callback function that should be called if this tile is collided against.
		 */
		public var callback:Function;
		/**
		 * The tile type index that this tile represents.
		 */
		private var index:uint;

		/**
		 * Creates a new AxTile.
		 * 
		 * @param map The tilemap this tile type belongs to.
		 * @param index The tile type index that this tile represents.
		 * @param width The width of this tile.
		 * @param height The height of this tile.
		 */
		public function AxTile(map:AxTilemap, index:uint, width:uint, height:uint) {
			super();
			this.map = map;
			this.index = index;
			this.width = width;
			this.height = height;
			this.collision = NONE;
			this.callback = null;
		}
	}
}
