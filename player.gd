extends CharacterBody3D


const speed = 70.0



func _physics_process(delta: float) -> void:
	
	if Input.is_action_just_pressed("forward"):
		velocity.z -= speed * delta
	
	elif Input.is_action_just_pressed("backward"):
		velocity.z += speed * delta

	if Input.is_action_just_pressed("left"):
		velocity.x -= speed * delta

	elif Input.is_action_just_pressed("right"):
		velocity.x += speed * delta
	
	move_and_slide()
