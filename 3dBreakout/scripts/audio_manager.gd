extends Node

# Placeholder audio manager — add AudioStreamPlayer children as needed.


func play_sfx(sfx_name: String) -> void:
	var player := get_node_or_null(sfx_name) as AudioStreamPlayer
	if player:
		player.play()
