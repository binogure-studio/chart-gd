tool
extends EditorPlugin

func _enter_tree():
  # Initialization of the plugin goes here
  add_custom_type('GDCharts', 'ReferenceFrame', preload('res://addons/GDCharts/script.gd'), preload('res://addons/GDCharts/icon.png'))

func _exit_tree():
  # Clean-up of the plugin goes here
  remove_custom_type('GDCharts')
