extends Node2D
const COLLISION_MASK_CARD = 1
const COLLISION_MASK_CARD_SLOT = 2
const DEFAULT_CARD_MOVE_SPEED = 0.1
const DEFAULT_CARD_SCALE = 0.8
const CARD_BIGER_SCALE = 0.85
const CARD_SMALLER_SCALE = 0.3

var screen_size 
var card_being_dragged
var is_hovering_on_card
var player_hand_refence

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport().size
	player_hand_refence = $"../PlayerHand"
	$"../InputManager".connect("left_mouse_button_released",on_left_click_released)


func _physics_process(delta: float) -> void:
	# 如果卡牌拖动，将鼠标坐标赋给卡牌
	if card_being_dragged:
		var mouse_position = get_global_mouse_position()
		card_being_dragged.position = Vector2(clamp(mouse_position.x,0,screen_size.x),
		clamp(mouse_position.y,0,screen_size.y))

func _input(event):
	# 点击左键触发事件
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed: # 按下鼠标左键触发事件
			# 检测卡牌
			var card = raycast_check_for_card()
			if card:
				start_drag(card)
		else:
			if card_being_dragged:
				finish_drag()

func start_drag(card):
	card_being_dragged = card
	card.scale = Vector2(DEFAULT_CARD_SCALE,DEFAULT_CARD_SCALE)
	
func finish_drag():
	card_being_dragged.scale = Vector2(CARD_BIGER_SCALE,CARD_BIGER_SCALE)
	var card_slot_found = raycast_check_for_card_slot()
	if card_slot_found and not card_slot_found.card_in_slot:
		card_being_dragged.scale = Vector2(CARD_SMALLER_SCALE,CARD_SMALLER_SCALE)
		card_being_dragged.z_index = -1
		is_hovering_on_card = false
		card_being_dragged.card_slot_card_is_in = card_slot_found
		# 卡牌已放入到空卡槽中
		player_hand_refence.remove_card_from_hand(card_being_dragged)
		card_being_dragged.position = card_slot_found.position
		card_being_dragged.get_node("Area2D/CollisionShape2D").disabled = true
	else:
		player_hand_refence.add_card_to_hand(card_being_dragged,DEFAULT_CARD_MOVE_SPEED)
	card_being_dragged = null
	


func connect_card_signals(card):
	card.connect("hovered",on_hovered_over_card)
	card.connect("hovered_off",on_hovered_off_card)

func on_left_click_released():
	if card_being_dragged:
		finish_drag()

# 鼠标悬浮在卡片
func on_hovered_over_card(card):
	if !is_hovering_on_card:
		is_hovering_on_card = true
		highlight_card(card,true)

# 鼠标离开卡片
func on_hovered_off_card(card):
	if !card.card_slot_card_is_in && !card_being_dragged:
		highlight_card(card,false)
		# 检查悬浮卡片是否到了另一张卡片上
		var new_card_hovered = raycast_check_for_card()
		if new_card_hovered:
			highlight_card(new_card_hovered,true)
		else:
			is_hovering_on_card = false

# 卡片高亮
func highlight_card(card,hovered):
	if hovered:
		card.scale = Vector2(CARD_BIGER_SCALE,CARD_BIGER_SCALE)
		card.z_index = 2
	else:
		card.scale = Vector2(DEFAULT_CARD_SCALE,DEFAULT_CARD_SCALE)
		card.z_index = 1	


func raycast_check_for_card():
	# 设置射线投射，点击时返回光标下的东西
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	# 获取全局鼠标位置，确保碰撞区域为真，因为我们卡牌碰撞是2D区域，碰撞遮罩设为1
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD
	# [{ "rid": RID(4440996184065), "collider_id": 29695673685, "collider": Area2D:<Area2D#29695673685>, "shape": 0 }]
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		# 【BUG 01】修复光标放在多张卡片上，左键点击，会拖动一张随机卡片，应为最上面的卡片
		return get_card_with_hight_z_index(result);
	return null

func raycast_check_for_card_slot():
	# 设置射线投射，点击时返回光标下的东西
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	# 获取全局鼠标位置，确保碰撞区域为真，因为我们卡牌碰撞是2D区域，碰撞遮罩设为1
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD_SLOT
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		# 【BUG 01】修复光标放在多张卡片上，左键点击，会拖动一张随机卡片，应为最上面的卡片
		return result[0].collider.get_parent();
	return null	


# [Fix BUG 01] 通过选取拥有z_index最大的一张，保证为最上面的卡片
func get_card_with_hight_z_index(cards):
	# 	假设传入的卡牌有最高的z
	var hightest_z_card = cards[0].collider.get_parent()
	var hightest_z_index = hightest_z_card.z_index
	for i in range(1,cards.size()):
		var current_card = cards[i].collider.get_parent()
		if current_card.z_index > hightest_z_index:
			hightest_z_card = current_card
			hightest_z_index = current_card.z_index
	return hightest_z_card
