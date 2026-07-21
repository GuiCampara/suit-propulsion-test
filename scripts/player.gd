extends CharacterBody2D


const SPEED = 130.0
const JUMP_VELOCITY = -300.0

# flecha pra UI
# state machine pro personagem
# atrelar a label ao state launch mode

var launch_mode_active = false
var is_launched = false

var launch_mode_angle = 45
const launch_mode_max_angle = 90
const launch_mode_min_angle = 1
const launch_mode_angle_increment = 1

var launch_mode_power = 3
const launch_mode_max_power = 5
const launch_mode_min_power = 0.5
const launch_mode_power_increment = 0.1

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("launch_mode"):
		if is_on_floor():
			launch_mode_angle = 45
			launch_mode_power = 3
			if launch_mode_active:
				launch_mode_active = false
				%StatsLabel.hide()
			else:
				launch_mode_active = true
				animated_sprite_2d.play("jump")
				%StatsLabel.show()
				velocity.x = 0
				
	if launch_mode_active and is_on_floor():
		animated_sprite_2d.play("jump")
		if event.is_action_pressed("increase_angle", true):
			launch_mode_angle += launch_mode_angle_increment
		if event.is_action_pressed("decrease_angle", true):
			launch_mode_angle -= launch_mode_angle_increment
		if event.is_action_pressed("increase_power", true):
			launch_mode_power += launch_mode_power_increment
		if event.is_action_pressed("decrease_power", true):
			launch_mode_power -= launch_mode_power_increment
		launch_mode_power = clamp(launch_mode_power, launch_mode_min_power, launch_mode_max_power)
		launch_mode_angle = clamp(launch_mode_angle, launch_mode_min_angle, launch_mode_max_angle)
		
		var launch_mode_power_display_value = (launch_mode_power) * 2
		%StatsLabel.text = "Power: " + str(snapped(launch_mode_power_display_value,0.1)) + "\nAngle: " + str(launch_mode_angle) + "°"
		
		if event.is_action_pressed("launch"):
			var angle = deg_to_rad(launch_mode_angle)
			var direction = Vector2.from_angle(angle)
			animated_sprite_2d.play("fly")
			
			var animated_sprite_2d_direction =  1 if animated_sprite_2d.flip_h == false else -1
			
			print("launched")
			is_launched = true
			launch_mode_active = false
			%StatsLabel.hide()
			
			velocity.x = direction.x * launch_mode_power * SPEED * animated_sprite_2d_direction
			velocity.y = direction.y * launch_mode_power * SPEED * -1
			print(launch_mode_power)
			print(velocity)
		
	if event.is_action_pressed("jump"):
		if is_launched:
			return
			
		if is_on_floor():
			velocity.y = JUMP_VELOCITY

func _physics_process(delta: float) -> void:
	if is_on_floor():
		if velocity.y >= 0:
			if is_launched:
				is_launched = false
	
	if !launch_mode_active:
		if !is_launched:
			var direction := Input.get_axis("move_left", "move_right")
			if is_on_floor():
				is_launched = false
				if direction == 0:
					animated_sprite_2d.play("idle")
				else:
					animated_sprite_2d.play("run")
			else: animated_sprite_2d.play("jump")
				
			if direction:
				velocity.x = direction * SPEED
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
	
	velocity += get_gravity() * delta
		
	if velocity.x > 0:
		animated_sprite_2d.flip_h = false
	elif velocity.x < 0:
		animated_sprite_2d.flip_h = true

	move_and_slide()
