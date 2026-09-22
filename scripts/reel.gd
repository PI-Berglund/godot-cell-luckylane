extends Control

## Reusable slot-machine reel used by luckylane_level_3. Owns its own scroll
## animation (continuous spin + decelerate-and-land tween); the level
## script only tells it which symbol strip to use, when to spin, and which
## symbol to land on, per luckylane_level3.py's UDP message contract.
##
## Single-row window: only one symbol is visible at a time, sitting at the
## top of this control's rect. That symbol is always symbols[current_index].

const SYMBOL_SIZE := 220.0
const SPIN_SPEED := 1400.0  # px/sec while freely spinning
const STOP_TWEEN_TIME := 0.9
const EXTRA_LAPS_ON_STOP := 1  # extra full strip loops before landing, for feel

@onready var strip: Control = $Mask/Strip

var symbols: Array = []
var scroll_offset := 0.0
var spinning := false
var stop_tween: Tween


func setup(symbol_strip: Array) -> void:
	symbols = symbol_strip
	spinning = false

	for child in strip.get_children():
		child.queue_free()

	## Three copies of the strip stacked so the reel can scroll seamlessly;
	## the middle copy is what's visible at rest, with slack above/below.
	for lap in range(3):
		for i in range(symbols.size()):
			var icon := _make_symbol_node(symbols[i])
			icon.position.y = (lap * symbols.size() + i) * SYMBOL_SIZE
			strip.add_child(icon)

	_set_scroll_offset(0.0)


func spin() -> void:
	if stop_tween:
		stop_tween.kill()
	spinning = true


func stop_on_symbol(symbol: String) -> void:
	spinning = false

	var strip_height: float = symbols.size() * SYMBOL_SIZE
	var target_index := _find_next_symbol_index(symbol)

	var target_offset: float = target_index * SYMBOL_SIZE
	while target_offset <= scroll_offset:
		target_offset += strip_height
	target_offset += EXTRA_LAPS_ON_STOP * strip_height

	if stop_tween:
		stop_tween.kill()
	stop_tween = create_tween()
	stop_tween.tween_method(_set_scroll_offset, scroll_offset, target_offset, STOP_TWEEN_TIME) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _process(delta: float) -> void:
	if spinning:
		_set_scroll_offset(scroll_offset + SPIN_SPEED * delta)


func _set_scroll_offset(value: float) -> void:
	scroll_offset = value
	var strip_height: float = symbols.size() * SYMBOL_SIZE
	strip.position.y = fmod(scroll_offset, strip_height) - strip_height


func _find_next_symbol_index(symbol: String) -> int:
	var strip_height: float = symbols.size() * SYMBOL_SIZE
	var current_index := int(floor(fmod(scroll_offset, strip_height) / SYMBOL_SIZE))
	for step in range(symbols.size()):
		var idx := (current_index + step) % symbols.size()
		if symbols[idx] == symbol:
			return idx
	push_error("Luckylane reel: symbol '%s' not found in strip" % symbol)
	return current_index


func _make_symbol_node(symbol: String) -> Control:
	var texture := _load_symbol_texture(symbol)
	if texture:
		var rect := TextureRect.new()
		rect.texture = texture
		rect.size = Vector2(SYMBOL_SIZE, SYMBOL_SIZE)
		rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		return rect

	## Placeholder until the symbol image is in: colored tile + symbol name,
	## so the reel is fully testable before art assets exist.
	var placeholder := ColorRect.new()
	placeholder.size = Vector2(SYMBOL_SIZE, SYMBOL_SIZE)
	placeholder.color = _placeholder_color(symbol)

	var label := Label.new()
	label.text = symbol.to_upper()
	label.size = placeholder.size
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	placeholder.add_child(label)
	return placeholder


func _load_symbol_texture(symbol: String) -> Texture2D:
	var path := "res://cells/luckylane/resources/images/symbols/%s.png" % symbol
	if ResourceLoader.exists(path):
		return load(path)
	return null


func _placeholder_color(symbol: String) -> Color:
	match symbol:
		"cherry":
			return Color(0.8, 0.1, 0.1)
		"seven":
			return Color(0.1, 0.1, 0.8)
		"bell":
			return Color(0.9, 0.7, 0.1)
		"star":
			return Color(0.6, 0.1, 0.8)
		_:
			return Color(0.3, 0.3, 0.3)
