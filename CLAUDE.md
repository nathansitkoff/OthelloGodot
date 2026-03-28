# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

StrateGodot is a Godot 4.6 game targeting desktop platforms, currently in early development focused on player movement and animation state machines.

## Tech Stack

- **Engine**: Godot 4.6
- **Language**: GDScript (not C#)
- **Platform**: Desktop

## Code Style

- `snake_case` for functions and variables
- `PascalCase` for classes and nodes
- Type hints on all function parameters
- Prefer signals over direct references

## Project Structure

- Autoloads: `GameManager`, `AudioManager`, `SaveSystem`
- Main scenes in `res://scenes/`
- Reusable components in `res://components/`

## Repository Note

The `StrateGodot/` subdirectory contains a separate git repository. The Godot project files live there.
