'use strict';

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _zosLib = require('zos-lib');

const StdlibDeployer = {
  async deploy(stdlibName, txParams = {}) {
    const release = await this._createRelease(stdlibName, txParams);
    return release.address();
  },

  async _createRelease(stdlibName, txParams) {
    const contractsList = this._jsonData(stdlibName).contracts;
    const contractsData = Object.keys(contractsList).map(alias => ({ alias, name: contractsList[alias] }));
    return await _zosLib.Release.deployDependency(stdlibName, contractsData, txParams);
  },

  _jsonData(stdlibName) {
    const filename = `node_modules/${stdlibName}/zos.json`;
    return _zosLib.FileSystem.parseJson(filename);
  }
};

exports.default = StdlibDeployer;