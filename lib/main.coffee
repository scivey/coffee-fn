_ = require 'underscore'

# 
# BASICS
#

flatsplat = (maybeList) ->
    if _.isArray(maybeList[0]) and maybeList.length is 1
        return maybeList[0]
    maybeList

ensureList = (elem) ->
    if _.isArray(elem) then elem else [elem]

cat = (lists...) ->
    lists = _.map(flatsplat(lists), ensureList)
    shallow = true
    _.flatten(lists, shallow)

partial2 = (fn, x, y) ->
    if y?
        fn x, y
    else
        if x?
            (y) ->
                fn x, y
        else
            (x, y) ->
                if y?
                    fn x, y
                else
                    (y) ->
                        fn x, y

partial3 = (fn, x, y, z) ->
    if z?
        fn x, y, z
    else
        if y?
            (z) ->
                fn x, y, z
        else
            if x?
                (y, z) ->
                    if z?
                        fn x, y, z
                    else
                        (z) ->
                            fn x, y, z
            else
                (x, y, z) ->
                    if z?
                        fn x, y, z
                    else
                        if y?
                            (z) ->
                                fn x, y, z
                        else
                                (y, z) ->
                                    if z?
                                        fn x, y, z
                                    else
                                        (z) ->
                                            fn x, y, z

rev2 = (fn, x, y) ->
    fn y, x

rev2 = partial3 rev2




#
# LIST OPERATIONS
#

nth = (index, aList) ->
    aList[index]
nth = partial2 nth

nthMap = (aList, fn, n) ->
    _.map aList, (subList) ->
        sub = _.clone(subList)
        sub[n] = fn(sub[n])
        sub

valMap = (obj, fn) ->
    _.object(nthMap(_.pairs(obj), fn, 1))
valMap = partial2 valMap
valMapWith = rev2 valMap


keyMap = (obj, fn) ->
    _.object(nthMap(_.pairs(obj), fn, 0))
keyMap = partial2 keyMap
keyMapWith = rev2 keyMap


deepClone = (something) ->
    if _.isArray(something) then return _.map(something, deepClone)
    if _.isObject(something) then return valMap(something, deepClone)
    return something



# 
# PREDICATES
#


negate = (fn, params...) ->
    params = flatsplat params
    ! fn.apply(null, params)

negate = partial2 negate

lt = partial2 (y, x) -> x < y
gt = partial2 (y, x) -> x > y
gte = partial2 (y, x) -> x >= y
lte = partial2 (y, x) -> x <= y
eq = partial2 (x, y) -> x is y
neq = partial2 (x, y) -> x isnt y

isOdd = (x) ->
    (x % 2) > 0

isEven = negate isOdd

allTrue = (preds, vals...) ->
    testOne = (onePred) ->
        onePred.apply null, vals

    _.all preds, testOne

allFalse = (preds, vals...) ->
    allBad = true
    for pred in preds
        result = pred.apply null, vals
        if result
            allBad = false
            break
    allBad

anyTrue = (preds, vals...) ->
    testOne = (onePred) ->
        onePred.apply null, vals

    _.any preds, testOne

anyFalse = (preds, vals...) ->
    anyBad = false
    for pred in preds
        result = pred.apply null, vals
        unless result
            anyBad = true
            break
    anyBad

allTrue = partial2 allTrue
allFalse = partial2 allFalse
anyTrue = partial2 anyTrue
anyFalse = partial2 anyFalse









#
# TYPE COERCION
#

boolize = (val) ->
    !! val









#
# LIST OPERATIONS
#


ijth = (i, j, matrix) ->
    matrix[i][j]

ijth = partial3 ijth

nthCol = (index, matrix) ->
    _.map matrix, nth(index)

catMap = (list, fn) ->
    cat(_.map(list, fn))

catMapWith = rev2 catMap
catMap = partial2 catMap

zipMap = (list, fn) ->
    _.zip list, _.map(list, fn)

zipMapWith = rev2 zipMap

zipNext = (aList) ->
    _.zip(aList, aList.slice(1))


