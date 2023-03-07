extends ReferenceFrame

enum LABELS_TO_SHOW {
  NO_LABEL = 0,
  X_LABEL = 1,
  Y_LABEL = 2,
  LEGEND_LABEL = 4
}

enum CHART_TYPE {
  LINE_CHART,
  PIE_CHART,
  JAPANESE_CANDLESTICK_CHART,
  HISTOBAR_CHART
}

const MAXIMUM_CANDLE_WIDTH = 28.0
const MIN_MAX_RATIO = 1.1
const MIN_MAX_CLAMP_MAX = 10.0
const MIN_MAX_CLAMP_MIN = 1.0
const COLOR_LINE_RATIO = 0.5
const LABEL_SPACE = Vector2(42.0, 42.0)
const MAXIMUM_HORIZONTAL_LINES = 10.0

const HISTOBAR_MINIMMUM_SIZE = 6.0

export(int, 0, 16) var HISTOBAR_CHART_SPACE = 4.0
export(int, 0, 8) var HISTOBAR_ROUNDED_RADIUS_MINIMUM = 6.0
export(int, 8, 128) var HISTOBAR_ROUNDED_RADIUS_MAXIMUM = 64.0

export(Font) var label_font = preload('res://assets/THSarabunNew.tres')
export(int, 6, 100) var MAX_VALUES = 12
export(Texture) var dot_texture = preload('res://assets/graph-plot-white.png')
export(Color) var default_chart_color = Color('#ccffffff')
export(Color) var grid_color = Color('#b111171c')
export(Color) var background_color = Color('#64dae3ea')
export(Color) var background_color_alternative = Color('#649ba3aa')
export(bool) var auto_adjust_dark_mode = true
export(int, 'Line', 'Pie', 'Japanese candlestick', 'Histobar') var chart_type = CHART_TYPE.LINE_CHART setget set_chart_type
export var line_width = 2.0
export(float, 1.0, 2.0, 0.1) var hovered_radius_ratio = 1.1
export(float, 0.0, 1.0, 0.01) var chart_background_opacity = 0.334
export(bool) var draw_background = true
export(bool) var draw_gradient_background = false

var current_data = []
var min_value = 0.0
var max_value = 1.0
var current_animation_duration = 0.667
var current_point_color = {}
var current_show_label = LABELS_TO_SHOW.NO_LABEL
var current_mouse_over = null
var label_pool = []

class PieChartData extends Object:
  var p_data
  var p_hovered_item = null
  var p_hovered_radius_ratio = 1.2

  func _init():
    p_data = {}

  func _set(param, value):
    p_data[param] = value

    return true

  func _get(param):
    if not p_data.has(param):
      p_data[param] = 0.0

    return p_data[param]

  func set_hovered_item(name):
    p_hovered_item = name

  func set_radius(param, value):
    return _set(_format_radius_key(param), value)

  func get_radius(param):
    var radius_ratio = 1.0

    if param == p_hovered_item:
      radius_ratio = p_hovered_radius_ratio

    return _get(_format_radius_key(param)) * radius_ratio

  func _format_radius_key(param):
    return '%s_radius' % [param]

  func get_property_list():
    return p_data.keys()

var pie_chart_current_data = PieChartData.new()

# Node create in the initializion phase
var tween_node = Tween.new()
var tooltip_data = null

onready var texture_size = dot_texture.get_size()
onready var min_x = 0.0
onready var max_x = get_size().x

onready var candle_min_x = 0.0
onready var candle_max_x = get_size().x

onready var min_y = 0.0
onready var max_y = get_size().y

onready var current_data_size = MAX_VALUES
onready var global_scale = Vector2(1.0, 1.0) / sqrt(MAX_VALUES)

var interline_color = Color(grid_color.r, grid_color.g, grid_color.b, grid_color.a * 0.5)
var min_value_set = false
var max_value_set = false
var computed_grid_color = grid_color

func _init():
  add_child(tween_node)
  call_deferred('_update_grid_color')

func _ready():
  tween_node.call_deferred('start')
  set_process_input(chart_type == CHART_TYPE.PIE_CHART)
  pie_chart_current_data.hovered_radius_ratio = hovered_radius_ratio

func _update_grid_color(arg0 = null):
  computed_grid_color = grid_color

  interline_color = Color(computed_grid_color.r, computed_grid_color.g, computed_grid_color.b, computed_grid_color.a * 0.5)

func _exit_tree():
  pie_chart_current_data.free()

func set_chart_type(value):
  if chart_type != value:
    clear_chart()
    chart_type = value

    _update_min_max()
    update_tooltip()
    set_process_input(chart_type == CHART_TYPE.PIE_CHART)

    update()

