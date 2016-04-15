# Extensions
Extensions.framework allows creation of plugins which involve execution of a script in an interpreted / JIT compiled language of some kind.

# How to build

In order to build this framework, you will need:

- carthage to fetch the Freddy JSON parsing library that’s used internally (you can get carthage from homebrew)
  - To build / update Carthage based dependencies: `carthage update --use-submodules --platform mac --use-ssh` in the root of the repository.

- if you want to rebuild the JS resources inside JSExample.extension, you need `node` (a recent version, for instance 5.7.0 most likely needed) + `bower` (you can get it from npm) and gulp (you can get it from npm too)
  - to rebuild JSExample.extension resources, execute: `npm install && bower install && gulp dist` in the folder `JSExamples`
