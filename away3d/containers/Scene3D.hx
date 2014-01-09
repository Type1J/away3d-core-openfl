package away3d.containers;

	//import away3d.arcane;
	import away3d.core.partition.NodeBase;
	import away3d.core.partition.Partition3D;
	import away3d.core.traverse.PartitionTraverser;
	import away3d.entities.Entity;
	import away3d.events.Scene3DEvent;
	
	import flash.events.EventDispatcher;
	
	//use namespace arcane;
	
	/**
	 * The Scene3D class represents an independent 3D scene in which 3D objects can be created and manipulated.
	 * Multiple Scene3D instances can be created in the same SWF file.
	 *
	 * Scene management happens through the scene graph, which is exposed using addChild and removeChild methods.
	 * Internally, the Scene3D object also manages any space partition objects that have been assigned to objects in
	 * the scene graph, of which there is at least 1.
	 */
	class Scene3D extends EventDispatcher
	{
		/*arcane*/ public var _sceneGraphRoot:ObjectContainer3D;
		var _partitions:Array<Partition3D>;
		
		/**
		 * Creates a new Scene3D object.
		 */
		public function new()
		{
			super();

			_partitions = new Array<Partition3D>();
			_sceneGraphRoot = new ObjectContainer3D();
			_sceneGraphRoot.scene = this;
			_sceneGraphRoot._isRoot = true;
			_sceneGraphRoot.partition = new Partition3D(new NodeBase());
		}
		
		/**
		 * Sends a PartitionTraverser object down the scene partitions
		 * @param traverser The traverser which will pass through the partitions.
		 *
		 * @see away3d.core.traverse.PartitionTraverser
		 * @see away3d.core.traverse.EntityCollector
		 */
		public function traversePartitions(traverser:PartitionTraverser):Void
		{
			var i:UInt = 0;
			var len:UInt = _partitions.length;
			
			traverser.scene = this;
			
			while (i < len)
				_partitions[i++].traverse(traverser);
		}
		
		/**
		 * The root partition to be used by the Scene3D.
		 */
		public var partition(get, set) : Partition3D;
		public function get_partition() : Partition3D
		{
			return _sceneGraphRoot.partition;
		}
		
		public function set_partition(value:Partition3D) : Partition3D
		{
			_sceneGraphRoot.partition = value;
			
			dispatchEvent(new Scene3DEvent(Scene3DEvent.PARTITION_CHANGED, _sceneGraphRoot));
			return value;
		}
		
		public function contains(child:ObjectContainer3D):Bool
		{
			return _sceneGraphRoot.contains(child);
		}
		
		/**
		 * Adds a child to the scene's root.
		 * @param child The child to be added to the scene
		 * @return A reference to the added child.
		 */
		public function addChild(child:ObjectContainer3D):ObjectContainer3D
		{
			return _sceneGraphRoot.addChild(child);
		}
		
		/**
		 * Removes a child from the scene's root.
		 * @param child The child to be removed from the scene.
		 */
		public function removeChild(child:ObjectContainer3D):Void
		{
			_sceneGraphRoot.removeChild(child);
		}
		
		/**
		 * Removes a child from the scene's root.
		 * @param index Index of child to be removed from the scene.
		 */
		public function removeChildAt(index:UInt):Void
		{
			_sceneGraphRoot.removeChildAt(index);
		}
		
		/**
		 * Retrieves the child with the given index
		 * @param index The index for the child to be retrieved.
		 * @return The child with the given index
		 */
		public function getChildAt(index:UInt):ObjectContainer3D
		{
			return _sceneGraphRoot.getChildAt(index);
		}
		
		/**
		 * The amount of children directly contained by the scene.
		 */
		public var numChildren(get, null) : UInt;
		public function get_numChildren() : UInt
		{
			return _sceneGraphRoot.numChildren;
		}
		
		/**
		 * When an entity is added to the scene, or to one of its children, add it to the partition tree.
		 * @private
		 */
		public function registerEntity(entity:Entity):Void
		{
			var partition:Partition3D = entity.implicitPartition;
			addPartitionUnique(partition);
			
			partition.markForUpdate(entity);
		}
		
		/**
		 * When an entity is removed from the scene, or from one of its children, remove it from its former partition tree.
		 * @private
		 */
		public function unregisterEntity(entity:Entity):Void
		{
			entity.implicitPartition.removeEntity(entity);
		}
		
		/**
		 * When an entity has moved or changed size, update its position in its partition tree.
		 */
		public function invalidateEntityBounds(entity:Entity):Void
		{
			entity.implicitPartition.markForUpdate(entity);
		}
		
		/**
		 * When a partition is assigned to an object somewhere in the scene graph, add the partition to the list if it isn't in there yet
		 */
		public function registerPartition(entity:Entity):Void
		{
			addPartitionUnique(entity.implicitPartition);
		}
		
		/**
		 * When a partition is removed from an object somewhere in the scene graph, remove the partition from the list
		 */
		public function unregisterPartition(entity:Entity):Void
		{
			// todo: wait... is this even correct?
			// shouldn't we check the number of children in implicitPartition and remove partition if 0?
			entity.implicitPartition.removeEntity(entity);
		}
		
		/**
		 * Add a partition if it's not in the list
		 */
		private function addPartitionUnique(partition:Partition3D):Void
		{
			if (Lambda.indexOf(_partitions, partition) == -1)
				_partitions.push(partition);
		}
	}
