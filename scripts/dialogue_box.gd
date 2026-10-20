class_name DialogueBox
extends CanvasLayer

@export_category("Configuración de Texto")
@export_multiline var texto_a_mostrar: String = "¡Hola! Ahora puedes editar mi estilo desde el Inspector."
@export_range(0.001, 0.2, 0.001) var velocidad_letra: float = 0.05

@export_category("Estilo Visual")
@export var fuente_custom: Font
@export var tamano_letra: int = 24
@export var color_texto: Color = Color.WHITE

# Referencias directas a componentes de la UI
@onready var texto_label: RichTextLabel = $MarginContainer/Panel/RichTextLabel
@onready var contenedor_opciones: HBoxContainer = $MarginContainer/Panel/ContenedorOpciones
@onready var boton_si: Button = $MarginContainer/Panel/ContenedorOpciones/BotonSi
@onready var boton_no: Button = $MarginContainer/Panel/ContenedorOpciones/BotonNo

# Variables de control de estado y concurrencia de diálogos
var current_sender: Object = null
var dialogue_id: int = 0
var esta_escribiendo: bool = false
var callback_respuesta: Callable

func _ready() -> void:
	# Espera un frame de físicas para asegurar la inicialización correcta del árbol de nodos.
	await get_tree().process_frame
	
	_inicializar_componentes_ui()
	_conectar_senales()
	
	# Ejecución de texto inicial por defecto si está configurado en el Inspector.
	if not texto_a_mostrar.is_empty():
		iniciar_dialogo(texto_a_mostrar)

# Configura las propiedades tipográficas y el estado inicial de visibilidad de la UI.
func _inicializar_componentes_ui() -> void:
	_aplicar_estilo_personalizado()
	
	if contenedor_opciones:
		contenedor_opciones.visible = false

# Aplica los overrides de tema tipográfico y color al RichTextLabel.
func _aplicar_estilo_personalizado() -> void:
	texto_label.remove_theme_color_override("default_color")
	texto_label.add_theme_font_size_override("normal_font_size", tamano_letra)
	
	if fuente_custom:
		texto_label.add_theme_font_override("normal_font", fuente_custom)
	
	texto_label.add_theme_color_override("default_color", color_texto)
	texto_label["theme_override_colors/default_color"] = color_texto
	texto_label.self_modulate = color_texto

# Establece las conexiones de eventos con los botones de opción y el bus global de señales.
func _conectar_senales() -> void:
	if boton_si and not boton_si.pressed.is_connected(_on_boton_si_pressed):
		boton_si.pressed.connect(_on_boton_si_pressed)
		
	if boton_no and not boton_no.pressed.is_connected(_on_boton_no_pressed):
		boton_no.pressed.connect(_on_boton_no_pressed)
	
	if not SignalBusText.mostrar_dialogo.is_connected(_on_mostrar_dialogo_recibido):
		SignalBusText.mostrar_dialogo.connect(_on_mostrar_dialogo_recibido)
		
	if not SignalBusText.mostrar_dialogo_con_opciones.is_connected(_on_mostrar_dialogo_con_opciones_recibido):
		SignalBusText.mostrar_dialogo_con_opciones.connect(_on_mostrar_dialogo_con_opciones_recibido)

	if not SignalBusText.limpiar_dialogo.is_connected(_on_limpiar_dialogo_recibido):
		SignalBusText.limpiar_dialogo.connect(_on_limpiar_dialogo_recibido)

# Callback para solicitudes de diálogo estándar sin opciones.
func _on_mostrar_dialogo_recibido(sender: Object, nuevo_texto: String) -> void:
	# Rechaza la solicitud si el mismo emisor intenta enviar texto mientras aún se está escribiendo (anti-spam).
	if sender == current_sender and esta_escribiendo:
		return
	
	current_sender = sender
	iniciar_dialogo(nuevo_texto, false, Callable())
	# Nota: El audio se gestiona de forma controlada en el emisor para evitar efectos secundarios en textos de cancelación.

# Callback para solicitudes de diálogo con opciones de decisión.
func _on_mostrar_dialogo_con_opciones_recibido(sender: Object, nuevo_texto: String, on_decision: Callable) -> void:
	# Rechaza la solicitud si el mismo emisor interactúa de forma concurrente durante la escritura.
	if sender == current_sender and esta_escribiendo:
		return
	
	current_sender = sender
	iniciar_dialogo(nuevo_texto, true, on_decision)

# Callback para limpiar y ocultar la caja de texto externamente.
func _on_limpiar_dialogo_recibido() -> void:
	dialogue_id += 1 # Invalida cualquier corrutina de escritura activa
	esta_escribiendo = false
	current_sender = null
	texto_label.text = ""
	texto_label.visible_characters = 0
	
	if contenedor_opciones:
		contenedor_opciones.visible = false

# Gestiona la renderización progresiva del texto (efecto máquina de escribir) con control de ID.
func iniciar_dialogo(nuevo_texto: String, pedir_opciones: bool = false, on_decision: Callable = Callable()) -> void:
	dialogue_id += 1
	var mi_id := dialogue_id
	
	callback_respuesta = on_decision
	
	if contenedor_opciones:
		contenedor_opciones.visible = false
	
	esta_escribiendo = true
	texto_label.text = ""
	texto_label.visible_characters = 0
	texto_label.text = nuevo_texto
	
	var total_caracteres := texto_label.get_total_character_count()
	for i in range(total_caracteres + 1):
		if mi_id != dialogue_id:
			return # Interrumpe la corrutina si se solicita un nuevo diálogo concurrentemente.
			
		texto_label.visible_characters = i
		await get_tree().create_timer(velocidad_letra).timeout
	
	if mi_id == dialogue_id:
		esta_escribiendo = false
		if pedir_opciones and contenedor_opciones:
			contenedor_opciones.visible = true

# Maneja la pulsación del botón afirmativo.
func _on_boton_si_pressed() -> void:
	if contenedor_opciones:
		contenedor_opciones.visible = false
	
	if callback_respuesta.is_valid():
		callback_respuesta.call(true)

# Maneja la pulsación del botón negativo.
func _on_boton_no_pressed() -> void:
	if contenedor_opciones:
		contenedor_opciones.visible = false
	
	if callback_respuesta.is_valid():
		callback_respuesta.call(false)
