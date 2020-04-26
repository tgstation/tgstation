import { Window } from './layouts';

const requireInterface = require.context('./interfaces', false, /\.js$/);

const routingError = (type, name) => () => {
  return (
    <Window resizable>
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

export const getRoutedComponent = state => {
  if (process.env.NODE_ENV !== 'production') {
    // Show a kitchen sink
    if (state.showKitchenSink) {
      return require('./interfaces/manually-routed/KitchenSink').KitchenSink;
    }
  }
  const name = state.config?.interface;
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
