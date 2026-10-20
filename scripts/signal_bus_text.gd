extends Node

@warning_ignore("unused_signal")
signal mostrar_dialogo(sender: Object, texto: String)
@warning_ignore("unused_signal")
signal mostrar_dialogo_con_opciones(sender: Object, texto: String, callback: Callable)
@warning_ignore("unused_signal")
signal cambiar_habitacion_solicitada(ruta_escena: String)
@warning_ignore("unused_signal")
signal limpiar_dialogo()
