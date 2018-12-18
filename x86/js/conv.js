var esprima = require('esprima');
var program = 'const answer = 42';
var fs = require('fs');
fs.readFile( 'cpux86-ta-2019.js', "utf8", function (err, data) {
    if (err) {
	throw err; 
    }
    ast = esprima.parse(data);
    j = JSON.stringify(ast, null, 4);
    fs.writeFile('ast-2018.txt', j ,function(err) {
	if(err) {
	    console.log(err);
	} else {
	    console.log("JSON saved");
	}
    }); 
});



