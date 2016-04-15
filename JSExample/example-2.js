exports.process = function(input, outputHandler) {
    console.log("Input to procedure 2: " + input);

    setTimeout(function() {
        outputHandler(input + "bar");
    });
};