class_name WorldBarrier
extends Area3D

func _ready() -> void:
	self.body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	print("Resetting body %s" % body.name)
	body.global_position = Vector3(0, 1, 0)