func _input(event):
  if event.type == InputEvent.MOUSE_MOTION:
    var center_point = get_global_pos() + Vector2(min_x + max_x, min_y + max_y) / 2.0
    var computed_radius = round(min(max_y - min_y, max_x - min_x) / 2.0)
    var hovered_data = null
    var hovered_name = null

    if event.pos.distance_to(center_point) <= computed_radius and \
      current_data != null and current_data.size() > 0:
      var centered_position = event.pos - center_point
      var computed_angle = (360.0 - rad2deg(centered_position.angle() + PI))
      var total_value = 0.0
      var initial_angle = 0.0

      for item_key in current_data[0]:
        total_value += pie_chart_current_data.get(item_key)

      total_value = max(1, total_value)

      for item_key in current_data[0]:
        var item_value = pie_chart_current_data.get(item_key)
        var ending_angle = min(initial_angle + item_value * 360.0 / total_value, 359.99)

        if computed_angle > initial_angle and computed_angle <= ending_angle:
          hovered_name = item_key
          hovered_data = {
            name = item_key,
            value = item_value
          }
          break

        initial_angle = ending_angle

    pie_chart_current_data.set_hovered_item(hovered_name)
    update_tooltip(hovered_data)

func update_tooltip(data = null):
  var update_frame = false

  if data != null:
    if tooltip_data != data and data.has('value'):
      set_tooltip('%s: %.02f%%' % [data.name, data.value])
      update_frame = true

  elif tooltip_data != null:
    set_tooltip('')
    update_frame = true

  tooltip_data = data

  if update_frame:
    update()

func initialize(show_label, points_color = {}, animation_duration = 0.667):
  set_labels(show_label)
  current_animation_duration = animation_duration

  _clear_labels()

  for key in points_color:
    current_point_color[key] = {
      dot = points_color[key],
      line = Color(
        points_color[key].r,
        points_color[key].g,
        points_color[key].b,
        points_color[key].a * COLOR_LINE_RATIO)
    }

  _update_labels()

func _update_labels():
  if current_show_label & LABELS_TO_SHOW.LEGEND_LABEL:
    for key in current_point_color:
      if not current_point_color[key].has('wref_label') or current_point_color[key].wref_label.get_ref() == null:
        var dot_label = Label.new()

        dot_label.set_text(tr(key))
        dot_label.set_autowrap(true)
        dot_label.set_clip_text(true)
        dot_label.set_custom_minimum_size(LABEL_SPACE)
        dot_label.set_ignore_mouse(true)
        dot_label.set_stop_mouse(false)
        dot_label.set_valign(Label.VALIGN_CENTER)
        dot_label.set('custom_colors/font_color', computed_grid_color)

        current_point_color[key].label = dot_label
        current_point_color[key].wref_label = weakref(dot_label)

        # FIXME
        # Might lead to a crash
        add_child(dot_label)
        label_pool.push_back(weakref(dot_label))

  else:
    _clear_labels()

func _clear_labels():
  for label_item in label_pool:
    if label_item != null and label_item.get_ref() != null:
      label_item.get_ref().queue_free()

  # Reset the label pool
  label_pool = []  

func set_labels(show_label):
  # No label for 
  if chart_type == CHART_TYPE.JAPANESE_CANDLESTICK_CHART or chart_type == CHART_TYPE.HISTOBAR_CHART:
    current_show_label = LABELS_TO_SHOW.NO_LABEL

  else:
    current_show_label = show_label

  _update_min_max()

func _update_min_max():
  # Reset values
  min_y = 0.0
  min_x = 0.0
  max_y = get_size().y
  max_x = get_size().x

  if chart_type == CHART_TYPE.JAPANESE_CANDLESTICK_CHART:
    var candle_width = _compute_candle_width()

    candle_min_x = min_x + candle_width / 2.0
    candle_max_x = max_x - candle_width / 2.0

  else:
    if current_show_label & LABELS_TO_SHOW.X_LABEL:
      max_y -= LABEL_SPACE.y

    if current_show_label & LABELS_TO_SHOW.Y_LABEL:
      min_x += LABEL_SPACE.x
      max_x -= min_x

    if current_show_label & LABELS_TO_SHOW.LEGEND_LABEL:
      min_y += LABEL_SPACE.y
      max_y -= min_y

  _update_labels()
  current_data_size = max(0, current_data_size - 1)
  move_other_sprites()
  current_data_size = current_data.size()

func _on_mouse_over(label_type):
  current_mouse_over = label_type

  update()

func _on_mouse_out(label_type):
  if current_mouse_over == label_type:
    current_mouse_over = null

    update()

func set_max_values(max_values):
  MAX_VALUES = max_values

  clean_chart()

  current_data_size = max(0, current_data_size - 1)
  move_other_sprites()
  current_data_size = current_data.size()

func draw_circle_arc_poly(center, radius, angle_from, angle_to, color):
  var nb_points = int(radius / 2.0)
  var points_arc = Vector2Array()
  var colors = ColorArray([color])

  points_arc.push_back(center)

  for index in range(nb_points + 1):
    var angle_point = deg2rad(angle_from + index * (angle_to - angle_from) / nb_points - 90)

    points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)

  draw_polygon(points_arc, colors)

