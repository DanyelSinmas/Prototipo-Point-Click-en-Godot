class_name CollectibleItem
extends InteractiveItem

@export_group("Configuración de Inventario")
@export var id_item: String = "item_generico"
@export var sprite_item: Texture2D

# Sobrescribe la acción para implementar la lógica de recolección en futuras fases.
func _accion_objeto() -> void:
	print("Objeto recogido: ", id_item)
	# TODO: Añadir lógica de inventario global y eliminar o ocultar nodo de la escena.
	queue_free()
