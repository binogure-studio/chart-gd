extends Control

onready var chart_node = get_node('chart')
onready var fps_label = get_node('benchmark/fps')
onready var points_label = get_node('benchmark/points')

func _ready():
  chart_node.initialize(chart_node.LABELS_TO_SHOW.NO_LABEL,
  {
    depenses = Color(1.0, 0.18, 0.18),
    recettes = Color(0.58, 0.92, 0.07),
    interet = Color(0.5, 0.22, 0.6)
  })

  reset()
  set_process(true)

func set_chart_type(chart_type):
  chart_node.clear_chart()
  chart_node.set_chart_type(chart_type)

  reset()

func _process(delta):
  fps_label.set_text('FPS: %02d' % [OS.get_frames_per_second()])
  points_label.set_text('NB POINTS: %d' % [chart_node.current_data_size * 3.0])

func _generate_candle_stick_value():
  var entry_value = randi() % 128
  var exit_value = randi() % 128

  var min_value = min(randi() % 128, min(exit_value, entry_value))
  var max_value = max(randi() % 128, max(exit_value, entry_value))

  return {
    exit_value = exit_value,
    entry_value = entry_value, 
    min_value = min_value, 
    max_value = max_value
  }

func reset():
  if chart_node.chart_type == chart_node.CHART_TYPE.JAPANESE_CANDLESTICK_CHART:
    for index in range(0, 12):
      chart_node.create_new_point(_generate_candle_stick_value())

  elif chart_node.chart_type == chart_node.CHART_TYPE.HISTOBAR_CHART:
    chart_node.create_new_point({
      depenses = randi() % 8192,
      recettes = randi() % 1024,
      interet = randi() % 512
    })

  else:
    chart_node.create_new_point({
      label = 'JANVIER',
      values = {
        depenses = 150,
        recettes = 1025,
        interet = 1050
      }
    })

    chart_node.create_new_point({
      label = 'FEVRIER',
      values = {
        depenses = 500,
        recettes = 1020,
        interet = -150
      }
    })

    chart_node.create_new_point({
      label = 'MARS',
      values = {
        depenses = 10,
        recettes = 1575,
        interet = -450
      }
    })

    chart_node.create_new_point({
      label = 'AVRIL',
      values = {
        depenses = 350,
        recettes = 750,
        interet = -509
      }
    })

    chart_node.create_new_point({
      label = 'MAI',
      values = {
        depenses = 1350,
        recettes = 750,
        interet = -505
      }
    })

    chart_node.create_new_point({
      label = 'JUIN',
      values = {
        depenses = 350,
        recettes = 1750,
        interet = -950
      }
    })

    chart_node.create_new_point({
      label = 'JUILLET',
      values = {
        depenses = 100,
        recettes = 1500,
        interet = -350
      }
    })

    chart_node.create_new_point({
      label = 'AOUT',
      values = {
        depenses = 350,
        recettes = 750,
        interet = -500
      }
    })

    chart_node.create_new_point({
      label = 'SEPTEMBRE',
      values = {
        depenses = 1350,
        recettes = 750,
        interet = -50
      }
    })

    chart_node.create_new_point({
      label = 'OCTOBRE',
      values = {
        depenses = 350,
        recettes = 1750,
        interet = -750
      }
    })

    chart_node.create_new_point({
      label = 'NOVEMBRE',
      values = {
        depenses = 450,
        recettes = 200,
        interet = -150
      }
    })

    chart_node.create_new_point({
      label = 'DECEMBRE',
      values = {
        depenses = 1350,
        recettes = 500,
        interet = -500
      }
    })
