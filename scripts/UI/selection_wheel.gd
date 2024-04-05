@tool
extends Control
var possibleEdgesSize = range(2, 10) # center for cancel and 1 cube is useless
var lineWidth = 3
@export var bigRadius: int = 250
@export var smallRadius: int = 80
@export var baseColor: Color

func _draw():
	draw_circle(Vector2.ZERO, bigRadius, baseColor)
	draw_arc(Vector2.ZERO, smallRadius, 0, 2*PI, 64, Color.DARK_GOLDENROD, lineWidth, true)
	custom_drawLines()

func custom_drawLines():
	var edgeSizeLabelRadius = (bigRadius - smallRadius) / 2 + smallRadius
	var angle = -(2 * PI) / (len(possibleEdgesSize) + 1)
	var offset = -10
	
	for i in range(len(possibleEdgesSize) + 1):
		var angleI = angle * i - PI/2
		var posAngle = Vector2.from_angle(angleI)
		draw_line(posAngle*smallRadius, posAngle*bigRadius, Color.DARK_GOLDENROD, lineWidth)
		draw_string(
			ThemeDB.fallback_font, 
			Vector2(
				cos(angleI + angle/2) * edgeSizeLabelRadius + offset, 
				sin(angleI + angle/2) * edgeSizeLabelRadius - offset
				), 
			str(i + 2),
			HORIZONTAL_ALIGNMENT_CENTER,
			-1, 
			32
			)

func _process(_delta: float):
	queue_redraw()
