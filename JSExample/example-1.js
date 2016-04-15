console.log("Procedure 1")
console.log("Input 1: " + window.input)
console.log("Output 1: " + window.output)

try {
    console.log(window.output("foo"));
} catch (e) {
    console.error(e);
}