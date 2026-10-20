class_name AreaItem
extends Area2D

signal clicked
signal hover_started
signal hover_ended

@export_group("Relleno")
@export var use_fill: bool = false
@export var fill_color: Color = Color(1.0, 1.0, 1.0, 0.0)

@export_group("Resplandor (difuminado)")
@export var use_glow: bool = true
@export var glow_color: Color = Color("ffffffc0")
@export var glow_layers: int = 10
@export var glow_spread: float = 6.0

@export_group("Borde Nítido")
@export var use_border: bool = false
@export var border_color: Color = Color(1.0, 1.0, 1.0, 1.0)
@export var border_width: float = 2.0

@export_group("Parpadeo (Pulsación)")
@export var enable_pulsing: bool = true
@export var pulse_duration: float = 0.8
@export var min_pulse_alpha: float = 0.3

var is_hovered: bool = false
var highlight_container: Node2D = null
var pulse_tween: Tween = null

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	input_event.connect(_on_input_event)
	_setup_highlight_overlays()

# Escanea colisiones hijas y genera overlays gráficos procedurales.
func _setup_highlight_overlays() -> void:
	highlight_container = Node2D.new()
	highlight_container.name = "HighlightContainer"
	highlight_container.visible = false
	add_child(highlight_container)

	for child in get_children():
		if child is CollisionPolygon2D:
			_process_polygon(child.polygon, child.transform)
		elif child is CollisionShape2D:
			var points := _get_points_from_shape(child)
			if not points.is_empty():
				_process_polygon(points, child.transform)

# Extrae vértices vectoriales de formas primitivas soportadas.
func _get_points_from_shape(col_shape: CollisionShape2D) -> PackedVector2Array:
	if not col_shape.shape:
		return PackedVector2Array()

	var shape := col_shape.shape
	var points := PackedVector2Array()

	if shape is RectangleShape2D:
		var extents: Vector2 = shape.size * 0.5
		points = PackedVector2Array([
			Vector2(-extents.x, -extents.y),
			Vector2(extents.x, -extents.y),
			Vector2(extents.x, extents.y),
			Vector2(-extents.x, extents.y)
		])
	elif shape is CircleShape2D:
		const NUM_POINTS := 32
		const STEP := TAU / NUM_POINTS
		var radius: float = shape.radius
		points.resize(NUM_POINTS)
		for i in range(NUM_POINTS):
			var angle := i * STEP
			points[i] = Vector2(cos(angle), sin(angle)) * radius

	return points

# Instancia capas gráficas dentro del contenedor de resaltado.
func _process_polygon(points: PackedVector2Array, xform: Transform2D) -> void:
	if points.size() < 3:
		return

	var shared_material := CanvasItemMaterial.new()
	shared_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD

	if use_fill:
		var poly := Polygon2D.new()
		poly.polygon = points
		poly.transform = xform
		poly.color = fill_color
		poly.material = shared_material
		highlight_container.add_child(poly)

	if use_glow and glow_layers > 0:
		var alpha_step := (glow_color.a / glow_layers) * 0.35
		for i in range(glow_layers, 0, -1):
			var line := Line2D.new()
			line.closed = true
			line.points = points
			line.transform = xform
			line.joint_mode = Line2D.LINE_JOINT_ROUND
			line.material = shared_material
			line.width = i * glow_spread
			line.default_color = Color(glow_color.r, glow_color.g, glow_color.b, alpha_step)
			highlight_container.add_child(line)

	if use_border:
		var line := Line2D.new()
		line.closed = true
		line.points = points
		line.transform = xform
		line.width = border_width
		line.default_color = border_color
		line.joint_mode = Line2D.LINE_JOINT_ROUND
		line.material = shared_material
		highlight_container.add_child(line)

func _on_mouse_entered() -> void:
	is_hovered = true
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	_kill_tween()

	if highlight_container:
		highlight_container.visible = true
		highlight_container.modulate.a = 1.0
		if enable_pulsing and highlight_container.get_child_count() > 0:
			_start_pulse_tween()

	hover_started.emit()

func _on_mouse_exited() -> void:
	is_hovered = false
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	_kill_tween()

	if highlight_container:
		highlight_container.visible = false
		highlight_container.modulate.a = 1.0

	hover_ended.emit()

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit()

func _kill_tween() -> void:
	if pulse_tween and pulse_tween.is_valid():
		pulse_tween.kill()
		pulse_tween = null

func _start_pulse_tween() -> void:
	var half_time := pulse_duration * 0.8
	pulse_tween = create_tween().set_loops()

	pulse_tween.tween_property(highlight_container, "modulate:a", min_pulse_alpha, half_time)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_IN_OUT)

	pulse_tween.tween_property(highlight_container, "modulate:a", 1.0, half_time)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_IN_OUT)
