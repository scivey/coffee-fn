_ = require 'underscore'
func = require '../index.js'
chai = require 'chai'
sinon = require 'sinon'

assert = chai.assert

add = (x,y) -> x + y
mul3 = (x,y,z) -> x * y * z

describe 'partial2', ->
	{partial2} = func
	it 'works', ->
		add5 = partial2(add, 5)
		assert.equal(add5(3), (5 + 3))
		assert.equal(partial2(add, 5, 3), 8)
		assert.equal(partial2(add)(5)(3), 8)
		assert.equal(partial2(add)(5, 3), 8)
		assert.equal(partial2(add, 5)(3), 8)

describe 'partial3', ->
	{partial3} = func
	it 'works', ->
		expected = 5 * 10 * 3
		assert.equal(mul3(5,10,3), expected)
		assert.equal(partial3(mul3, 5, 10, 3), expected)
		assert.equal(partial3(mul3, 5, 10)(3), expected)
		assert.equal(partial3(mul3, 5)(10)(3), expected)
		assert.equal(partial3(mul3)(5)(10,3), expected)
		assert.equal(partial3(mul3)(5, 10)(3), expected)
		assert.equal(partial3(mul3)(5)(10)(3), expected)
		assert.equal(partial3(mul3, 5)(10,3), expected)


describe 'nthMap', ->
	{nthMap} = func
	it 'returns a list with the `nth` element mapped', ->
		nums = [[1,5],[2,10],[3,15]]
		f = (x) -> x * 2
		map1 = nthMap(nums, f, 1)
		assert.deepEqual(map1, [[1,10],[2,20],[3,30]])

		map2 = nthMap(nums, f, 0)
		assert.deepEqual(map2, [[2,5],[4,10],[6,15]])



describe 'deepClone', ->
	{deepClone} = func
	it 'works', ->
		obj =
			a:
				val: 17
			b:
				spazz: [11]

		anotherObj =
			a:
				val: 17
			b:
				spazz: [11]

		expected =
			a:
				val: 10
			b:
				spazz: [11, 3]

		cloned = deepClone(obj)
		assert.deepEqual obj, anotherObj
		assert.deepEqual cloned, obj
		assert.notEqual cloned, obj

		cloned.a.val = 10
		cloned.b.spazz.push(3)
		assert.deepEqual cloned, expected

		# original is unchanged
		assert.deepEqual obj, anotherObj


describe 'objMap', ->
	{objMap} = func
	it 'works', ->
		obj =
			a: 1
			b: 2
			c: 3
		expected =
			thing_a: 10
			thing_b: 20
			thing_c: 30

		prependThing = (str) -> "thing_#{str}"
		mul10 = (x) -> x * 10
		assert.deepEqual objMap(obj, prependThing, mul10), expected


describe 'objMapWith', ->
	{objMap} = func
	it 'works', ->
		obj =
			a: 1
			b: 2
			c: 3
		expected =
			thing_a: 10
			thing_b: 20
			thing_c: 30

		prependThing = (str) -> "thing_#{str}"
		mul10 = (x) -> x * 10

		fn = func.objMapWith(prependThing, mul10)

		assert.deepEqual fn(obj), expected



describe 'valMap', ->
	{valMap} = func
	it 'works', ->
		obj =
			a: 1
			b: 2
			c: 3
		expected =
			a: 6
			b: 7
			c: 8

		add5 = (x) -> x + 5

		mapped = valMap(obj, add5)
		assert.deepEqual(mapped, expected)

describe 'keyMap', ->
	{keyMap} = func
	it 'works', ->
		obj =
			a: 1
			b: 2
			c: 3
		expected =
			key_a: 1
			key_b: 2
			key_c: 3

		prependKey = (str) -> 'key_' + str

		mapped = keyMap(obj, prependKey)
		assert.deepEqual(mapped, expected)

describe 'extend', ->
	{extend} = func
	it 'works', ->
		one =
			a: 5
		two =
			b: 6
		three =
			c: 7

		expected =
			a: 5
			b: 6
			c: 7

		extended = extend(one,two,three)
		assert.deepEqual(extended, expected)
		_.each [one,two,three], (elem) ->
			assert.equal _.keys(elem).length, 1



describe 'keyify', ->
	it 'works', ->
		keys = ['one', 'two', 'three']
		expected =
			one: true
			two: true
			three: true
		assert.deepEqual func.keyify(keys), expected

