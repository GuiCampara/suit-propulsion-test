extends Node2D

const WEAK_COLOR = Color(0.367, 0.73, 1.0, 0.424)
const STRONG_COLOR = Color(1.0, 0.145, 0.145, 0.616)

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var angle = deg_to_rad(%Player.launch_mode_angle)
	var direction = Vector2.from_angle(angle)
	var length = %Player.launch_mode_power * 10 + 20

	var power_t = inverse_lerp(
		%Player.launch_mode_min_power, %Player.launch_mode_max_power, %Player.launch_mode_power
	)
	var color = WEAK_COLOR.lerp(STRONG_COLOR, power_t)

	var end_point = 50* direction * Vector2(%Player.get_facing_direction(), -1)
	draw_line(Vector2(0, -4), end_point, color, 1)
