@tool
extends Control
var possibleEdgesSize = range(2, 10) # center for cancel and 1 cube is useless
var lineWidth = 3
@export var bigRadius: int = 250
@export var smallRadius: int = 80
@export var baseColor: Color

var edgeSize = 0

func _draw():
	draw_circle(Vector2.ZERO, bigRadius, baseColor)
	draw_arc(Vector2.ZERO, smallRadius, 0, 2*PI, 64, Color.DARK_GOLDENROD, lineWidth, true)
	drawParts()
	var cancelButtonLength = 0.7
	
	draw_line(
		Vector2.from_angle(-PI/4) * smallRadius * cancelButtonLength, 
		Vector2.from_angle(3*PI/4) * smallRadius* cancelButtonLength, 
		Color.DARK_GOLDENROD, 
		lineWidth
	)
	
	draw_line(
		Vector2.from_angle(PI/4) * smallRadius * cancelButtonLength, 
		Vector2.from_angle(-3*PI/4) * smallRadius* cancelButtonLength, 
		Color.DARK_GOLDENROD, 
		lineWidth
	)

func drawParts():
	var edgeSizeLabelRadius = (bigRadius - smallRadius) / 2 + smallRadius
	var angle = -(2 * PI) / (len(possibleEdgesSize) + 1)
	var offset = -10
	
	for i in range(len(possibleEdgesSize) + 1):
		var angleI = angle * i - PI/2
		var posAngle = Vector2.from_angle(angleI)
		draw_line(posAngle*smallRadius, posAngle*bigRadius, Color.DARK_GOLDENROD, lineWidth)
		
		if edgeSize - 2 == i:
			var smallArc = PackedVector2Array()
			var bigArc = PackedVector2Array()
			var pointsPerArc = 32
			
			for j in range(pointsPerArc + 1):
				var pointAngle = -(angleI + j*angle/pointsPerArc)
				smallArc.append(smallRadius*Vector2.from_angle(2*PI - pointAngle))
				bigArc.append(bigRadius*Vector2.from_angle(2*PI - pointAngle))
				pass
			
			smallArc.reverse()
			draw_polygon(smallArc + bigArc, PackedColorArray([Color.CRIMSON]))
			
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
	
	if edgeSize == 0:
		draw_circle(Vector2.ZERO, smallRadius, Color.CRIMSON)

func _process(_delta: float):
	var mousePosition = get_local_mouse_position()
	var mouseRadius = mousePosition.length()
	
	edgeSize = 0
	
	if mouseRadius > smallRadius:
		var tmp = int(floor(((-mousePosition.angle() - PI/2)/(2 * PI)) * (len(possibleEdgesSize) + 1)))
		#print((tmp + len(possibleEdgesSize) + 1)%(len(possibleEdgesSize) + 1) + 2)
		edgeSize = (tmp + len(possibleEdgesSize) + 1)%(len(possibleEdgesSize) + 1) + 2
	
	queue_redraw()

func close():
	hide()
	return edgeSize