describe 'asKey', ->
	it 'works', ->
		vals = [5,3,2]
		expected = [
			{value: 5}
			{value: 3}
			{value: 2}
		]

		mapped = _.map vals, func.asKey('value')
		assert.deepEqual(mapped, expected)

describe 'asKeys', ->
	it 'works', ->
		vals = [
			['john', 20]
			['tom', 15]
			['adam', 26]
		]
		expected = [
			{name: 'john', age: 20}
			{name: 'tom', age: 15}
			{name: 'adam', age: 26}
		]

		mapped = _.map vals, func.asKeys(['name', 'age'])
		assert.deepEqual(mapped, expected)


describe 'predicates', ->
	describe 'comparisons', ->
		it 'works', ->
			{gt, lt, eq, neq, lte, gte} = func
			assert.ok(gt(5)(7))
			assert.ok(gt(5,7))
			assert.notOk(gt(7)(5))
			assert.notOk(gt(7, 5))

			assert.ok(lt(5)(3))
			assert.ok(lt(5, 3))
			assert.notOk(lt(5)(7))
			assert.notOk(lt(5,7))

			assert.ok eq(5, 5)
			assert.ok eq(5)(5)
			assert.notOk eq(5, 7)
			assert.notOk eq(5)(7)

			assert.ok neq(5,7)
			assert.ok neq(5)(7)
			assert.notOk neq(5,5)
			assert.notOk neq(5)(5)

			assert.ok lte(5)(5)
			assert.ok lte(5)(4)
			assert.ok lte(5,5)
			assert.ok lte(5,4)
			assert.notOk lte(5,6)
			assert.notOk lte(5)(6)

			assert.ok gte(5)(5)
			assert.ok gte(5,5)
			assert.ok gte(5,6)
			assert.ok gte(5)(6)
	
	describe 'even/odd', ->
		it 'works', ->
			assert.ok func.isEven(10)
			assert.notOk func.isEven(9)
			assert.ok func.isOdd(9)
			assert.notOk func.isOdd(10)

	describe 'negate', ->
		it 'negates a predicate', ->
			truth = -> true
			opposite = func.negate truth

			assert.notOk opposite(10)

	describe 'pipelines', ->
		{allTrue, allFalse, anyTrue, anyFalse} = func
		lt12 = (x) -> x < 12
		odd = (x) -> !!(x % 2)

		preds = []

		beforeEach ->
			preds = [lt12, odd]

		describe 'allTrue', ->
			it 'works', ->
				assert.ok(allTrue(preds, 9))
				assert.notOk(allTrue(preds, 13))
				assert.notOk(allTrue(preds, 8))


		describe 'allFalse', ->
			it 'works', ->
				assert.ok(allFalse(preds, 14))
				assert.notOk(allFalse(preds, 10))
				assert.notOk(allFalse(preds, 9))

		describe 'anyTrue', ->
			it 'works', ->
				assert.ok(anyTrue(preds, 8))
				assert.ok(anyTrue(preds, 15))
				assert.notOk(anyTrue(preds, 18))

		describe 'anyFalse', ->
			it 'works', ->
				assert.ok(anyFalse(preds, 10))
				assert.ok(anyFalse(preds, 13))
				assert.notOk(anyFalse(preds, 9))

