class_name SceneTransitionItem
extends InteractiveItem

@export_group("Configuración de Navegación")
@export_file("*.tscn") var escena_destino: String
@export_multiline var mensaje_cancelacion: String = "Decidiste quedarte."

# Sobrescribir el manejo de la respuesta para personalizar qué sucede al pulsar Sí o No.
func _on_respuesta_jugador(aceptado: bool) -> void:
	if aceptado:
		# 1. Si elige SÍ: Limpiar la caja de texto y solicitamos el cambio de escena.
		SignalBusText.limpiar_dialogo.emit()
		_accion_objeto()
	else:
		# 2. Si elige NO: Mostrar el texto genérico/personalizado de cancelación.
		SignalBusText.mostrar_dialogo.emit(self, mensaje_cancelacion)

# Ejecuta el cambio de escena hacia la ruta configurada.
func _accion_objeto() -> void:
	if not escena_destino.is_empty():
		SignalBusText.cambiar_habitacion_solicitada.emit(escena_destino)
	else:
		print("Advertencia: No hay un archivo .tscn asignado en el nodo: ", name)
