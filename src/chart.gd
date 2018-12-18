extends Control

enum LABELS_TO_SHOW {
  NO_LABEL,
  X_LABEL,
  Y_LABEL
}

const number_utils = preload('res://src/number.gd')
const COLOR_LINE_RATIO = 0.5
const LABEL_SPACE = Vector2(64.0, 32.0)

export(Font) var label_font
export(int, 6, 24) var MAX_VALUES = 12
export(Texture) var dot_texture = preload('res://assets/graph-plot-white.png')
export(Color) var default_chart_color = Color(1.0, 1.0, 1.0, 0.8)
export(Color) var grid_color = Color(0.7, 0.7, 0.7, 0.7)
export var line_width = 2.0

var current_data = []
var max_value = 1.0
var current_animation_duration = 1.0
var current_point_color = {}
var current_show_label = LABELS_TO_SHOW.NO_LABEL

onready var tween_node = get_node('tween')
onready var texture_size = dot_texture.get_size()
onready var min_x = 0.0
onready var max_y = get_size().y
onready var max_x = get_size().x
onready var current_data_size = MAX_VALUES
onready var global_scale = Vector2(1.0, 1.0) / sqrt(MAX_VALUES)
onready var interline_color = Color(grid_color.r, grid_color.g, grid_color.b, grid_color.a * 0.5)

func _ready():
  tween_node.start()

func initialize(show_label, points_color = {}, animation_duration = 1.0):
  set_labels(show_label)
  current_animation_duration = animation_duration

  for key in points_color:
    current_point_color[key] = {
      dot = points_color[key],
      line = Color(
        points_color[key].r,
        points_color[key].g,
        points_color[key].b,
        points_color[key].a * COLOR_LINE_RATIO)
    }

func set_labels(show_label):
  current_show_label = show_label

  # Reset values
  min_x = 0.0
  max_y = get_size().y
  max_x = get_size().x

  if current_show_label & LABELS_TO_SHOW.X_LABEL:
    max_y -= LABEL_SPACE.y

  if current_show_label & LABELS_TO_SHOW.Y_LABEL:
    min_x += LABEL_SPACE.x
    max_x -= min_x

  current_data_size -= 1
  move_other_sprites()
  current_data_size = current_data.size()

func _draw():
  var vertical_line = [Vector2(min_x, 0.0), Vector2(min_x, max_y)]
  var horizontal_line = [vertical_line[1], Vector2(min_x + max_x, max_y)]
  var previous_point = {}

  for point_data in current_data:
    var point

    for key in point_data.sprites:
      point = point_data.sprites[key].sprite.get_pos() + texture_size * global_scale / 2.0

      if previous_point.has(key):
        draw_line(previous_point[key], point, current_point_color[key].line, line_width)

      previous_point[key] = point

    draw_line(
      Vector2(point.x, vertical_line[0].y),
      Vector2(point.x, vertical_line[1].y),
      interline_color, 1.0)

    if current_show_label & LABELS_TO_SHOW.X_LABEL:
      var label = tr(point_data.label).left(3)
      var string_decal = Vector2(14, -LABEL_SPACE.y + 8.0)

      draw_string(label_font, Vector2(point.x, vertical_line[1].y) - string_decal, label, grid_color)


  if current_show_label & LABELS_TO_SHOW.Y_LABEL:
    var ordinate_values = number_utils.compute_ordinate_values(max_value)

    for ordinate_value in ordinate_values:
      var label = number_utils.format(ordinate_value)
      var position = Vector2(max(0, 6.0 -label.length()) * 9.5, max_y - compute_y(ordinate_value))
      draw_string(label_font, position, label, grid_color)

  draw_line(vertical_line[0], vertical_line[1], grid_color, 1.0)
  draw_line(horizontal_line[0], horizontal_line[1], grid_color, 1.0)

func compute_y(value):
  return (value / max_value) * (max_y - texture_size.y)

func compute_sprites(points_data):
  var sprites = {}

  for key in points_data.values:
    var value = points_data.values[key]

    # Création d'un Sprite
    var sprite = TextureFrame.new()

    # Positionne le Sprite
    var initial_pos = Vector2(max_x, max_y)

    sprite.set_pos(initial_pos)

    # Attache une texture a ce node
    sprite.set_texture(dot_texture)
    sprite.set_modulate(current_point_color[key].dot)

    # Attacher le sprite à la scène courante
    add_child(sprite)

    var end_pos = initial_pos - Vector2(-min_x, compute_y(value))

    sprite.set_ignore_mouse(false)
    sprite.set_stop_mouse(true)
    sprite.set_tooltip('%s: %s' % [tr(key), number_utils.format(value)])

    # Appliquer le déplacement
    animation_move_dot(sprite, end_pos - texture_size * global_scale / 2.0, global_scale, 0.0, current_animation_duration)

    sprites[key] = {
      sprite = sprite,
      value = value
    }

  return sprites

func _compute_max_value(point_data):
  # Being able to manage multiple points dynamically
  for key in point_data.values:
    max_value = max(point_data.values[key], max_value)

    # Set default color
    if not current_point_color.has(key):
      current_point_color[key] = {
        dot = default_chart_color,
        line = Color(default_chart_color.r,
          default_chart_color.g,
          default_chart_color.b,
          default_chart_color.a * COLOR_LINE_RATIO)
      }

func clean_chart():
  # If there is too many points, remove old ones
  if current_data.size() >= MAX_VALUES:
    var point_to_remove = current_data[0]

    for key in point_to_remove.sprites:
      var sprite = point_to_remove.sprites[key]

      sprite.sprite.queue_free()

    current_data.remove(0)
    _update_scale()

func create_new_point(point_data):
  # Reset current tween
  tween_node.reset_all()
  tween_node.stop_all()

  clean_chart()
  _compute_max_value(point_data)

  # Move others current_data
  move_other_sprites()

  # Sauvegarde le sprite courant
  current_data.append({
    label = point_data.label,
    sprites = compute_sprites(point_data)
  })

  _update_scale()
  tween_node.start()

func _update_scale():
  current_data_size = current_data.size()
  global_scale = Vector2(1.0, 1.0) / sqrt(min(5, current_data_size))

func _move_other_sprites(points_data, index):
  for key in points_data.sprites:
    var point_data = points_data.sprites[key]
    var delay = sqrt(index) / 10.0
    var sprite = point_data.sprite
    var value = point_data.value

    var y = max_y - compute_y(value)
    var x = min_x + (max_x / current_data_size) * index

    animation_move_dot(sprite, Vector2(x, y) - texture_size * global_scale / 2.0, global_scale, delay)

func move_other_sprites():
  var index = 0

  for points_data in current_data:
    _move_other_sprites(points_data, index)

    index += 1

func animation_move_dot(node, end_pos, end_scale, delay = 0.0, duration = 0.5):
  var current_pos = node.get_pos()
  var current_scale = node.get_scale()

  tween_node.interpolate_property(node, 'rect/pos', current_pos, end_pos, duration, Tween.TRANS_CIRC, Tween.EASE_OUT, delay)
  tween_node.interpolate_property(node, 'rect/scale', current_scale, end_scale, duration, Tween.TRANS_CIRC, Tween.EASE_OUT, delay)
  tween_node.interpolate_method(self, '_update_draw', current_scale, end_scale, duration, Tween.TRANS_CIRC, Tween.EASE_OUT, delay)

func _update_draw(object = null):
  update()