describe 'function functions', ->
	describe 'arity', ->
		it 'works', ->
			bad1 = (x) ->
				if x?
					throw new Error('ARITY NOT LOCKED')

			good1 = func.arity(0,bad1)

			good1(5)
			assert.ok(true)

			bad3 = (x,y,z) ->
				unless y?
					throw new Error('didn\'t get second arg!')
				if z?
					throw new Error('arity not restricted to 2!')

			good3 = func.arity(2, bad3)

			good3(2,5)
			assert.ok(true)

	describe 'funcMap', ->
		it 'works', ->
			add5 = (x) -> x + 5
			sub2 = (x) -> x - 2
			square = (x) -> x * x
			funcs = [add5, square, sub2]

			mapped = func.funcMap(funcs, 9)
			assert.deepEqual(mapped, [14, 81, 7])

	describe 'repeatedly', ->
		{repeatedly, rpt} = func
		it 'works', ->
			assert.equal repeatedly, rpt

			always5 = -> 5

			list = repeatedly(always5, 3)
			assert.equal list.length, 3
			assert.deepEqual list, [5,5,5]

			repeater = repeatedly(always5)

			list = repeater(3)
			assert.equal list.length, 3
			assert.deepEqual list, [5,5,5]

			counted = repeatedly(_.identity, 5)
			assert.equal counted.length, 5
			assert.deepEqual counted, [0,1,2,3,4]


	describe 'constantly', ->
		{constantly, konst} = func
		it 'works', ->
			assert.equal constantly, konst
			always9 = konst(9)
			assert.equal always9(5), 9
		it 'clones non-simple types', ->
			always9and5 = konst([9,5])
			one = always9and5(7)
			assert.deepEqual(one, [9,5])

			two = always9and5(7)
			two.push(3)
			assert.deepEqual(two, [9,5,3])
			assert.notDeepEqual(one,two)
			assert.deepEqual(one, [9,5])

	describe 'ply', ->
		{ply} = func
		it 'works', ->
			add2 = (x,y) -> x + y
			nums = [3,5]
			assert.equal ply(add2, nums), 8

			numList = [
				[3,5]
				[2,4]
				[1,19]
			]
			mapped = _.map numList, ply(add2)
			assert.deepEqual mapped, [8,6,20]

describe 'math', ->
	describe 'add,sub,mul,div,toPow', ->
		it 'works', ->
			{add, sub, mul, div, subBy, divBy, toPow} = func
			
			equal = assert.equal
			ok = assert.ok

			equal add(5,3), 8
			equal add(5)(3), 8

			equal sub(5)(3), 2
			equal sub(5,3), 2

			equal mul(5)(3), 15
			equal mul(5,3), 15

			equal div(10,2), 5
			equal div(10)(2), 5

			equal divBy(2)(10), 5
			equal divBy(2,10), 5

			equal subBy(3)(10), 7
			equal subBy(3, 10), 7

			equal toPow(3, 3), 27
			equal toPow(3)(3), 27

	describe 'sum', ->
		it 'adds numbers', ->
			{sum} = func
			assert.equal sum(5,3,2), 10
			assert.equal sum([5,3,2]), 10

	describe 'product', ->
		it 'multiplies numbers', ->
			{product} = func
			assert.equal product(5,3,2), 30
			assert.equal product([5,3,2]), 30

	describe 'avg', ->
		it 'averages numbers', ->
			{avg} = func
			assert.equal avg(5,15,10,0,20), 10
			assert.equal avg([10,5,15, 0, 20]), 10



	describe 'lists', ->
		describe 'ensureList', ->
			it 'works', ->
				assert.isArray func.ensureList(5)
				assert.isArray func.ensureList([5])

		describe 'zipMap', ->
			it 'zips a list with the results of its mapping', ->
				nums = [1,2,3]
				square = (x) -> x * x
				mapped = func.zipMap(nums, square)
				expected = [[1,1],[2,4],[3,9]]
				assert.deepEqual(mapped, expected)

		describe 'joinWith', ->
			it 'joins list elements with the given string', ->
				letters = [
					['A','B']
					['B','C']
					['C','D']
				]
				joined = _.map letters, func.joinWith('->')
				expected = ['A->B', 'B->C', 'C->D']
				assert.deepEqual(joined, expected)

		describe 'cat', ->
			it 'joins lists', ->
				assert.deepEqual(func.cat([5,3], [9], [4,2]), [5,3,9,4,2])

		describe 'catMap', ->
			it 'joins map results into a list', ->
				makePair = (x) -> [x, x]
				nums = [5,3,2]
				assert.deepEqual(func.catMap(nums, makePair), [5,5,3,3,2,2])

		describe 'nth', ->
			it 'returns nth elem of list', ->
				nums = [1,2,3,4,5]
				assert.equal func.nth(2, nums), 3

		describe 'ijth', ->
			it 'returns the ijth-elem of a matrix', ->
				nums = [
					[1,2,3]
					[4,5,6]
					[7,8,9]
				]

				assert.equal func.ijth(2,1,nums), 8
				assert.equal func.ijth(1,0,nums), 4

		describe 'nthCol', ->
			it 'returns the nth column of a matrix', ->
				nums = [
					[1,2,3]
					[4,5,6]
					[7,8,9]
				]

				assert.deepEqual(func.nthCol(1, nums), [2,5,8])