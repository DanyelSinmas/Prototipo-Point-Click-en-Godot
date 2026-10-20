class_name SceneTransitionItem
extends InteractiveItem

@export_group("Configuración de Navegación")
@export_file("*.tscn") var escena_destino: String
@export_multiline var mensaje_cancelacion: String = "Decidiste quedarte."

## Sobrescribe el procesamiento de la respuesta del diálogo para manejar la bifurcación de navegación.
func _on_respuesta_jugador(aceptado: bool) -> void:
	if aceptado:
		# Rama afirmativa: Reproduce el sonido de éxito exclusivamente al confirmar, 
		# limpia el diálogo y ejecuta la transición de escena.
		reproducir_sonido(true)
		SignalBusText.limpiar_dialogo.emit()
		_accion_objeto()
	else:
		# Rama negativa: El usuario eligió "No". No se reproduce sonido alguno, 
		# emitiendo únicamente la notificación textual de cancelación.
		SignalBusText.mostrar_dialogo.emit(self, mensaje_cancelacion)

## Gestiona la transición hacia el archivo de escena destino especificado en el inspector.
func _accion_objeto() -> void:
	if not escena_destino.is_empty():
		# Salvaguarda de audio: desacopla temporalmente el reproductor del árbol actual 
		# antes de liberar la escena para asegurar que el efecto de sonido concluya sin cortes abruptos.
		if audio_player and audio_player.playing:
			audio_player.get_parent().remove_child(audio_player)
			get_tree().root.add_child(audio_player)
			# Programa la liberación automática del recurso en memoria al finalizar el stream de audio.
			audio_player.finished.connect(audio_player.queue_free)
		
		SignalBusText.cambiar_habitacion_solicitada.emit(escena_destino)
	else:
		push_warning("SceneTransitionItem: No se ha asignado una ruta de escena destino válida en el nodo: ", name)
