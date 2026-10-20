extends AreaItem

@onready var node: Node = $"."

func _ready() -> void:
	super._ready()
	
	clicked.connect(_on_object_clicked)
	
func _on_object_clicked() -> void:
	_mostrar_texto_y_opcion()

func _mostrar_texto_y_opcion() -> void:
	# 1. Primero muestras el texto informativo
	SignalBusText.mostrar_dialogo.emit(self, "Una puerta que lleva a otra habitación.")
	
	# 2. Opcionalmente, si tu SignalBusText o sistema de diálogos permite invocar una opción de Sí/No 
	# justo después, puedes gestionarlo mediante una señal o un callback. 
	# Ejemplo genérico de cómo estructurarlo con tu bus:
	# SignalBusText.mostrar_opcion_decision.emit("¿Deseas pasar?", Callable(self, "_on_respuesta_decision"))

# Esta función recibiría el resultado cuando el jugador pulse Sí o No en la interfaz
func _on_respuesta_decision(quiere_pasar: bool) -> void:
	if quiere_pasar:
		cambiar_escena()
	else:
		print("El jugador decidió quedarse.")
