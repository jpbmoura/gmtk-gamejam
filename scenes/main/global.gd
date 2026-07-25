extends Node

var herb_count: int = 0

func add_herb(val:int = 1):
	herb_count += val
	
func remove_herb(val:int = 1):
	if herb_count - val < 0:
		herb_count = 0
		pass
	herb_count -= val