func _draw():
  if chart_type == CHART_TYPE.LINE_CHART:
    draw_line_chart()
    _draw_labels()

  elif chart_type == CHART_TYPE.JAPANESE_CANDLESTICK_CHART:
    draw_japanese_candlestick_chart()

  elif chart_type == CHART_TYPE.HISTOBAR_CHART:
    draw_histobar_chart()

  else:
    draw_pie_chart()
    _draw_labels()

func draw_histobar_chart():
  if not current_data.empty():
    var total_value = 0
    var number_of_entries = current_data[0].keys().size()
    var histobar_size = get_size().x

    for item_key in current_data[0]:
      total_value += current_data[0][item_key]

    total_value = max(1.0, total_value)

    # (nombre de segment de mon histobar) = (taille totale / nombre de données visibles) 
    var visible_entries = {}
    var number_of_segment = number_of_entries
    var need_to_compute_visible_entries = true
    var removed_entries = []
    var histobar_size_with_spaces = histobar_size - max(0, number_of_segment - 1) * HISTOBAR_CHART_SPACE
    var border_radius = int(clamp(get_size().y / 2.0, HISTOBAR_ROUNDED_RADIUS_MINIMUM, HISTOBAR_ROUNDED_RADIUS_MAXIMUM))

    while need_to_compute_visible_entries:
      border_radius = int(clamp(get_size().y / 2.0, HISTOBAR_ROUNDED_RADIUS_MINIMUM, HISTOBAR_ROUNDED_RADIUS_MAXIMUM))
      histobar_size_with_spaces = histobar_size - max(0, number_of_segment - 1) * HISTOBAR_CHART_SPACE
      need_to_compute_visible_entries = false

      for item_key in current_data[0]:
        var item_value = current_data[0][item_key]
        var item_size_x = int(current_data[0][item_key] * (histobar_size_with_spaces / total_value))

        if item_size_x > HISTOBAR_MINIMMUM_SIZE:
          visible_entries[item_key] = item_value
          border_radius = int(min(border_radius, item_size_x))

        elif not removed_entries.has(item_key):
          removed_entries.push_back(item_key)
          number_of_segment -= 1
          need_to_compute_visible_entries = true
          total_value -= item_value
          break

    var last_position = Vector2(0.0, 0.0)
    var index = 0
    var half_size = int(get_size().y / 2.0)

    for item_key in visible_entries:
      var item_size_x = int(current_data[0][item_key] * (histobar_size_with_spaces / total_value))
      var polygon_color = current_point_color[item_key].dot
      var points = [
        last_position,
        last_position + Vector2(item_size_x, 0),
        last_position + Vector2(item_size_x, get_size().y),
        last_position + Vector2(0.0, get_size().y)
      ]

      if index == 0:
        var top_center = Vector2(border_radius, border_radius)
        var bottom_center = Vector2(border_radius, get_size().y - border_radius)

        draw_circle_arc_poly(top_center, border_radius, 270, 360, polygon_color)
        draw_circle_arc_poly(bottom_center, border_radius, 180, 270, polygon_color)

        if half_size == border_radius:
          points = [
            last_position + Vector2(border_radius, 0.0),
            last_position + Vector2(item_size_x, 0.0),
            last_position + Vector2(item_size_x, get_size().y),
            last_position + Vector2(border_radius, get_size().y),
          ]

        elif item_size_x > border_radius:
          points = [
            last_position + Vector2(0.0, border_radius),
            last_position + Vector2(border_radius, border_radius),
            last_position + Vector2(border_radius, 0.0),

            last_position + Vector2(item_size_x, 0),
            last_position + Vector2(item_size_x, get_size().y),

            last_position + Vector2(border_radius, get_size().y),
            last_position + Vector2(border_radius, get_size().y - border_radius),
            last_position + Vector2(0.0, get_size().y - border_radius)
          ]

        else:
          points = [
            last_position + Vector2(0, border_radius),
            last_position + Vector2(item_size_x, border_radius),
            last_position + Vector2(item_size_x, get_size().y - border_radius),
            last_position + Vector2(0, get_size().y - border_radius),
          ]

      elif index == (number_of_segment - 1):
        var top_center = Vector2(last_position.x + item_size_x - border_radius, border_radius)
        var bottom_center = Vector2(last_position.x + item_size_x - border_radius, get_size().y - border_radius)

        draw_circle_arc_poly(top_center, border_radius, 0, 90, polygon_color)
        draw_circle_arc_poly(bottom_center, border_radius, 90, 180, polygon_color)

        if half_size == border_radius:
          points = [
            last_position,
            last_position + Vector2(item_size_x - border_radius, 0.0),
            last_position + Vector2(item_size_x - border_radius, get_size().y),
            last_position + Vector2(0, get_size().y),
          ]

        elif item_size_x > border_radius:
          points = [
            last_position,
            last_position + Vector2(item_size_x - border_radius, 0),
            last_position + Vector2(item_size_x - border_radius, border_radius),
            last_position + Vector2(item_size_x, border_radius),
            last_position + Vector2(item_size_x, get_size().y - border_radius),
            last_position + Vector2(item_size_x - border_radius, get_size().y - border_radius),
            last_position + Vector2(item_size_x - border_radius, get_size().y),
            last_position + Vector2(0.0, get_size().y)
          ]

        else:
          points = [
            last_position + Vector2(0, border_radius),
            last_position + Vector2(item_size_x, border_radius),
            last_position + Vector2(item_size_x, get_size().y - border_radius),
            last_position + Vector2(0, get_size().y - border_radius),
          ]

      draw_colored_polygon(points, polygon_color)
      last_position = last_position + Vector2(item_size_x + HISTOBAR_CHART_SPACE, 0.0)
      index += 1

