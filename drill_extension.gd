@tool
extends "res://simplecontroller.gd"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func sync():
	#print("xxx")
	$Collider.set_polygon($Polygon.get_polygon())
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	sync()