joinWith = (separator, list) ->
    list.join(separator)

joinWith = partial2 joinWith

mapWith = rev2 _.map
filterWith = rev2 _.filter




# 
# MATH
# 
add = partial2 (x, y) -> x + y
sub = partial2 (x, y) -> x - y
subBy = rev2 sub
mul = partial2 (x, y) -> x * y
div = partial2 (x, y) -> x / y
divBy = rev2 div
toPow = partial2 (exp, base) -> Math.pow(base, exp)

sum = (nums...) ->
    fn = (x,y) -> x + y
    nums = flatsplat nums
    _.reduce nums, fn, 0

avg = (nums...) ->
    nums = flatsplat nums
    sum(nums) / nums.length

product = (nums...) ->
    nums = flatsplat nums
    fn = (x,y) -> x * y
    _.reduce(nums, fn, 1)

# FUNCTION FUNCTIONS

arity = (n, fn) ->
    (params...) ->
        fn.apply(null, _.first(params, n))

ply = (fn, params) -> fn.apply(null, params)
plyTo = rev2 ply
ply = partial2 ply


funcMap = (funcs, val) ->
    _.map funcs, plyTo(ensureList(val))
funcMap = partial2 funcMap

constantly = (val) -> (x) -> _.clone(val)
konst = constantly

repeatedly = (fn, count, params...) ->
    params = zipMap _.range(0,count), constantly(flatsplat(params))
    _.map(params, ply(fn))
repeatedly = partial2(repeatedly)

repeatVal = (val, n) ->
    _.map(_.range(0, n), konst(val))






# OBJECT FUNCTIONS

keyify = (keyList) ->
    _.object(_.zip(keyList, repeatVal(true, _.size(keyList))))

asKey = (keyName, val) ->
    out = {}
    out[keyName] = val
    out

asKey = partial2 asKey

asKeys = (keyNames, aList) ->
    obj = {}
    _.each keyNames, (oneKey, index) ->
        val = aList[index]
        if _.isUndefined(val)
            val = null
        obj[oneKey] = val
    obj

asKeys = partial2 asKeys

objMap = (obj, keyFn, valFn) ->
    out = {}
    _.each obj, (val, key) ->
        k = keyFn(key, val)
        v = valFn(val, key)
        out[k] = v
    out

objMap = partial3 objMap

objMapWith = (keyFn, valFn, obj) ->
    objMap obj, keyFn, valFn

objMapWith = partial3 objMapWith

extend = (objects...) ->
    out = {}
    objects = flatsplat(objects)
    _.extend.apply(null, [out].concat(objects))
    out


exp =
    partial2: partial2
    partial3: partial3
    rev2: rev2
    flatsplat: flatsplat
    negate: negate
    isEven: isEven
    isOdd: isOdd
    gt: gt
    lt: lt
    eq: eq
    neq: neq
    lte: lte
    gte: gte
    allTrue: allTrue
    allFalse: allFalse
    anyTrue: anyTrue
    anyFalse: anyFalse
    arity: arity
    ply: ply
    plyTo: plyTo
    constantly: constantly
    konst: constantly
    repeatedly: repeatedly
    rpt: repeatedly
    funcMap: funcMap
    deepClone: deepClone
    ensureList: ensureList
    cat: cat
    nth: nth
    nthMap: nthMap
    nthCol: nthCol
    ijth: ijth
    catMap: catMap
    catMapWith: catMapWith
    filterWith: filterWith
    zipMap: zipMap
    zipMapWith: zipMapWith
    mapWith: mapWith
    joinWith: joinWith
    add: add
    sub: sub
    mul: mul
    div: div
    subBy: subBy
    divBy: divBy
    toPow: toPow
    sum: sum
    product: product
    avg: avg
    asKey: asKey
    asKeys: asKeys
    keyify: keyify
    valMap: valMap
    valMapWith: valMapWith
    keyMap: keyMap
    keyMapWith: keyMapWith
    objMap: objMap
    objMapWith: objMapWith
    zipNext: zipNext
    extend: extend

module.exports = exp

