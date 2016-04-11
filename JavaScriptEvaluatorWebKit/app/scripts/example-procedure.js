/**
 * scripts/app.js
 *
 * This is a sample CommonJS module.
 * Take a look at http://browserify.org/ for more info
 */

'use strict';

function Procedure() {
  console.log('procedure initialized');
}

module.exports = App;

window.setEvaluatorCompletionHandler

Procedure.prototype.input = function () {
    console.log('input');
};

Procedure.prototype.output = function () {
    console.log('output');
};

Procedure.prototype.error = function (code, description) {
    console.error("ERROR " + code + ": " + description)
};
