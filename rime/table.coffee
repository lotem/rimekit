fs = require('fs')
os = require('os')
path = require('path')
marisa = require('node-marisa-trie')

EPSILON = 1e-10

exports.Table = class Table
  loadFile: (filePath) ->
    new Promise (resolve, reject) =>
      fs.readFile filePath, (err, data) =>
        if err
          console.error "error loading table: #{err}"
          reject err
        else
          console.log "read table #{filePath}"
          @dictName = path.basename filePath, '.table.bin'
          @formatVersion = @getFormatVersion data
          if @formatVersion > 2.0 - EPSILON
            @stringTable = @loadStringTable data
          @syllabary = @getSyllabary data
          @stringTable = null
          resolve()

  getFormatVersion: (buf) ->
    format = @getString buf, 0
    match = /^Rime::Table\/(\d+\.\d+)/.exec(format)
    parseFloat match?[1]

  loadStringTable: (buf) ->
    offset = 60  # metadata.string_table
    stringTableOffset = offset + buf.readInt32LE(offset)
    offset += 4
    stringTableSize = buf.readUInt32LE(offset)
    offset += 4
    trieData = buf.slice stringTableOffset, stringTableOffset + stringTableSize
    trie = marisa.createTrie()
    trie.map trieData
    trie

  getSyllabary: (buf) ->
    getSyllable = switch
      when @formatVersion > 2.0 - EPSILON then @getSyllable_v2
      else @getSyllable_v1
    result = []
    offset = 44  # metadata.syllabary
    offset += buf.readInt32LE(offset)  # syllabary
    syllabarySize = buf.readUInt32LE(offset)
    offset += 4
    for i in [0...syllabarySize]
      result.push getSyllable.call @, buf, offset
      offset += 4
    result

  getSyllable_v2: (buf, offset) ->
    stringId = buf.readUInt32LE(offset)
    agent = marisa.createAgent()
    agent.set_query stringId
    @stringTable.reverse_lookup agent
    key = agent.key()
    key.ptr().substring(0, key.length())

  getSyllable_v1: (buf, offset) ->
    entryOffset = offset + buf.readInt32LE(offset)
    @getString buf, entryOffset

  getString: (buf, offset) ->
    end = offset
    ++end while buf[end] != 0  # find '\0'
    buf.toString('utf8', offset, end)
