const ordinary_factor = 10
const range_factor = 1000
const units = ['', 'K', 'M', 'B', 'G']

static func format(number):
  return _format(number, '%.2f %s')

static func iformat(number):
  return _format(number, '%d %s')

static func _format(number, format_text_custom):
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

static func compute_ordinate_values(max_value, min_value):
  var amplitude = max_value - min_value
  var unit_index = 0
  var ordinate_values = [-10, -8, -6, -4, -2, 0, 2, 4, 6, 8, 10]
  var result = []
  var ratio = 1

  for index in range(0, ordinary_factor):
    var computed_ratio = pow(ordinary_factor, index)

    if abs(amplitude) > computed_ratio:
      ratio = computed_ratio
      unit_index = index
      ordinate_values = []

      for index in range(-6, 6):
        ordinate_values.append(5 * index * computed_ratio / ordinary_factor)

  # Keep only valid values
  for value in ordinate_values:
    if value <= max_value and value >= min_value:
      result.append(value)

  return result

static func random(min_value, max_value):
  randomize()

  return randi() % int(max_value - min_value) + int(min_value)

static func randomf(min_value, max_value):
  randomize()

  return randf() * float(max_value - min_value) + float(min_value)
