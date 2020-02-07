var request = require('request');

h2z = str => {
    return str.replace(/[Ａ-Ｚａ-ｚ０-９]/g, function(s) {
        return String.fromCharCode(s.charCodeAt(0) - 0xFEE0);
    });
}

request({
    url: 'https://maker.ifttt.com/trigger/twi/with/key/dm5nT4nshQ1KxZwFv4A9EQ',
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({value1:
`${process.argv[2]}
Title:${process.env.NAME}:${process.env.PROGRAMID}
Channel:${process.env.CHANNELNAME?h2z(process.env.CHANNELNAME):process.env.CHANNELNAME}:${process.env.CHANNELID}
Duration:${process.env.DURATION/1000/60}m
Description:${process.env.DESCRIPTION}
@5yuim`})
}, (error, response, body) => {
    if (!error && response.statusCode == 200) {
        console.log(body);
    } else {
        console.log(response.statusCode);
    }
});