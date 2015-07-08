log = -> console.log arguments...
{benchmark, times, map, collect} = require "../../src/index"

# number of iterations
N = 1e3

# the numbers 0-999
a = [0...1e4]

# for-loop
f1 = ->
  (i for i in a)
  # prevent accumulation of array
  true

log "for-loop", benchmark -> times f1, N

# iterators
f2 = ->
  # for loops don't yet work with iterators in Node
  # `
  # for (let i of a) { console.log(i) }
  # `
  i = a[Symbol.iterator]()
  loop
    {value, done} = i.next()
    break if done

log "Iterators", benchmark -> times f2, N

# Fairmont iterators
{collect, map, identity} = require "../../src/index"
f3 = ->
  collect map identity, a

log "Fairmont iterator functions", benchmark -> times f3, N

# forEach
f4 = ->
  a.forEach identity

log "forEach", benchmark -> times f4, N
