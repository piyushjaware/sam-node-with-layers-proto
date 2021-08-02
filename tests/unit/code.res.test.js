'use strict';

let test = require('unit.js'),
    res = require('../../layers/code/nodejs/node_modules/res');


describe("Code layer's res.response", function () {

    it('should return a json lambda response', async function () {
        const result = res.response(200, sampleBody());

        test.object(result).hasProperty('statusCode');
        test.object(result).hasProperty('headers');
        test.object(result).hasProperty('body');

        test.assert.deepEqual(result.headers, { 'Content-Type': 'application/json' });
        test.assert.strictEqual(result.statusCode, 200);
        test.assert.strictEqual(result.body, JSON.stringify(sampleBody()));
    });

});

function sampleBody() {
    return {
        args: { name: "Kuhu" },
        headers: {},
        url: "https://postman-echo.com/get?name=kuhu"
    };
}

