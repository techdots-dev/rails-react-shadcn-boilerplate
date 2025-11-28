const { createHash } = require('node:crypto');

if (typeof globalThis.crypto !== 'object' || globalThis.crypto === null) {
  globalThis.crypto = {};
}

if (typeof globalThis.crypto.hash !== 'function') {
  globalThis.crypto.hash = (algorithm, data, encoding) => {
    return createHash(algorithm).update(data).digest(encoding);
  };
}
