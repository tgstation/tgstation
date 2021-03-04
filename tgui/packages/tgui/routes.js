/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { selectBackend } from './backend';
import { selectDebug } from './debug/selectors';
import { Window } from './layouts';

const requireInterface = require.context('./interfaces', false, /\.js$/);

const routingError = (type, name) => () => {
  return (
    <Window>
      <Window.Content scrollable>
        {type === 'notFound' && (
          <div>Interface <b>{name}</b> was not found.</div>
        )}
        {type === 'missingExport' && (
          <div>Interface <b>{name}</b> is missing an export.</div>
        )}
      </Window.Content>
    </Window>
  );
};

const SuspendedWindow = () => {
  return (
    <Window>
      <Window.Content scrollable />
    </Window>
  );
};

export const getRoutedComponent = store => {
  const state = store.getState();
  const { suspended, config } = selectBackend(state);
  if (suspended) {
    return SuspendedWindow;
  }
  if (process.env.NODE_ENV !== 'production') {
    const debug = selectDebug(state);
    // Show a kitchen sink
    if (debug.kitchenSink) {
      return require('./debug').KitchenSink;
    }
  }
  const name = config?.interface;
  let esModule;
  try {
    esModule = requireInterface(`./${name}.js`);
  }
  catch (err) {
    if (err.code === 'MODULE_NOT_FOUND') {
      return routingError('notFound', name);
    }
    throw err;
  }
  const Component = esModule[name];
  if (!Component) {
    return routingError('missingExport', name);
  }
  return Component;
};
