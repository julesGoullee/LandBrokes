"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _Stdlib = require("./Stdlib");

var _Stdlib2 = _interopRequireDefault(_Stdlib);

var _npmProgrammatic = require("npm-programmatic");

var _npmProgrammatic2 = _interopRequireDefault(_npmProgrammatic);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

const StdlibInstaller = {
  async call(stdlibNameAndVersion) {
    const params = { save: true, cwd: process.cwd() };
    await _npmProgrammatic2.default.install([stdlibNameAndVersion], params);
    return new _Stdlib2.default(stdlibNameAndVersion);
  }
};

exports.default = StdlibInstaller;