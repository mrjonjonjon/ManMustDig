extends Node2D

@export var chunk_length = 100              # Length of each chunk
@export var num_chunks = 10                # Number of chunks in each row/column
@export var chunk_prefab: PackedScene      # Prefab scene for each chunk

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Create a grid of chunks
	for x in range(num_chunks):
		for y in range(num_chunks):
			# Instantiate a new chunk from the prefab
			var chunk_instance = chunk_prefab.instantiate()
			
			# Set the position based on grid coordinates
			chunk_instance.position = Vector2(x * chunk_length, y * chunk_length)
			# Add the chunk as a child of the current node (to keep hierarchy organized)
			add_child(chunk_instance)
