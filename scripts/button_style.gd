class_name BotonEstilizado
extends Button

@export_category("Configuración de Fuente")
@export var fuente_custom: Font
@export var tamano_fuente: int = 20
@export var color_texto: Color = Color.WHITE

@export_category("Configuración de Resaltado")
@export var use_glow: bool = true
@export var border_color: Color = Color("ffffff")
@export var fill_color: Color = Color(1.0, 1.0, 1.0, 0.15)
@export var pulse_duration: float = 0.8
@export var min_pulse_alpha: float = 0.4

var _is_hovered: bool = false
var pulse_tween: Tween = null
var current_alpha: float = 1.0

func _ready() -> void:
	_aplicar_estilo_fuente()
	
	mouse_entered.connect(func(): 
		_is_hovered = true 
		_start_pulse_tween()
	)
	mouse_exited.connect(func(): 
		_is_hovered = false 
		_kill_tween()
		queue_redraw()
	)

# Aplica la fuente personalizada, el tamaño y el color del texto
func _aplicar_estilo_fuente() -> void:
	if fuente_custom:
		add_theme_font_override("font", fuente_custom)
	
	add_theme_font_size_override("font_size", tamano_fuente)
	add_theme_color_override("font_color", color_texto)
	add_theme_color_override("font_hover_color", color_texto)
	add_theme_color_override("font_pressed_color", color_texto)
	add_theme_color_override("font_focus_color", color_texto)

func _draw() -> void:
	if not _is_hovered or not use_glow:
		return
		
	var local_rect = Rect2(Vector2.ZERO, size)
	
	var dynamic_fill = Color(fill_color.r, fill_color.g, fill_color.b, fill_color.a * current_alpha)
	var dynamic_border = Color(border_color.r, border_color.g, border_color.b, border_color.a * current_alpha)
	
	# Dibujar fondo translúcido y marco nítido
	draw_rect(local_rect, dynamic_fill, true)
	draw_rect(local_rect, dynamic_border, false, 2.0)

func _kill_tween() -> void:
	if pulse_tween and pulse_tween.is_valid():
		pulse_tween.kill()
		pulse_tween = null
	current_alpha = 1.0

func _start_pulse_tween() -> void:
	_kill_tween()
	current_alpha = 1.0
	
	pulse_tween = create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	var half_time = pulse_duration * 0.5
	
	pulse_tween.tween_property(self, "current_alpha", min_pulse_alpha, half_time)
	pulse_tween.tween_property(self, "current_alpha", 1.0, half_time)

func _process(_delta: float) -> void:
	if _is_hovered:
		queue_redraw()
