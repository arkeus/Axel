package org.axgl.tilemap {
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	
	import org.axgl.Ax;

	/**
	 * A structure that holds information about a single segment within an AxTilemap. Each
	 * segment only contains the information necessary to draw that piece of the map (when
	 * visible on the screen), and does not contain any information about the tiles contained
	 * for things such as collision or pathfinding, those are all contained within AxTilemap.
	 * 
	 * This class purposely avoids extending AxModel as it cannot be drawn on its own, it can
	 * only be drawn in the context of AxTilemap.
	 */
	public class AxTilemapSegment {
		/** The index data used for the mesh of this model. */
		internal var indexData:Vector.<uint>;
		/** The index buffer used for the mesh of this model. */
		internal var indexBuffer:IndexBuffer3D;
		/** The vertex data used for the mesh of this model. */
		internal var vertexData:Vector.<Number>;
		/** The vertex buffer used to draw this model. */
		internal var vertexBuffer:VertexBuffer3D;
		/** The offsets, containing the id into the tilemap.data array of which tile is where */
		internal var bufferOffsets:Vector.<int>;
		/** The size of the buffer containing the tiles. */
		internal var bufferSize:uint;
		/** The number of triangles in this segment. */
		internal var triangles:uint;
		/** The parent tilemap this is a part of. */
		internal var tilemap:AxTilemap;
		/** Whether or not the vertex buffer needs to be rebuilt and reuploaded. */
		internal var dirty:Boolean;
		/** The index used by the tilemap to calculate the index buffer entries. */
		internal var index:uint;
		/** The width of the segment in tiles. */
		internal var width:uint;
		/** The height of the segment in tiles. */
		internal var height:uint;
		
		public function AxTilemapSegment(tilemap:AxTilemap, width:uint, height:uint) {
			this.tilemap = tilemap;
			this.width = width;
			this.height = height;
			indexData = new Vector.<uint>;
			vertexData = new Vector.<Number>;
			bufferOffsets = new Vector.<int>;
			bufferSize = 0;
			index = 0;
			triangles = 0;
			dirty = true;
		}
		
		/**
		 * Draws this segment. Only works in the context of AxTilemap.draw.
		 */
		public function draw():void {
			if (indexData.length == 0) {
				return;
			}
			
			if (dirty) {
				upload();
				dirty = false;
			}
			
			Ax.context.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
			Ax.context.setVertexBufferAt(1, vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_2);
			Ax.context.drawTriangles(indexBuffer, 0, triangles);
		}
		
		/**
		 * Builds the vertex buffer and index buffer and uploads it to the GPU.
		 */
		private function upload():void {
			var vertexLength:uint = vertexData.length / tilemap.shader.rowSize;
			indexBuffer = Ax.context.createIndexBuffer(indexData.length);
			indexBuffer.uploadFromVector(indexData, 0, indexData.length);
			vertexBuffer = Ax.context.createVertexBuffer(vertexLength, tilemap.shader.rowSize);
			vertexBuffer.uploadFromVector(vertexData, 0, vertexLength);
			triangles = indexData.length / 3;
		}
	}
}