func draw_pie_chart():
  var center_point = Vector2(min_x + max_x, min_y + max_y) / 2.0
  var total_value = 0
  var initial_angle = 0.0

  if not current_data.empty():
    for item_key in current_data[0]:
      total_value += pie_chart_current_data.get(item_key)

    total_value = max(1, total_value)

    for item_key in current_data[0]:
      var item_value = pie_chart_current_data.get(item_key)
      var ending_angle = min(initial_angle + item_value * 360.0 / total_value, 359.99)
      var color = current_point_color[item_key].dot
      var radius = pie_chart_current_data.get_radius(item_key)

      if item_value > 0.0 and radius > 1.0 and (ending_angle - initial_angle) > 2.0:
        draw_circle_arc_poly(center_point, radius, initial_angle, ending_angle, color)
        initial_angle = ending_angle

func draw_japanese_candlestick_chart():
  var max_y_value = min_y + max_y
  var vertical_line = [Vector2(min_x, min_y), Vector2(min_x, max_y_value)]
  var horizontal_line = [vertical_line[1], Vector2(min_x + max_x, max_y_value)]
  var previous_point = {}
  var pointListObject = {}
  var y_length = max_y_value - 1.0

  # Need to draw the 0 ordinate line
  if min_value < 0:
    horizontal_line[0].y = max_y_value - compute_y_no_texture(0.0)
    horizontal_line[1].y = horizontal_line[0].y

  var max_min_y_diff = max_y - min_y
  var number_of_lines = min(MAXIMUM_HORIZONTAL_LINES, max_min_y_diff)
  var horizontal_line_interval = max_min_y_diff / (number_of_lines + 1.0)

  if number_of_lines > 0:
    for index in range(0, number_of_lines):
      var y = max_y - horizontal_line_interval * (index + 1) - min_y

      draw_line(Vector2(min_x, y), Vector2(min_x + max_x, y), computed_grid_color, 1.0)    
      draw_string(label_font, Vector2(min_x + max_x + 4.0, y + 4.0), '%s$' % [format(compute_value_from_y(max_y - y))], computed_grid_color)
      index += 1

  for point_data in current_data:
    # TODO
    # Draw average line
    draw_line(
      point_data.candle.current.line[0],
      point_data.candle.current.line[1],
      point_data.color, 1.0)

    draw_rect(
      point_data.candle.current.rectangle,
      point_data.color
    )

  _draw_chart_background(pointListObject)
  draw_line(vertical_line[0], vertical_line[1], computed_grid_color, 1.0)
  draw_line(horizontal_line[0], horizontal_line[1], computed_grid_color, 1.0)

func _draw_chart_background(pointListObject):
  if not draw_background:
    return

  var horizontal_max_y_value = min_y + max_y
  var horizontal_line = Vector2(min_x + max_x, horizontal_max_y_value)

  # Need to draw the 0 ordinate line
  if min_value < 0:
    horizontal_line.y = horizontal_max_y_value - compute_y(0.0)

  for key in pointListObject:
    var key_alpha = 0.5 if current_mouse_over != null and current_mouse_over != key else 1.0

    if pointListObject[key].size() < 2:
      continue

    var pointList = pointListObject[key]
    var max_y_value = pointList[0].y
    var min_y_value = pointList[0].y
    var color_alpha_ratio = COLOR_LINE_RATIO if current_mouse_over != null and current_mouse_over != key else 1.0
    var colors = []

    for point in pointList:
      max_y_value = max(max_y_value, point.y)
      min_y_value = min(max_y_value, point.y)

    max_y_value += 2
    max_y_value = max(max_y_value, min_y_value + 64)

    if draw_gradient_background:
      pointList.push_front(Vector2(pointList[0].x, max_y_value))
      pointList.push_back(Vector2(pointList[-1].x, max_y_value))

    else:
      pointList.push_front(Vector2(pointList[0].x, horizontal_line.y))
      pointList.push_back(Vector2(pointList[-1].x, horizontal_line.y))

    for point in pointList:
      var computed_color = current_point_color[key].dot

      if draw_gradient_background:
        computed_color.a *= (1.0 - (point.y / max_y_value)) * chart_background_opacity * color_alpha_ratio * key_alpha

      else:
        computed_color.a *= chart_background_opacity * color_alpha_ratio * key_alpha
      colors.push_back(computed_color)

    draw_polygon(pointList, colors)

