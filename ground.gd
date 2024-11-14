
extends Area2D

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
	var areas = get_overlapping_areas()
	for area in areas:
		# Get the main polygon points array and individual polygon index lists for the current node
		var polygon_points_a: PackedVector2Array = $Polygon.get_polygon()
		var polygons_a: Array = $Polygon.get_polygons()  # List of indices into polygon_points_a

		# Convert main polygon points of the current node to global space
		var global_polygon_points_a = Array(polygon_points_a).map(func(p): return to_global(p))
		
		# Get polygon points and polygons (indices) for the overlapping area
		var polygon_points_b: PackedVector2Array = area.get_node("Polygon").get_polygon()
		var polygons_b: Array = area.get_node("Polygon").get_polygons()  # List of indices into polygon_points_b

		# Prepare list for all clipped polygons
		var all_clipped_polygons = []

		# If polygons_a is empty, use polygon_points_a directly as a single polygon
		if polygons_a.size() == 0:
			var polygon_a = global_polygon_points_a
			for indices_b in polygons_b:
				# If polygons_b is non-empty, use indices to build polygon_b
				var polygon_b = indices_b.map(func(i): return area.to_global(polygon_points_b[i]))
				var clipped_polygons = Geometry2D.clip_polygons(polygon_a, polygon_b)
				all_clipped_polygons += clipped_polygons
			# If polygons_b is also empty, use polygon_points_b directly as a single polygon
			if polygons_b.size() == 0:
				var polygon_b = Array(polygon_points_b).map(func(p): return area.to_global(p))
				all_clipped_polygons += Geometry2D.clip_polygons(polygon_a, polygon_b)
		else:
			# Otherwise, process each polygon in polygons_a using the indices
			for indices_a in polygons_a:
				var polygon_a = Array(indices_a).map(func(i): return global_polygon_points_a[i])
				
				# If polygons_b is empty, fallback to using polygon_points_b directly
				if polygons_b.size() == 0:
					var polygon_b = Array(polygon_points_b).map(func(p): return area.to_global(p))
					all_clipped_polygons += Geometry2D.clip_polygons(polygon_a, polygon_b)
				else:
					# Process each polygon in polygons_b using the indices
					for indices_b in polygons_b:
						var polygon_b = Array(indices_b).map(func(i): return area.to_global(polygon_points_b[i]))
						var clipped_polygons = Geometry2D.clip_polygons(polygon_a, polygon_b)
						all_clipped_polygons += clipped_polygons

		# Flatten the clipped polygons for setting in $Polygon
		var pti = {}
		var new_polygon = []
		var i = 0
		var newps = []

		for p in all_clipped_polygons:
			var newp = []
			for po in p:
				new_polygon.append(to_local(po))
				pti[po] = i
				i += 1
				newp.append(po)
			newps.append(newp)
		
		# Update the $Polygon with new points and polygon structure
		$Polygon.set_polygon(new_polygon)

		# Create indices for each new polygon set
		var indices = []
		for p in newps:
			var pi = []
			for po in p:
				pi.append(pti[po])
			indices.append(PackedInt32Array(pi))
		
		$Polygon.set_polygons(indices)

	# $Collider.set_polygon($Polygon.get_polygon())
	# sync()
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
