# godot-cell-luckylane

Godot cell submodule for Lucky Lane.

Port target: `cell-game-luckylane` (python/pygame), a Mastermind-style
peg-guessing game — `luckylane_game.py` deals a hidden sequence of
`num_colors` (4) colored pegs across `num_columns` (4) columns, the player
gets `num_rows` (10) guesses (`max_iterations`), and after each guess
receives hint pegs (right color / right position feedback), same as the
classic board game. Levels 0-3 correspond to `luckylane_level0.py` ..
`luckylane_level3.py`.

`gui_layout` is `FREE` for all 4 levels (`config/luckylane_main.cfg`), so
every level's scene is fully custom-drawn by Godot rather than sitting on
one of the base project's shared cell-screen layouts.

## Status

Bare placeholder scenes/scripts for levels 0-3, not yet built. Waiting on
game description / design details before porting the actual peg-board
logic, hint calculation, and input handling (guess button, hint button,
column buttons — see `config/luckylane_main.json`'s Digital Inputs for the
physical button layout) from the python source.
