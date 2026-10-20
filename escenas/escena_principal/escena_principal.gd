extends Node2D

# Carga tu imagen de la mano (ajusta la ruta según dónde la tengas guardada)
const HAND_CURSOR = preload("res://assets/cursor/ojo/ojo.png")

# Referencia al nodo de la habitación inicial en el árbol (ej. HabitacionPrueba)
@onready var habitacion_actual: Node = $HabitacionPrueba

func _ready() -> void:
	# 1. Configuramos el cursor de la mano para todo el juego al iniciar la escena principal
	# El último parámetro (Vector2) es el "hotspot" o punto exacto de clic (puedes ajustarlo)
	Input.set_custom_mouse_cursor(HAND_CURSOR, Input.CURSOR_POINTING_HAND, Vector2(4, 2))
	
	# Nos conectamos a la señal global de cambio de habitación
	SignalBusText.cambiar_habitacion_solicitada.connect(_on_cambiar_habitacion_solicitada)

func _on_cambiar_habitacion_solicitada(ruta_escena: String) -> void:
	if ruta_escena.is_empty():
		return
	
	# 1. Cargamos el archivo de la nueva escena de la habitación
	var nueva_escena_packed = load(ruta_escena)
	if not nueva_escena_packed:
		print("Error: No se pudo cargar la escena: ", ruta_escena)
		return
		
	# 2. Instanciamos la nueva habitación en memoria
	var nueva_habitacion = nueva_escena_packed.instantiate()
	
	# 3. Borramos la habitación anterior de forma segura del juego
	if habitacion_actual and is_instance_valid(habitacion_actual):
		habitacion_actual.queue_free()
		
	# 4. Añadimos la nueva habitación como hija de EscenaPrincipal
	add_child(nueva_habitacion)
	
	# 5. Opcional pero recomendado: Movemos la habitación al principio del orden de hijos 
	# para que la Cámara y la DialogueBox (que están debajo en el árbol) queden dibujadas ENCIMA.
	move_child(nueva_habitacion, 0)
	
	# 6. Actualizamos la referencia de la habitación actual
	habitacion_actual = nueva_habitacion
