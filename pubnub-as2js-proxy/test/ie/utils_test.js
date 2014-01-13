var ar = [2, 5, 7],
    obj = {0: 2, 1: 5},
    obj2 = {0: 2, 4: 8, to: 10},
    str = 'awesome string',
    int = 5;

//test('#objectValues', function () {
//    deepEqual(objectValues(obj), [2, 5], 'returned array has same values as object')
//    deepEqual(objectValues(obj2), [2, 8, 10], 'returned array has same values as object')
//});
//
//test('#isArray', function () {
//    ok(isArray(ar) === true, 'array is array');
//    ok(isArray(obj) === false, 'object is not array');
//    ok(isArray(str) === false, 'string is not array');
//    ok(isArray(int) === false, 'integer is not array');
//});
//
//test('#isString', function () {
//    ok(isString(ar) === false, 'array is not string');
//    ok(isString(obj) === false, 'object is not string');
//    ok(isString(str) === true, 'string is string');
//    ok(isString(int) === false, 'integer is not string');
//});