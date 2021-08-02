const axios = require('axios');// get from lib layer
const res = require('res'); // get from code layer
const random_name = require('node-random-name'); // directly get from lambda dependencies

exports.handler = async (event, context) => {
    try {
        const response = await axios.get(`https://httpbin.org/get?name=${random_name()}`);
        return res.response(response.status, { message: `Hi from ${response.data.args.name}` })
    } catch (err) {
        throw new Error(err.message);
    }
};