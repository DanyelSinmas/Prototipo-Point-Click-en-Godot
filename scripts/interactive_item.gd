class_name InteractiveItem
extends AreaItem

@export_group("Configuración de Interacción")
@export_multiline var descripcion_objeto: String = "Un objeto sin describir."
@export var requiere_confirmacion: bool = false

func _ready() -> void:
	super._ready()
	clicked.connect(_on_object_clicked)

# Maneja el evento de clic, decidiendo si muestra texto plano o abre el diálogo con opciones de confirmación.
func _on_object_clicked() -> void:
	if requiere_confirmacion:
		SignalBusText.mostrar_dialogo_con_opciones.emit(
			self,
			descripcion_objeto,
			Callable(self, "_on_respuesta_jugador")
		)
	else:
		SignalBusText.mostrar_dialogo.emit(self, descripcion_objeto)

# Procesa la respuesta booleana obtenida del sistema de diálogo (true = Sí, false = No).
func _on_respuesta_jugador(aceptado: bool) -> void:
	if aceptado:
		_accion_objeto()
	else:
		print("El jugador declinó la acción en el nodo: ", name)

# Método abstracto destinado a ser sobrescrito por subclases concretas para ejecutar lógica personalizada.
func _accion_objeto() -> void:
	pass
