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
  files: [
    'https://gist.github.com/lotem/5440677/raw/custom_phrase.txt'
  ]
  setup: (done) ->
    schemaId = @params['schema']
    schemaFile = @findConfigFile "#{schemaId}.schema.yaml"
    unless schemaFile
      done new Error "schema '#{schemaId}' could not be found."
      return
    s = new Config
    s.loadFile schemaFile, (err) =>
      mainTranslators = [
        /^r10n_translator/
        /^reverse_lookup_translator/
        /^script_translator/
        /^table_translator/
      ]
      customPhraseTranslator = 'table_translator@custom_phrase'
      translators = s.get 'engine/translators'
      unless customPhraseTranslator in translators
        # insert custom phrase translator before main translators
        index = 0
        for x in translators
          if mainTranslators.some((elem) -> elem.test x)
            break
          ++index
        translators.splice index, 0, customPhraseTranslator
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