func draw_line_chart():
  var max_y_value = min_y + max_y
  var vertical_line = [Vector2(min_x, min_y), Vector2(min_x, max_y_value)]
  var horizontal_line = [vertical_line[1], Vector2(min_x + max_x, max_y_value)]
  var previous_point = {}
  var pointListObject = {}
  var y_length = max_y_value - 1.0
  var texture_center = texture_size * global_scale / 2.0
  var string_decal = Vector2(14, -LABEL_SPACE.y + 8.0)

  # Need to draw the 0 ordinate line
  if min_value < 0:
    horizontal_line[0].y = max_y_value - compute_y(0.0)
    horizontal_line[1].y = horizontal_line[0].y

  var background_interval_size = Vector2(
    abs(horizontal_line[1].x - horizontal_line[0].x),
    abs(vertical_line[0].y - vertical_line[1].y)
  )

  background_interval_size.x = max(background_interval_size.x / max(1, (current_data.size() - 1)), 0)

  for index in range(0, current_data.size() - 1):
    var background_position = Vector2(horizontal_line[0].x + index * background_interval_size.x, vertical_line[0].y)
    var color = background_color if index % 2 else background_color_alternative
    var bottom_color = Color(
      color.r * 0.9,
      color.g * 0.9,
      color.b * 0.9,
      color.a
    )

    draw_polygon([
      background_position,
      background_position + background_interval_size * Vector2(0, 1),
      background_position + background_interval_size * Vector2(1, 1),
      background_position + background_interval_size * Vector2(1, 0)
    ], [
      color,
      color,
      bottom_color,
      bottom_color
    ])

  for point_data in current_data:
    var point

    for key in point_data.sprites:
      var current_dot_color = current_point_color[key].dot

      current_dot_color.a = COLOR_LINE_RATIO if current_mouse_over != null and current_mouse_over != key else 1.0

      point_data.sprites[key].sprite.set_modulate(current_dot_color)
      point = point_data.sprites[key].sprite.get_pos() + texture_center

      if not pointListObject.has(key):
        pointListObject[key] = []

      if point.y < y_length:
        pointListObject[key].push_back(point)
      else:
        pointListObject[key].push_back(Vector2(point.x, max_y_value - 2.0))

      if previous_point.has(key):
        var current_line_width = line_width

        if current_mouse_over != null:
          current_line_width = 1.0 if current_mouse_over != key else 3.0

        draw_line(previous_point[key], point, current_point_color[key].line, current_line_width)

        # Don't add points that are too close of each others
        if abs(previous_point[key].x - point.x) < 10.0:
          pointListObject[key].pop_back()

      previous_point[key] = point

    if current_show_label & LABELS_TO_SHOW.X_LABEL:
      var label = tr(point_data.label).left(3)

      draw_string(label_font, Vector2(point.x, vertical_line[1].y) - string_decal, label, computed_grid_color)

  _draw_chart_background(pointListObject)

  if current_show_label & LABELS_TO_SHOW.Y_LABEL:
    var ordinate_values = compute_ordinate_values(max_value, min_value)

    for ordinate_value in ordinate_values:
      var label = format(ordinate_value)
      var position = Vector2(max(0, 6.0 - label.length()) * 9.5, max_y_value - compute_y(ordinate_value))

      draw_string(label_font, position, label, computed_grid_color)

  draw_line(vertical_line[0], vertical_line[1], computed_grid_color, 1.0)
  draw_line(horizontal_line[0], horizontal_line[1], computed_grid_color, 1.0)

func _draw_labels():
  if current_show_label & LABELS_TO_SHOW.LEGEND_LABEL:
    var position = Vector2(min_x, 0.0)
    var position_increment = 1.0 * max_x / current_point_color.keys().size()
    var rectangle_size = LABEL_SPACE / 1.5

    for legend_label in current_point_color:
      var dot_color = current_point_color[legend_label].dot
      var label_position = Vector2(position.x, position.y)
      var label_size = LABEL_SPACE
      var label_node = current_point_color[legend_label].label if current_point_color[legend_label].has('label') and current_point_color[legend_label].wref_label.get_ref() else null
      var rect = Rect2(label_position, rectangle_size)

      if label_node == null:
        # Invalid label, meaning, stop drawing, if there is no
        # text, then there is no need for a rectangle
        continue

      label_position.x += LABEL_SPACE.x * 0.9
      label_position.y -= label_size.y / 6.0
      label_size.x += position_increment - (LABEL_SPACE.x + rectangle_size.x)

      if current_mouse_over != null and current_mouse_over != legend_label:
        dot_color = Color(
          dot_color.r,
          dot_color.g,
          dot_color.b,
          dot_color.a * COLOR_LINE_RATIO)

      label_node.set_pos(label_position)
      label_node.set_custom_minimum_size(label_size)
      draw_rect(rect, dot_color)
      position.x += position_increment

