const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('api', {
  testConnection: (config) => ipcRenderer.invoke('test-connection', config),
  installFonts: (config) => ipcRenderer.invoke('install-fonts', config),
  onInstallLog: (callback) => ipcRenderer.on('install-log', (_, msg) => callback(msg)),
  removeInstallLog: () => ipcRenderer.removeAllListeners('install-log')
});
