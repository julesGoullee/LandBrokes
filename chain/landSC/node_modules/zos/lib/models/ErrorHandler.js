'use strict';

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _zosLib = require('zos-lib');

const log = new _zosLib.Logger('Error');
const GENERIC_ERROR_MESSAGE = 'There was an undefined error. Please execute the same command again in verbose mode if necessary.';

class ErrorHandler {
  constructor(error, { verbose }) {
    this.error = error;
    this.verbose = verbose;
  }

  call() {
    if (!this.verbose) {
      const errorMessage = this.error.message || GENERIC_ERROR_MESSAGE;
      log.error(errorMessage);
    } else log.error(this.error.stack);
    process.exit(1);
  }
}
exports.default = ErrorHandler;