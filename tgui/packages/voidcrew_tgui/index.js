/**
 * code from raffclar
 * taken from https://github.com/fulpstation/fulpstation/pull/612
 */

const requireModularInterface = require.context('./interfaces');
const requireTgInterface = require.context('../tgui/interfaces');

const getComponent = (interfacePath, requireInterface) => {
  let esModule = null;

  try {
    esModule = requireInterface(interfacePath);
  } catch (err) {
    if (err.code !== 'MODULE_NOT_FOUND') {
      throw err;
    }
  }

  return esModule;
};

/**
 * This places precedence on Fulp's interfaces over the default ones
 */
export const loadInterface = (interfacePath) => {
  let esModule = getComponent(interfacePath, requireModularInterface);

  if (esModule) {
    return esModule;
  }

  return getComponent(interfacePath, requireTgInterface);
};