func compute_value_from_y(y_value):
  return ((y_value / max_y) * (max_value - min_value)) + min_value

func compute_y(value):
  var amplitude = max_value - min_value

  return ((value - min_value) / amplitude) * (max_y - texture_size.y)

func compute_rectangle_y(value):
  return value / (max_value - min_value) * max_y

func compute_y_no_texture(value):
  return ((value - min_value) / (max_value - min_value)) * max_y

func compute_candle(point_data):
  var candle_width = _compute_candle_width()
  var initial_pos = Vector2(candle_max_x - candle_width / 2.0, max_y)
  var M_end_pos = initial_pos - Vector2(-candle_min_x, compute_y_no_texture(point_data.max_value))
  var m_end_pos = initial_pos - Vector2(-candle_min_x, compute_y_no_texture(point_data.min_value))
  var y_value = abs(point_data.entry_value - point_data.exit_value)

  if y_value < 0.01:
    y_value = -1.0

  return {
    start = {
      line = [initial_pos, initial_pos],
      rectangle = Rect2(
        Vector2(initial_pos.x - candle_width / 2.0, max_y - compute_y_no_texture(max(point_data.entry_value, point_data.exit_value))),
        Vector2(candle_width, compute_rectangle_y(y_value))
      )
    },
    current = {
      line = [initial_pos, initial_pos],
      rectangle = Rect2(
        Vector2(initial_pos.x - candle_width / 2.0, max_y - compute_y_no_texture(max(point_data.entry_value, point_data.exit_value))),
        Vector2(candle_width, compute_rectangle_y(y_value))
      )
    },
    end = {
      line = [m_end_pos, M_end_pos],
      rectangle = Rect2(
        Vector2(m_end_pos.x - candle_width / 2.0, max_y - compute_y_no_texture(max(point_data.entry_value, point_data.exit_value))),
        Vector2(candle_width, compute_rectangle_y(y_value))
      )
    }
  }

func compute_sprites(points_data):
  var sprites = {}

  for key in points_data.values:
    var value = points_data.values[key]
    var sprite = TextureFrame.new()
    var initial_pos = Vector2(max_x, max_y)

    sprite.set_pos(initial_pos)
    sprite.set_texture(dot_texture)
    sprite.set_modulate(current_point_color[key].dot)

    # FIXME:
    # Watch out, this might lead to a random crash
    add_child(sprite)

    var end_pos = initial_pos - Vector2(-min_x, compute_y(value) - min_y)

    sprite.set_ignore_mouse(false)
    sprite.set_stop_mouse(true)
    sprite.set_tooltip('%s: %s' % [tr(key), format(value)])

    sprite.connect('mouse_enter', self, '_on_mouse_over', [key])
    sprite.connect('mouse_exit', self, '_on_mouse_out', [key])

    # Appliquer le déplacement
    animation_move_dot(sprite, end_pos - texture_size * global_scale / 2.0, global_scale, 0.0, current_animation_duration)

    sprites[key] = {
      sprite = sprite,
      value = value
    }

  return sprites

func _compute_max_value(point_data):
  # Being able to manage multiple points dynamically
  if chart_type == CHART_TYPE.LINE_CHART:
    for key in point_data.values:
      max_value = max(point_data.values[key], max_value)
      min_value = min(point_data.values[key], min_value)

      # Set default color
      if not current_point_color.has(key):
        current_point_color[key] = {
          dot = default_chart_color,
          line = Color(default_chart_color.r,
            default_chart_color.g,
            default_chart_color.b,
            default_chart_color.a * COLOR_LINE_RATIO)
        }

  else:
    var center_interval = clamp(max_value - (max_value / MIN_MAX_RATIO), MIN_MAX_CLAMP_MIN, MIN_MAX_CLAMP_MAX)
    
    max_value = max_value - center_interval
    min_value = min_value + center_interval

    if min_value_set:
      min_value = min(point_data.min_value, min_value)

    else:
      min_value = point_data.min_value
      min_value_set = true

    if max_value_set:
      max_value = max(point_data.max_value, max_value)

    else:
      max_value = point_data.max_value
      max_value_set = true

    var center_interval = clamp((max_value * MIN_MAX_RATIO) - max_value, MIN_MAX_CLAMP_MIN, MIN_MAX_CLAMP_MAX)
    
    min_value = min_value - center_interval
    max_value = max_value + center_interval

