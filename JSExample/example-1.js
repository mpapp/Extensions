console.log(exports)

exports.process = function(input, outputHandler) {
    console.log("Input to procedure 1: " + input);
    
    setTimeout(function() {
        outputHandler("foo");
    });
};

console.log(exports.process)