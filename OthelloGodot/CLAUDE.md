# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

OthelloGodot is a 2D Othello (Reversi) board game built with Godot 4.6 for WebGL (HTML5 export to itch.io). Supports Human vs Human and Human vs AI (minimax with alpha-beta pruning).

## Tech Stack

- **Engine**: Godot 4.6
- **Language**: GDScript (not C#)
- **Renderer**: GL Compatibility (required for HTML5)
- **Platform**: WebGL / HTML5 (itch.io)

## Code Style

- `snake_case` for functions and variables
- `PascalCase` for classes and nodes
- Type hints on all function parameters
- Prefer signals over direct references

## Architecture

- `scripts/game_logic.gd` — Othello rules engine (board state, move validation, flipping). Uses `board[row][col]` indexing with `Vector2i(row, col)`.
- `scripts/ai_player.gd` — Minimax AI with alpha-beta pruning and positional weight evaluation. Depth 4 by default.
- `scripts/board.gd` — Board rendering via `_draw()` on a Control node. Scales to fit available space. Emits `move_made` signal on valid click.
- `scripts/main.gd` — Game flow: turn management, AI integration, UI wiring.
- `scenes/main.tscn` — Single scene with UI controls and board. Uses `%UniqueNames` for node references.

## Running the Project

Open in Godot 4.6 and run from the editor, or:
```
godot --path .
```

## HTML5 Export (itch.io)

Requires the **Web** export template installed in Godot. Use `GL Compatibility` renderer. When uploading to itch.io, set the project type to "HTML" and enable "SharedArrayBuffer" in the embed options if needed.