func clean_chart():
  var update_min_max = false

  # If there is too many points, remove old ones
  while current_data.size() >= MAX_VALUES:
    var point_to_remove = current_data[0]

    if chart_type == CHART_TYPE.LINE_CHART and point_to_remove.has('sprites'):
      for key in point_to_remove.sprites:
        var sprite = point_to_remove.sprites[key]

        sprite.sprite.queue_free()

    update_min_max = true
    current_data.pop_front()

  # Update max value
  if update_min_max:
    if chart_type == CHART_TYPE.JAPANESE_CANDLESTICK_CHART:
      max_value_set = false
      min_value_set = false

    min_value = 0.0
    max_value = 1.0

    for item_data in current_data:
      if chart_type == CHART_TYPE.LINE_CHART:
        for item_value in item_data.sprites.values():
          if item_value == null or not item_value.has('value'):
            continue

          max_value = max(item_value.value, max_value)
          min_value = min(item_value.value, min_value)

      elif chart_type == CHART_TYPE.JAPANESE_CANDLESTICK_CHART:
        if max_value_set:
          max_value = max(item_data.max_value, max_value)

        else:
          max_value = item_data.max_value
          max_value_set = true

        if min_value_set:
          min_value = min(item_data.min_value, min_value)

        else:
          min_value = item_data.min_value
          min_value_set = true

    if chart_type == CHART_TYPE.JAPANESE_CANDLESTICK_CHART:
      var center_interval = clamp((max_value * MIN_MAX_RATIO) - max_value, MIN_MAX_CLAMP_MIN, MIN_MAX_CLAMP_MAX)
      
      min_value = min_value - center_interval
      max_value = max_value + center_interval

  _update_scale()
  _update_min_max()

func _stop_tween():
  # Reset current tween
  tween_node.remove_all()
  tween_node.stop_all()

func clear_chart():
  _stop_tween()
  max_value = 1.0
  min_value = 0.0

  for point_to_remove in current_data:
    if point_to_remove.has('sprites'):
      for key in point_to_remove.sprites:
        var sprite = point_to_remove.sprites[key]

        sprite.sprite.queue_free()

  current_data = []
  _update_scale()
  update()

func create_new_point(point_data):
  _stop_tween()
  clean_chart()

  if chart_type == CHART_TYPE.LINE_CHART:
    _compute_max_value(point_data)

    # Move others current_data
    move_other_sprites()

    # Save current sprite
    current_data.push_back({
      label = point_data.label,
      sprites = compute_sprites(point_data)
    })

  elif chart_type == CHART_TYPE.HISTOBAR_CHART:
    current_data.push_back(point_data)

  elif chart_type == CHART_TYPE.JAPANESE_CANDLESTICK_CHART:
    _compute_max_value(point_data)

    # Move others current_data
    move_other_sprites()

    # Save current sprite
    current_data.push_back({
      min_value = point_data.min_value,
      max_value = point_data.max_value,

      entry_value = point_data.entry_value,
      exit_value = point_data.exit_value,

      candle = compute_candle(point_data),
      color = Color('#0092e9') if point_data.entry_value < point_data.exit_value else Color('#ff6363')
    })

  else:
    if current_data.empty():
      var data = {}

      for item_key in point_data.values:
        data[item_key] = 0
        pie_chart_current_data.set(item_key, 0.0)
        pie_chart_current_data.set_radius(item_key, 2.0)

      current_data.push_back(data)

    for item_key in point_data.values:
      current_data[0][item_key] += max(0, point_data.values[item_key])

    # Move others current_data
    move_other_sprites()

  _update_scale()
  tween_node.start()

func _compute_candle_width():
  return min((max_x / max(current_data_size, 1.0)) - 2.0, MAXIMUM_CANDLE_WIDTH)

func _update_scale():
  current_data_size = current_data.size()
  global_scale = Vector2(1.0, 1.0) / sqrt(min(5, current_data_size))

func _move_other_sprites(points_data, index):
  if chart_type == CHART_TYPE.LINE_CHART:
    for key in points_data.sprites:
      var point_data = points_data.sprites[key]

      if point_data == null or not point_data.has('value'):
        continue

      var position = Vector2(min_x + (max_x / max(1.0, current_data_size)) * index, min_y + max_y - compute_y(point_data.value))

      animation_move_dot(point_data.sprite, position - texture_size * global_scale / 2.0, global_scale, sqrt(index) / 10.0)

  elif chart_type == CHART_TYPE.JAPANESE_CANDLESTICK_CHART:
    var candle_width = _compute_candle_width()
    var M_end_pos = Vector2(candle_min_x + ((candle_max_x - candle_width / 2.0) / max(1.0, current_data_size)) * index, max_y - compute_y_no_texture(points_data.max_value))
    var m_end_pos = Vector2(candle_min_x + ((candle_max_x - candle_width / 2.0) / max(1.0, current_data_size)) * index, max_y - compute_y_no_texture(points_data.min_value))
    var y_value = abs(points_data.entry_value - points_data.exit_value)

    if y_value < 0.01:
      y_value = -1.0

    points_data.candle.start = {
      line = points_data.candle.end.line,
      rectangle = points_data.candle.end.rectangle,
    }
    points_data.candle.current = {
      line = points_data.candle.end.line,
      rectangle = points_data.candle.end.rectangle,
    }
    points_data.candle.end = {
      line = [m_end_pos, M_end_pos],
      rectangle = Rect2(
        Vector2(m_end_pos.x - candle_width / 2.0, max_y - compute_y_no_texture(max(points_data.entry_value, points_data.exit_value))),
        Vector2(candle_width, compute_rectangle_y(y_value))
      )
    }
  else:
    var sub_index = 0

    for item_key in points_data:
      animation_move_arcpolygon(item_key, points_data[item_key], sqrt(sub_index) / 5.0)
      sub_index += 1

