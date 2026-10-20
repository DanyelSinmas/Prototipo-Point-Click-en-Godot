class_name InteractiveItem
extends AreaItem

@export_group("Configuración de Interacción")
@export_multiline var descripcion_objeto: String = "Un objeto sin describir."
@export var requiere_confirmacion: bool = false

@export_group("Audio")
@export var sound_effect: AudioStream = null

var audio_player: AudioStreamPlayer = null

func _ready() -> void:
	super._ready()
	_setup_audio_player()
	clicked.connect(_on_object_clicked)

# Configura e instancia un único nodo reproductor de audio interno enlazado al bus de efectos.
func _setup_audio_player() -> void:
	audio_player = AudioStreamPlayer.new()
	audio_player.name = "AudioStreamPlayer"
	audio_player.bus = "Sfx"
	add_child(audio_player)

# Reproduce el efecto de sonido configurado si se cumple la condición requerida y el reproductor está libre.
func reproducir_sonido(condicion: bool = true) -> void:
	if not condicion:
		return
	
	if sound_effect and audio_player:
		audio_player.stream = sound_effect
		audio_player.play()

# Maneja el evento de clic, decidiendo si muestra texto plano o abre el diálogo con opciones.
func _on_object_clicked() -> void:
	if requiere_confirmacion:
		SignalBusText.mostrar_dialogo_con_opciones.emit(
			self,
			descripcion_objeto,
			Callable(self, "_on_respuesta_jugador")
		)
	else:
		# Filtro anti-spam: omite la interacción si el canal de audio se encuentra ocupado.
		if audio_player and audio_player.playing:
			return
		
		reproducir_sonido(true)
		SignalBusText.mostrar_dialogo.emit(self, descripcion_objeto)

# Procesa la respuesta booleana obtenida del sistema de diálogo (true = Sí, false = No).
func _on_respuesta_jugador(aceptado: bool) -> void:
	reproducir_sonido(aceptado)
	
	if aceptado:
		_accion_objeto()
	else:
		print("El jugador declinó la acción en el nodo: ", name)

# Método abstracto destinado a ser sobrescrito por subclases concretas para ejecutar lógica personalizada.
func _accion_objeto() -> void:
	pass
