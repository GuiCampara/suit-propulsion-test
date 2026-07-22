extends CharacterBody2D


enum State { WALKING, LAUNCH_MODE, LAUNCHED }

const SPEED = 130.0
const JUMP_VELOCITY = -150.0

const launch_mode_max_angle = 90
const launch_mode_min_angle = 1
const launch_mode_angle_increment = 1

const launch_mode_max_power = 5
const launch_mode_min_power = 0.5
const launch_mode_power_increment = 0.1

var state: State = State.WALKING
var launch_mode_angle = 45
var launch_mode_power = 0.5

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func get_facing_direction() -> int:
	return -1 if animated_sprite_2d.flip_h else 1

func _change_state(new_state: State) -> void:
	state = new_state
	match state:
		State.WALKING:
			#%StatsLabel.hide()
			%AngleLine.hide()
			#%PowerMeter.hide()
		State.LAUNCH_MODE:
			launch_mode_angle = 45
			launch_mode_power = 0.5
			animated_sprite_2d.play("jump")
			#%StatsLabel.show()
			%AngleLine.show()
			#%PowerMeter.show()
			velocity.x = 0
			_update_stats_label()
		State.LAUNCHED:
			#%StatsLabel.hide()
			%AngleLine.hide()
			#%PowerMeter.hide()
			animated_sprite_2d.play("fly")

func _update_stats_label() -> void:
	var launch_mode_power_display_value = launch_mode_power * 2
	var power_text = "Power: " + str(snapped(launch_mode_power_display_value, 0.1))
	var angle_text = "Angle: " + str(launch_mode_angle) + "°"
	%StatsLabel.text = power_text + "\n" + angle_text

func _unhandled_input(event: InputEvent) -> void:
	match state:
		State.WALKING:
			_walking_input(event)
		State.LAUNCH_MODE:
			_launch_mode_input(event)
		State.LAUNCHED:
			pass

func _walking_input(event: InputEvent) -> void:
	if event.is_action_pressed("launch_mode") and is_on_floor():
		_change_state(State.LAUNCH_MODE)
		return

	if event.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

func _launch_mode_input(event: InputEvent) -> void:
	if event.is_action_pressed("launch_mode"):
		_change_state(State.WALKING)
		return

	if event.is_action_pressed("increase_angle", true):
		launch_mode_angle += launch_mode_angle_increment
	if event.is_action_pressed("decrease_angle", true):
		launch_mode_angle -= launch_mode_angle_increment
	#if event.is_action_pressed("increase_power", true):
	#	launch_mode_power += launch_mode_power_increment
	#if event.is_action_pressed("decrease_power", true):
	#	launch_mode_power -= launch_mode_power_increment
	if event.is_action_pressed("launch", true):
		launch_mode_power += launch_mode_power_increment
	launch_mode_power = clamp(launch_mode_power, launch_mode_min_power, launch_mode_max_power)
	launch_mode_angle = clamp(launch_mode_angle, launch_mode_min_angle, launch_mode_max_angle)

	_update_stats_label()
	
	if event.is_action_released("launch",false):
		var angle = deg_to_rad(launch_mode_angle)
		var direction = Vector2.from_angle(angle)

		velocity.x = direction.x * launch_mode_power * SPEED * get_facing_direction()
		velocity.y = direction.y * launch_mode_power * SPEED * -1

		_change_state(State.LAUNCHED)

	#if event.is_action_pressed("launch"):
	#	var angle = deg_to_rad(launch_mode_angle)
	#	var direction = Vector2.from_angle(angle)
#
#		velocity.x = direction.x * launch_mode_power * SPEED * get_facing_direction()
#		velocity.y = direction.y * launch_mode_power * SPEED * -1
#
#		_change_state(State.LAUNCHED)

func _physics_process(delta: float) -> void:
	match state:
		State.WALKING:
			_walking_physics()
		State.LAUNCH_MODE, State.LAUNCHED:
			pass

	velocity += get_gravity() * delta

	if velocity.x > 0:
		animated_sprite_2d.flip_h = false
	elif velocity.x < 0:
		animated_sprite_2d.flip_h = true

	move_and_slide()

	if state == State.LAUNCHED and is_on_floor() and velocity.y >= 0:
		_change_state(State.WALKING)

func _walking_physics() -> void:
	var direction := Input.get_axis("move_left", "move_right")

	if is_on_floor():
		if direction == 0:
			animated_sprite_2d.play("idle")
		else:
			animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("jump")

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
