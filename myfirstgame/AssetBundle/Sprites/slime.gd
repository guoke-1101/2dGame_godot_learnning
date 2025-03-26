extends Area2D


@export var slime_speed : float = -30;
var is_game_over : bool = false;
@export var animator : AnimatedSprite2D
var is_dead : bool = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if not is_dead:
		position += Vector2(slime_speed,0) * delta
	if position.x < -267:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		body.game_over()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("bullet"):
		$AudioStreamPlayer2D.play()
		animator.play("death")
		is_dead = true
		area.queue_free()
		get_tree().current_scene.score += 1
		
		await get_tree().create_timer(0.6).timeout
		queue_free()
