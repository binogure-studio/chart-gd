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

func reset():
  if chart_node.chart_type == chart_node.CHART_TYPE.JAPANESE_CANDLESTICK_CHART:
    chart_node.create_new_point({"exit_value":14, "entry_value":27, "min_value":2, "max_value":40})
    chart_node.create_new_point({"exit_value":24, "entry_value":23, "min_value":4, "max_value":41})
    chart_node.create_new_point({"exit_value":38, "entry_value":31, "min_value":2, "max_value":41})
    chart_node.create_new_point({"exit_value":18, "entry_value":20, "min_value":2, "max_value":37})
    chart_node.create_new_point({"exit_value":10, "entry_value":33, "min_value":8, "max_value":49})
    chart_node.create_new_point({"exit_value":26, "entry_value":33, "min_value":9, "max_value":50})
    chart_node.create_new_point({"exit_value":24, "entry_value":29, "min_value":8, "max_value":49})
    chart_node.create_new_point({"exit_value":28, "entry_value":8, "min_value":8, "max_value":46})
    chart_node.create_new_point({"exit_value":21, "entry_value":29, "min_value":2, "max_value":35})
    chart_node.create_new_point({"exit_value":28, "entry_value":22, "min_value":2, "max_value":37})
    chart_node.create_new_point({"exit_value":20, "entry_value":41, "min_value":10, "max_value":51})
    chart_node.create_new_point({"exit_value":5, "entry_value":30, "min_value":2, "max_value":37})
    chart_node.create_new_point({"exit_value":22, "entry_value":40, "min_value":3, "max_value":43})
    chart_node.create_new_point({"exit_value":10, "entry_value":40, "min_value":5, "max_value":44})
    chart_node.create_new_point({"exit_value":10, "entry_value":13, "min_value":4, "max_value":40})
    chart_node.create_new_point({"exit_value":13, "entry_value":41, "min_value":6, "max_value":46})
    chart_node.create_new_point({"exit_value":5, "entry_value":4, "min_value":2, "max_value":39})
    chart_node.create_new_point({"exit_value":22, "entry_value":6, "min_value":2, "max_value":37})
    chart_node.create_new_point({"exit_value":35, "entry_value":35, "min_value":7, "max_value":47})
    chart_node.create_new_point({"exit_value":25, "entry_value":28, "min_value":11, "max_value":54})
    chart_node.create_new_point({"exit_value":14, "entry_value":14, "min_value":2, "max_value":38})
    chart_node.create_new_point({"exit_value":47, "entry_value":44, "min_value":10, "max_value":52})
    chart_node.create_new_point({"exit_value":3, "entry_value":16, "min_value":2, "max_value":38})
    chart_node.create_new_point({"exit_value":34, "entry_value":29, "min_value":7, "max_value":49})
    chart_node.create_new_point({"exit_value":40, "entry_value":20, "min_value":7, "max_value":47})
    chart_node.create_new_point({"exit_value":15, "entry_value":36, "min_value":10, "max_value":52})
    chart_node.create_new_point({"exit_value":4, "entry_value":23, "min_value":2, "max_value":37})
    chart_node.create_new_point({"exit_value":48, "entry_value":17, "min_value":9, "max_value":50})
    chart_node.create_new_point({"exit_value":33, "entry_value":10, "min_value":2, "max_value":37})
    chart_node.create_new_point({"exit_value":30, "entry_value":9, "min_value":2, "max_value":37})
    chart_node.create_new_point({"exit_value":36, "entry_value":29, "min_value":6, "max_value":42})
    chart_node.create_new_point({"exit_value":15, "entry_value":23, "min_value":2, "max_value":39})
    chart_node.create_new_point({"exit_value":7, "entry_value":25, "min_value":2, "max_value":38})
    chart_node.create_new_point({"exit_value":14, "entry_value":34, "min_value":2, "max_value":36})
    chart_node.create_new_point({"exit_value":20, "entry_value":22, "min_value":9, "max_value":52})
    chart_node.create_new_point({"exit_value":12, "entry_value":25, "min_value":2, "max_value":37})
    chart_node.create_new_point({"exit_value":22, "entry_value":16, "min_value":10, "max_value":52})
    chart_node.create_new_point({"exit_value":11, "entry_value":37, "min_value":2, "max_value":39})
    chart_node.create_new_point({"exit_value":8, "entry_value":39, "min_value":7, "max_value":47})
    chart_node.create_new_point({"exit_value":41, "entry_value":34, "min_value":11, "max_value":55})
    chart_node.create_new_point({"exit_value":20, "entry_value":23, "min_value":2, "max_value":36})
    chart_node.create_new_point({"exit_value":34, "entry_value":38, "min_value":5, "max_value":45})
    chart_node.create_new_point({"exit_value":27, "entry_value":2, "min_value":2, "max_value":39})
    chart_node.create_new_point({"exit_value":22, "entry_value":21, "min_value":10, "max_value":51})
    chart_node.create_new_point({"exit_value":33, "entry_value":25, "min_value":2, "max_value":36})
    chart_node.create_new_point({"exit_value":26, "entry_value":16, "min_value":2, "max_value":37})
    chart_node.create_new_point({"exit_value":47, "entry_value":42, "min_value":10, "max_value":50})
    chart_node.create_new_point({"exit_value":34, "entry_value":34, "min_value":2, "max_value":40})
    chart_node.create_new_point({"exit_value":28, "entry_value":6, "min_value":2, "max_value":37})
    chart_node.create_new_point({"exit_value":10, "entry_value":32, "min_value":2, "max_value":40})
    chart_node.create_new_point({"exit_value":9, "entry_value":35, "min_value":9, "max_value":51})
    chart_node.create_new_point({"exit_value":40, "entry_value":27, "min_value":4, "max_value":43})
    chart_node.create_new_point({"exit_value":20, "entry_value":33, "min_value":5, "max_value":43})
    chart_node.create_new_point({"exit_value":34, "entry_value":19, "min_value":4, "max_value":40})
    chart_node.create_new_point({"exit_value":35, "entry_value":36, "min_value":4, "max_value":41})
    chart_node.create_new_point({"exit_value":28, "entry_value":47, "min_value":10, "max_value":52})
    chart_node.create_new_point({"exit_value":13, "entry_value":2, "min_value":2, "max_value":37})
    chart_node.create_new_point({"exit_value":33, "entry_value":20, "min_value":6, "max_value":46})
    chart_node.create_new_point({"exit_value":33, "entry_value":29, "min_value":2, "max_value":37})
    chart_node.create_new_point({"exit_value":21, "entry_value":25, "min_value":2, "max_value":36})
    chart_node.create_new_point({"exit_value":18, "entry_value":10, "min_value":5, "max_value":41})
    chart_node.create_new_point({"exit_value":23, "entry_value":15, "min_value":3, "max_value":37})
    chart_node.create_new_point({"exit_value":27, "entry_value":13, "min_value":2, "max_value":39})
    chart_node.create_new_point({"exit_value":28, "entry_value":22, "min_value":2, "max_value":36})
    chart_node.create_new_point({"exit_value":15, "entry_value":20, "min_value":3, "max_value":40})
    chart_node.create_new_point({"exit_value":50, "entry_value":43, "min_value":10, "max_value":52})
    chart_node.create_new_point({"exit_value":24, "entry_value":35, "min_value":2, "max_value":37})
    chart_node.create_new_point({"exit_value":32, "entry_value":31, "min_value":7, "max_value":46})
    chart_node.create_new_point({"exit_value":28, "entry_value":22, "min_value":2, "max_value":42})
    chart_node.create_new_point({"exit_value":14, "entry_value":19, "min_value":2, "max_value":37})
    chart_node.create_new_point({"exit_value":34, "entry_value":35, "min_value":7, "max_value":48})
    chart_node.create_new_point({"exit_value":5, "entry_value":32, "min_value":3, "max_value":37})
    chart_node.create_new_point({"exit_value":20, "entry_value":51, "min_value":11, "max_value":52})
    chart_node.create_new_point({"exit_value":39, "entry_value":2, "min_value":2, "max_value":41})
    chart_node.create_new_point({"exit_value":25, "entry_value":13, "min_value":2, "max_value":38})
    chart_node.create_new_point({"exit_value":3, "entry_value":11, "min_value":2, "max_value":36})
    chart_node.create_new_point({"exit_value":9, "entry_value":7, "min_value":2, "max_value":37})
    chart_node.create_new_point({"exit_value":29, "entry_value":11, "min_value":2, "max_value":37})
    chart_node.create_new_point({"exit_value":41, "entry_value":35, "min_value":10, "max_value":53})
    chart_node.create_new_point({"exit_value":14, "entry_value":29, "min_value":2, "max_value":37})
    chart_node.create_new_point({"exit_value":9, "entry_value":7, "min_value":6, "max_value":45})
    chart_node.create_new_point({"exit_value":8, "entry_value":14, "min_value":5, "max_value":41})
    chart_node.create_new_point({"exit_value":43, "entry_value":18, "min_value":10, "max_value":58})
    chart_node.create_new_point({"exit_value":29, "entry_value":36, "min_value":2, "max_value":38})
    chart_node.create_new_point({"exit_value":17, "entry_value":16, "min_value":6, "max_value":43})
    chart_node.create_new_point({"exit_value":20, "entry_value":6, "min_value":2, "max_value":37})
    chart_node.create_new_point({"exit_value":6, "entry_value":34, "min_value":2, "max_value":36})
    chart_node.create_new_point({"exit_value":32, "entry_value":15, "min_value":3, "max_value":39})
    chart_node.create_new_point({"exit_value":9, "entry_value":5, "min_value":5, "max_value":42})
    chart_node.create_new_point({"exit_value":24, "entry_value":31, "min_value":3, "max_value":40})
    chart_node.create_new_point({"exit_value":12, "entry_value":22, "min_value":2, "max_value":36})
    chart_node.create_new_point({"exit_value":5, "entry_value":4, "min_value":2, "max_value":39})
    chart_node.create_new_point({"exit_value":11, "entry_value":46, "min_value":8, "max_value":49})
    chart_node.create_new_point({"exit_value":33, "entry_value":44, "min_value":8, "max_value":49})
    chart_node.create_new_point({"exit_value":13, "entry_value":12, "min_value":9, "max_value":48})
    chart_node.create_new_point({"exit_value":4, "entry_value":5, "min_value":2, "max_value":37})
    chart_node.create_new_point({"exit_value":7, "entry_value":27, "min_value":2, "max_value":36})
    chart_node.create_new_point({"exit_value":10, "entry_value":9, "min_value":7, "max_value":48})
    chart_node.create_new_point({"exit_value":14, "entry_value":19, "min_value":10, "max_value":52})
    chart_node.create_new_point({"exit_value":25, "entry_value":39, "min_value":7, "max_value":48})


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
