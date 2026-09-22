extends Control

## Godot-rendered slot machine level ("Luckylane Level4" in the python
## source, luckylane_level3.py). Four reels spin at once; python decides
## the winning symbol for every reel the instant SPIN is pressed and only
## tells Godot WHEN each reel should stop, never WHAT it lands on - python
## owns the outcome, Godot owns the animation. See luckylane_level3.py's
## module docstring for the full UDP message contract this listens for.

const ReelScene := preload("res://cells/luckylane/scenes/reel.tscn")

@onready var reels_container: HBoxContainer = $ReelsContainer
@onready var result_label: Label = $ResultLabel

var reels: Array = []


func level_specific_start_game() -> void:
	EventBus.game_specific_message_received.connect(_on_game_specific_message_received)
	result_label.visible = false


func _on_game_specific_message_received(message: String, data: Variant) -> void:
	match message:
		"LUCKYLANE_INIT_REELS":
			_init_reels(data)
		"LUCKYLANE_SPIN":
			_spin_all()
		"LUCKYLANE_STOP_REEL":
			_stop_reel(data.reel_index, data.symbol)
		"LUCKYLANE_RESULT":
			_show_result(data)


## data: { "symbols": [...], "reels": [[...], [...], [...], [...]] }
## Sent once per round start; rebuilds each reel's strip from scratch so
## python stays the single source of truth for strip content/order.
func _init_reels(data: Dictionary) -> void:
	result_label.visible = false

	for child in reels_container.get_children():
		child.queue_free()
	reels.clear()

	var reel_strips: Array = data.reels
	for reel_index in range(reel_strips.size()):
		var reel := ReelScene.instantiate()
		reels_container.add_child(reel)
		reel.setup(reel_strips[reel_index])
		reels.append(reel)


func _spin_all() -> void:
	result_label.visible = false
	for reel in reels:
		reel.spin()


## data: { "reel_index": 0-3, "symbol": "cherry" }
func _stop_reel(reel_index: int, symbol: String) -> void:
	if reel_index >= 0 and reel_index < reels.size():
		reels[reel_index].stop_on_symbol(symbol)
	else:
		push_error("Luckylane: LUCKYLANE_STOP_REEL for out-of-range reel_index %s" % reel_index)


## data: { "win": bool, "points": int, "symbols": [...] }
func _show_result(data: Dictionary) -> void:
	if data.win:
		result_label.text = "WIN! +%s" % data.points
		result_label.modulate = Color(1, 0.84, 0, 1)
	else:
		result_label.text = "TRY AGAIN"
		result_label.modulate = Color(1, 1, 1, 1)
	result_label.visible = true
