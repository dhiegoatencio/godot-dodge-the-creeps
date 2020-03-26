extends Area2D
signal hit

export var speed = 400 # how fast the player will move (pixel/sec)

var screen_size # size of the game window
var target = Vector2() # add this variable to hold the clicked position

func _ready():
	hide()
	screen_size = get_viewport_rect().size

func start(pos):
	position = pos
	target = pos # initial target is the start position
	show()
	$CollisionShape2D.disabled = false

func _input(event): # change the target whenever a touch event happens
	if event is InputEventScreenTouch and event.is_pressed():
		target = event.position

func _process(delta):
	var velocity = Vector2() # the player moviment vector

	# move towards the target and stop when close
	if position.distance_to(target) > 10:
		velocity = (target - position).normalized() * speed
	else:
		velocity = Vector2()

	# if Input.is_action_pressed("ui_right"):
	# 	velocity.x += 1
	# if Input.is_action_pressed("ui_left"):
	# 	velocity.x -= 1
	# if Input.is_action_pressed("ui_down"):
	# 	velocity.y += 1
	# if Input.is_action_pressed("ui_up"):
	# 	velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite.play()
	else:
		$AnimatedSprite.stop()

	position += velocity * delta
	# We still need to clamp the player's position here because on devices that don't
	# match your game's aspect ratio, Godot will try to maintain it as much as possible
	# by creating black borders, if necessary.
	# Without clamp(), the player would be able to move under those borders.
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)

	# animation change
	if velocity.x != 0:
		$AnimatedSprite.animation = "right"
		$AnimatedSprite.flip_v = false
		# See the note below about boolean assignment
		$AnimatedSprite.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite.animation = "up"
		$AnimatedSprite.flip_v = velocity.y > 0


func _on_Player_body_entered(body):
	hide()
	emit_signal("hit")
	$CollisionShape2D.set_deferred("disabled", true)

