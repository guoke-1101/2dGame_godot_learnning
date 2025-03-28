extends Node2D


signal hovered
signal hovered_off
var hand_position
var card_slot_card_is_in


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 所有的卡牌都必须是CardManager的子节点
	get_parent().connect_card_signals(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered",self)


func _on_area_2d_mouse_exited() -> void:
	emit_signal("hovered_off",self)
