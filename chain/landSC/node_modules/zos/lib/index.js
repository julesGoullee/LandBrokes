'use strict';

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.NetworkLibController = exports.NetworkAppController = exports.LocalLibController = exports.LocalAppController = exports.ControllerFor = exports.TestApp = exports.version = undefined;

var _TestApp = require('./models/TestApp');

var _TestApp2 = _interopRequireDefault(_TestApp);

var _ControllerFor = require('./models/local/ControllerFor');

var _ControllerFor2 = _interopRequireDefault(_ControllerFor);

var _LocalAppController = require('./models/local/LocalAppController');

var _LocalAppController2 = _interopRequireDefault(_LocalAppController);

var _LocalLibController = require('./models/local/LocalLibController');

var _LocalLibController2 = _interopRequireDefault(_LocalLibController);

var _NetworkAppController = require('./models/network/NetworkAppController');

var _NetworkAppController2 = _interopRequireDefault(_NetworkAppController);

var _NetworkLibController = require('./models/network/NetworkLibController');

var _NetworkLibController2 = _interopRequireDefault(_NetworkLibController);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

// module information
const version = 'v' + require('../package.json').version;

// model objects
exports.version = version;
exports.TestApp = _TestApp2.default;
exports.ControllerFor = _ControllerFor2.default;
exports.LocalAppController = _LocalAppController2.default;
exports.LocalLibController = _LocalLibController2.default;
exports.NetworkAppController = _NetworkAppController2.default;
exports.NetworkLibController = _NetworkLibController2.default;