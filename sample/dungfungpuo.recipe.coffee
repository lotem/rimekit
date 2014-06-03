# encoding: utf-8

cook new Recipe
  name: 'dungfungpuo'
  version: '0.1'
  category: 'schema'
  description: '東風破古韻輸入法'
  files: [
    'https://raw.github.com/lotem/rime-forge/master/dungfungpuo/dungfungpuo.schema.yaml'
    'https://raw.github.com/lotem/rime-forge/master/dungfungpuo/dungfungpuo.dict.yaml'
  ]
  setup: ->
    @installSchema('dungfungpuo')
    .then =>
      @enableSchema('dungfungpuo')
