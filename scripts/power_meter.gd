extends Node2D

const WEAK_COLOR = Color(0.369, 0.729, 1.0, 1.0)
const STRONG_COLOR = Color(1.0, 0.145, 0.145, 1.0)

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	#draw_polygon([Vector2(-10,10), Vector2(10,10), Vector2(10,15),Vector2(-10,15)], [Color.BLACK,Color.BLACK,Color.BLACK,Color.BLACK])
	var length = %Player.launch_mode_power * 6

	var power_t = inverse_lerp(
		%Player.launch_mode_min_power, %Player.launch_mode_max_power, %Player.launch_mode_power
	)
	var color = WEAK_COLOR.lerp(STRONG_COLOR, power_t)

	var end_point = Vector2(-15 + length, 7)
	draw_line(Vector2(-15, 7), end_point, color, 6)
	draw_multiline([Vector2(-15,4), Vector2(15,4), Vector2(15,4), Vector2(15,10), Vector2(15,10),Vector2(-15,10), Vector2(-15,10),Vector2(-15,4)],Color.BLACK,1)