func move_other_sprites():
  var index = 0

  for points_data in current_data:
    _move_other_sprites(points_data, index)

    index += 1

  if chart_type == CHART_TYPE.JAPANESE_CANDLESTICK_CHART:
    animation_move_candlestick()

func animation_move_candlestick(duration = 0.5):
  tween_node.interpolate_method(self, '_update_candleticks', 0.0, 1.0, duration, Tween.TRANS_CIRC, Tween.EASE_OUT)
  tween_node.interpolate_method(self, '_update_draw', 0.0, 1.0, duration, Tween.TRANS_CIRC, Tween.EASE_OUT)

func _update_candleticks(value):
  for points_data in current_data:
    points_data.candle.current.line[0].x = lerp(points_data.candle.start.line[0].x, points_data.candle.end.line[0].x, value)
    points_data.candle.current.line[0].y = lerp(points_data.candle.start.line[0].y, points_data.candle.end.line[0].y, value)

    points_data.candle.current.line[1].x = lerp(points_data.candle.start.line[1].x, points_data.candle.end.line[1].x, value)
    points_data.candle.current.line[1].y = lerp(points_data.candle.start.line[1].y, points_data.candle.end.line[1].y, value)

    points_data.candle.current.rectangle.pos.x = lerp(points_data.candle.start.rectangle.pos.x, points_data.candle.end.rectangle.pos.x, value)
    points_data.candle.current.rectangle.pos.y = lerp(points_data.candle.start.rectangle.pos.y, points_data.candle.end.rectangle.pos.y, value)

    points_data.candle.current.rectangle.size.x = lerp(points_data.candle.start.rectangle.size.x, points_data.candle.end.rectangle.size.x, value)
    points_data.candle.current.rectangle.size.y = lerp(points_data.candle.start.rectangle.size.y, points_data.candle.end.rectangle.size.y, value)

func animation_move_dot(node, end_pos, end_scale, delay = 0.0, duration = 0.5):
  if node == null:
    return

  var current_pos = node.get_pos()
  var current_scale = node.get_scale()

  tween_node.interpolate_property(node, 'rect/pos', current_pos, end_pos, duration, Tween.TRANS_CIRC, Tween.EASE_OUT, delay)
  tween_node.interpolate_property(node, 'rect/scale', current_scale, end_scale, duration, Tween.TRANS_CIRC, Tween.EASE_OUT, delay)
  tween_node.interpolate_method(self, '_update_draw', 0.0, 1.0, duration, Tween.TRANS_CIRC, Tween.EASE_OUT, delay)

func animation_move_arcpolygon(key_value, end_value, delay = 0.0, duration = 0.667):
  var radius_key = '%s_radius' % [key_value]
  var computed_radius = round(min(max_y - min_y, max_x - min_x) / 2.0)

  tween_node.interpolate_property(pie_chart_current_data, key_value, pie_chart_current_data.get(key_value), end_value, duration, Tween.TRANS_CIRC, Tween.EASE_OUT, delay)
  tween_node.interpolate_property(pie_chart_current_data, radius_key, pie_chart_current_data.get(radius_key), computed_radius, duration, Tween.TRANS_CIRC, Tween.EASE_OUT, delay)
  tween_node.interpolate_method(self, '_update_draw', 0.0, 1.0, duration, Tween.TRANS_CIRC, Tween.EASE_OUT, delay)

func _update_draw(object = null):
  update()

############################################
# Utils scripts
############################################
const ordinary_factor = 10
const range_factor = 1000
const units = ['', 'K', 'M', 'G', 'T', 'P', 'E', 'Z', 'Y']

func format(number, format_text_custom = '%.2f %s'):
  var unit_index = 0
  var format_text = '%d %s'
  var ratio = 1

  for index in range(0, units.size()):
    var computed_ratio = pow(range_factor, index)

    if abs(number) > computed_ratio:
      ratio = computed_ratio
      unit_index = index

      if index > 0:
        format_text = format_text_custom

  return format_text % [(number / ratio), units[unit_index]]

func compute_ordinate_values(p_max_value, p_min_value):
  var amplitude = p_max_value - p_min_value
  var ordinate_values = [-10, -8, -6, -4, -2, 0, 2, 4, 6, 8, 10]
  var result = []
  var ratio = 1

  for index in range(0, ordinary_factor):
    var computed_ratio = pow(ordinary_factor, index)

    if abs(amplitude) > computed_ratio:
      ratio = computed_ratio
      ordinate_values = []

      for sub_index in range(-6, 6):
        ordinate_values.push_back(5 * sub_index * computed_ratio / ordinary_factor)

  # Keep only valid values
  for value in ordinate_values:
    if value <= p_max_value and value >= p_min_value:
      result.push_back(value)

  return result
