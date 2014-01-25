# encoding: utf-8

recipe = new Recipe
  name: 'slash_symbols'
  version: '1.0'
  category: 'settings'
  description: '啓用特殊符號(/fh)'
  params: [
    {
      name: 'schema'
      label: '選取輸入方案'
      default: 'luna_pinyin'
      required: true
    }
  ]
  setup: (done) ->
    @customize @params['schema'], done, (c) ->
      c.patch 'punctuator/import_preset', 'symbols'
      c.patch 'recognizer/patterns/punct', '^/[a-z]*$'

cook recipe, ingredients
