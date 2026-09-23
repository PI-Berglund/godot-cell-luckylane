extends Control

## Visualizes the auto-lock safety net: MAX_REEL_SPIN_SECONDS in
## luckylane_level3.py auto-stops any reel still spinning that long after
## SPIN. Python doesn't send that duration over, so AUTO_LOCK_SECONDS here
## is a mirrored constant, not a fetched one - keep the two in sync if
## either changes.
##
## start() on LUCKYLANE_SPIN, stop() on LUCKYLANE_RESULT (see
## luckylane_level_3.gd). TimerFill's left edge is fixed; its right edge
## anchor animates from FILL_RIGHT_ANCHOR down to FILL_LEFT_ANCHOR as time
## runs out, draining the bar into the pill cutout in the frame art.
const AUTO_LOCK_SECONDS := 8.0

const FILL_LEFT_ANCHOR := 0.1860
const FILL_RIGHT_ANCHOR := 0.8131

@onready var fill: ColorRect = $TimerFill
@onready var seconds_label: Label = $SecondsLabel

var remaining := 0.0
var running := false


func start() -> void:
	remaining = AUTO_LOCK_SECONDS
	running = true
	visible = true
	_update_display()


func stop() -> void:
	running = false
	visible = false


func _process(delta: float) -> void:
	if not running:
		return

	remaining = max(0.0, remaining - delta)
	_update_display()

	if remaining <= 0.0:
		running = false


func _update_display() -> void:
	var fraction: float = remaining / AUTO_LOCK_SECONDS
	fill.anchor_right = FILL_LEFT_ANCHOR + (FILL_RIGHT_ANCHOR - FILL_LEFT_ANCHOR) * fraction
	seconds_label.text = str(int(ceil(remaining)))
