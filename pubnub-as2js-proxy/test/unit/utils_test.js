"use strict";

describe('utils', function () {
    describe('objectValues', function () {
        var obj = {
            '0': 'zeroValue',
            '1': 'firstValue',
            '2': 'secondValue',
            'another': 'charValue'
        };

        var expectedResult = ['zeroValue', 'firstValue', 'secondValue', 'charValue'];

        expect(objectValues(obj)).to.eql(expectedResult);
    });
});