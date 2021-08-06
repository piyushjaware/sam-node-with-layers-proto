'use strict';

let test = require('unit.js'),
    sinon = require('sinon'),
    lambda = require('../../lambdas/greeter/app'),
    axios = require('axios'),
    event = {},
    context = { awsRequestId: 'a123' };

let assert = test.assert;
let axiosStub;

describe('Greeter Lambda Function', function () {

    it('should return a greeting message', async function () {
        axiosStub = stubAxios(200, {
            "args": {
                "name": "Kuhu"
            },
            "headers": {},
            "url": "https://postman-echo.com/get?name=kuhu"
        });
        let res = await lambda.handler(event, context);
        const axiosCallArgs = axiosStub.getCalls()[0].args;
        assert.equal(axiosCallArgs[0].includes("https://httpbin.org/get?name="), true);
        assert.equal(res.statusCode, 200);
        assert.equal(JSON.parse(res.body).message, 'Hi from Kuhu');
    });

    afterEach(function () {
        axiosStub ? axiosStub.restore() : '';
    });

});


function stubAxios(status, data) {
    return sinon.stub(axios, 'get')
        .returns(Promise.resolve({ status, data }));
}
