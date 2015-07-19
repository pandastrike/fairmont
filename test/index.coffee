targets = process.argv[2..]

if targets.length == 0
  targets = [
    "array"
    "async"
    "core"
    "crypto"
    "fs"
    "iterator"
    "logical"
    "multimethods"
    "numeric"
    "object"
    "reactive"
    "string"
    "type"
    "util"
  ]

(require "./#{target}") for target in targets
