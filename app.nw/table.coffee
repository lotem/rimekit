fs = require('fs')

class Table
  loadFile: (filePath, callback) ->
    fs.readFile filePath, (err, data) =>
      throw err if err
      console.log "read table #{filePath}"
      callback(@getSyllabary data)

  getSyllabary: (buf) ->
    result = []
    offset = 44  # metadata.syllabary
    offset += buf.readInt32LE(offset)  # syllabary
    syllabarySize = buf.readUInt32LE(offset)
    offset += 4
    for i in [0...syllabarySize]
      entryOffset = offset + buf.readInt32LE(offset)
      result.push @getEntry buf, entryOffset
      offset += 4
    return result

  getEntry: (buf, offset) ->
    end = offset
    ++end while buf[end] != 0  # find '\0'
    buf.toString('utf8', offset, end)
