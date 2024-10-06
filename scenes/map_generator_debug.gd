@tool
extends Node2D

@export var regenerate: bool:
	set(value):
		if Engine.is_editor_hint():
			$LevelManager.generate()
