# encoding: utf-8

cook new Recipe
  name: 'dungfungpuo'
  version: '0.1'
  category: 'schema'
  description: '東風破古韻輸入法'
  files: [
    'https://github.com/lotem/rime-forge/blob/master/dungfungpuo/dungfungpuo.schema.yaml'
    'https://github.com/lotem/rime-forge/blob/master/dungfungpuo/dungfungpuo.dict.yaml'
  ]
  setup: ->
    @installSchema 'dungfungpuo'
      enable: true
