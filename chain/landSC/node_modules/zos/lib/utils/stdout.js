'use strict';

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = log;
exports.silent = silent;
const state = {
  silent: false
};

function log() {
  if (!state.silent && process.env.NODE_ENV !== 'test') {
    console.log(...arguments);
  }
}

function silent(value) {
  state.silent = value;
}