# Code made with love and care by Mymy/TuTiuTe
extends VBoxContainer

signal resume

const ACTION_PANEL = preload("res://scenes/menu/ActionPanel.tscn")
@onready var mapping_container: VBoxContainer = $MappingContainer

var _gameplay_ns := "gameplay"
var _loaded_settings := false
var remappable_actions_str := [
  "move_forward",
  "move_back",
  "strafe_left",
  "strafe_right",
  "jump",
  "crouch",
  "interact",
]

func _ready() -> void:
  populate_map_buttons()
  var settings = SettingsManager.get_settings(_gameplay_ns)
  _loaded_settings = true
  if settings:
    load_settings_obj(settings)

func populate_map_buttons() -> void:
  for action_str in remappable_actions_str:
    var action_panel := ACTION_PANEL.instantiate()
    action_panel.action_str = action_str
    action_panel.name = action_str + " Panel"
    mapping_container.add_child(action_panel)
    action_panel.update_action()

func _create_settings_obj() -> Dictionary:
  var save_dict := {}
  for action_panel in mapping_container.get_children():
    var save_event_joy := []
    var save_event_key := []
    print(typeof(action_panel.current_keyboard_event))
    if action_panel.current_keyboard_event is InputEventKey:
      save_event_key = [0, action_panel.current_keyboard_event.keycode]
    elif action_panel.current_keyboard_event is InputEventMouseButton:
      save_event_key = [1, action_panel.current_keyboard_event.button_index]
    
    if action_panel.current_joy_event is InputEventJoypadButton:
      save_event_joy = [0, action_panel.current_joy_event.button_index]
    elif action_panel.current_joy_event is InputEventJoypadMotion:
      save_event_joy = [1, [action_panel.current_joy_event.axis, signf(action_panel.current_joy_event.axis_value)]]
    
    save_dict[action_panel.action_str] = {"key_event" : save_event_key, "joy_event" : save_event_joy}
  return save_dict

func load_settings_obj(dict : Dictionary) -> void:
  for elt in dict:
    var action_panel : PanelContainer = mapping_container.get_node_or_null(elt + " Panel")
    if not action_panel:
      continue
    var event_key : InputEvent = null
    var event_joy : InputEvent = null
    
    if dict[elt]["key_event"][0] == 0:
      event_key = InputEventKey.new()
      event_key.keycode = dict[elt]["key_event"][1]
      event_key.pressed = true
    elif dict[elt]["key_event"][0] == 1:
      event_key = InputEventMouseButton.new()
      event_key.button_index = dict[elt]["key_event"][1]
      event_key.pressed = true
    
    if dict[elt]["joy_event"][0] == 0:
      event_joy = InputEventJoypadButton.new()
      event_joy.button_index = dict[elt]["joy_event"][1]
      event_joy.pressed = true
    elif dict[elt]["joy_event"][0] == 1:
      event_joy = InputEventJoypadMotion.new()
      event_joy.axis = dict[elt]["joy_event"][1][0]
      event_joy.axis_value = dict[elt]["joy_event"][1][1]
    
    if event_key:
      action_panel.keyboard_button.button_pressed = true
      action_panel._input(event_key)
    if event_joy:
      action_panel.joypad_button.button_pressed = true
      action_panel._input(event_joy)
    action_panel.update_action()
    
    

func _on_visibility_changed() -> void:
  if _loaded_settings and not visible:
    _save_settings()

func _save_settings() -> void:
  SettingsManager.save_settings(_gameplay_ns, _create_settings_obj())

func _on_resume() -> void:
  _save_settings()
  emit_signal("resume")
