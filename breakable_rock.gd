extends StaticBody2D


func take_damage(amount: int) -> void:
	#particle effect or dust cloud
	
	print("A solid boulder shattered into dust!")
	
	queue_free()
