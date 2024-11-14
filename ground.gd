
extends StaticBody2D

var in_contact=false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func triangulate_polygons(polygons:Array[PackedVector2Array]):
	var ans=[]
	for polygon in polygons:
		var triangulated_indices = Geometry2D.triangulate_polygon(polygon)
		if triangulated_indices.size()==0:
			print("TRIANGULATION FAILURE")
		#print(triangulated_indices.size())
		#print(triangulated_indices.size()/3)
		for i in range(triangulated_indices.size()/3):
			var x = triangulated_indices[3*i]
			var y = triangulated_indices[3*i + 1]
			var z = triangulated_indices[3*i + 2]
			#print(3*i,' ',3*i+1,' ',3*i+2,' ',polygon.size())
			var new_polygon = [polygon[x],polygon[y],polygon[z]]
			#print(new_polygon)
			ans.append(new_polygon)
	return ans
	
func sync():
	$Collider.set_polygon($Polygon.get_polygon())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	return





func _on_area_entered(area: Area2D) -> void:
	in_contact=true

	#print('mmm',indices)
	#call_deferred("sync")
	#sync()


func _on_area_exited(area: Area2D) -> void:
	in_contact=false
	#print("coricnon") # Replace with function body.
	pass
