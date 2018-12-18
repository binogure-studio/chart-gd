extends Control

onready var chart_node = get_node('chart')

func _ready():
  chart_node.initialize(chart_node.LABELS_TO_SHOW.NO_LABEL,
  {
    depenses = Color(1.0, 0.18, 0.18),
    recettes = Color(0.58, 0.92, 0.07)
  })

  chart_node.create_new_point({
    label = 'JANVIER',
    values = {
      depenses = 150,
      recettes = 1025
    }
  })

  chart_node.create_new_point({
    label = 'FEVRIER',
    values = {
      depenses = 500,
      recettes = 1020
    }
  })

  chart_node.create_new_point({
    label = 'MARS',
    values = {
      depenses = 10,
      recettes = 1575
    }
  })

  chart_node.create_new_point({
    label = 'AVRIL',
    values = {
      depenses = 350,
      recettes = 750
    }
  })

  chart_node.create_new_point({
    label = 'MAI',
    values = {
      depenses = 1350,
      recettes = 750
    }
  })

  chart_node.create_new_point({
    label = 'JUIN',
    values = {
      depenses = 350,
      recettes = 1750
    }
  })

  chart_node.create_new_point({
    label = 'JUILLET',
    values = {
      depenses = 100,
      recettes = 1500
    }
  })

  chart_node.create_new_point({
    label = 'AOUT',
    values = {
      depenses = 350,
      recettes = 750
    }
  })

  chart_node.create_new_point({
    label = 'SEPTEMBRE',
    values = {
      depenses = 1350,
      recettes = 750
    }
  })

  chart_node.create_new_point({
    label = 'OCTOBRE',
    values = {
      depenses = 350,
      recettes = 1750
    }
  })

  chart_node.create_new_point({
    label = 'NOVEMBRE',
    values = {
      depenses = 450,
      recettes = 200
    }
  })

  chart_node.create_new_point({
    label = 'DECEMBRE',
    values = {
      depenses = 1350,
      recettes = 500
    }
  })
