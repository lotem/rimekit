# encoding: utf-8

recipe = new Recipe
  name: 'custom_phrase'
  version: '1.0'
  category: 'settings'
  description: '啓用自定義短語'
  params: [
    {
      name: 'schema'
      label: '選取輸入方案'
      required: true
    }
  ]
  setup: (done) ->
    schemaId = @params['schema']
    s = new Config
    s.loadFile "#{@rimeDirectory}/#{schemaId}schema.yaml", (s) =>
      main_translators = [
        'reverse_lookup_translator'
        'table_translator'
        'script_translator'
      ]
      translators = s.get 'engine/translators'
      index = 0
      for t in translators
        if t in main_translators  # TODO: handle those with aliases
          break
        ++index
      translators.insert index, 'table_translator@custom_phrase'
      @customize schemaId, done, (c) ->
        c.patch 'engine/translators', translators
        c.patch 'custom_phrase',
          dictionary: ''
          user_dict: 'custom_phrase'
          db_class: 'stabledb'
          enable_completion: false
          enable_sentence: false
          initial_quality: 1

cook recipe, ingredients
