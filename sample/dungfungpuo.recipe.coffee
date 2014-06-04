# encoding: utf-8

cook new Recipe
  name: 'dungfungpuo'
  version: '0.2'
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
  sha1sum:
    "dungfungpuo.dict.yaml": "7615c6e1402ef122bddc7c65205954cb1e653450"
    "dungfungpuo.schema.yaml": "b0f9c5f45ff05158c94c61a736fc26c142470e22"
