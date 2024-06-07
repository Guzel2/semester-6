extends Camera2D

@export var speed = 400

func _process(delta):
	var dir = Vector2(0, 0)
	
	if Input.is_action_pressed("up"):
		dir.y += -1
	if Input.is_action_pressed("down"):
		dir.y += 1
	if Input.is_action_pressed("left"):
		dir.x += -1
	if Input.is_action_pressed("right"):
		dir.x += 1
	
	dir = dir.normalized()
	
	position += dir * delta * speed

