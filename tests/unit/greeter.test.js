'use strict';

let test = require('unit.js'),
    sinon = require('sinon'),
    lambda = require('../../lambdas/greeter/app'),
    axios = require('axios'),
    event = {},
    context = { awsRequestId: 'a123' };

let assert = test.assert;
let axiosSpy;

describe('Greeter Lambda Function', function () {

    it('should return a greeting message', async function () {
        axiosSpy = stubAxios(200, {
            "args": {
                "name": "Kuhu"
            },
            "headers": {},
            "url": "https://postman-echo.com/get?name=kuhu"
        });
        let res = await lambda.handler(event, context);
        assert.equal(res.statusCode, 200);
        assert.equal(JSON.parse(res.body).message, 'Hi from Kuhu');
    });

    afterEach(function () {
        axiosSpy ? axiosSpy.restore() : '';
    });

});


function stubAxios(status, data) {
    return sinon.stub(axios, 'get')
        .returns(Promise.resolve({ status, data }));
}
