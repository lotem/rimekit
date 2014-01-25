# encoding: utf-8

recipe = new Recipe
  name: 'horizontal_layout'
  version: '1.0'
  category: 'settings'
  description: '候選窗横排'
  params: [
    {
      name: 'distro'
      options:
        'weasel': '小狼毫'
        'squirrel': '鼠鬚管'
      required: true
    }
  ]
  setup: (done) ->
    @customize @params['distro'], done, (c) ->
      c.patch 'style/horizontal', true

cook recipe, ingredients
