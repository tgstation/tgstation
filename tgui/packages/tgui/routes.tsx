/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { useBackend } from './backend';
import { useDebug } from './debug';
import { LoadingScreen } from './interfaces/common/LoadingScreen';
import { Window } from './layouts';

const requireInterface = require.context('./interfaces');

const routingError =
  (type: 'notFound' | 'missingExport', name: string) => () => {
    return (
      <Window>
        <Window.Content scrollable>
          {type === 'notFound' && (
            <div>
              Interface <b>{name}</b> was not found.
            </div>
          )}
          {type === 'missingExport' && (
            <div>
              Interface <b>{name}</b> is missing an export.
            </div>
          )}
        </Window.Content>
      </Window>
    );
  };

// Displays an empty Window with scrollable content
function SuspendedWindow() {
  return (
    <Window>
      <Window.Content scrollable />
    </Window>
  );
}

// Displays a loading screen with a spinning icon
function RefreshingWindow() {
  return (
    <Window title="Loading">
      <Window.Content>
        <LoadingScreen />
      </Window.Content>
    </Window>
  );
}

// Get the component for the current route
export function getRoutedComponent() {
  const { suspended, config } = useBackend();
  const { kitchenSink = false } = useDebug();

  if (suspended) {
    return SuspendedWindow;
  }
  if (config?.refreshing) {
    return RefreshingWindow;
  }

  if (process.env.NODE_ENV !== 'production') {
    // Show a kitchen sink
    if (kitchenSink) {
      return require('./debug').KitchenSink;
    }
  }

  const name = config?.interface?.name;
  const interfacePathBuilders = [
    (name: string) => `./${name}.tsx`,
    (name: string) => `./${name}.jsx`,
    (name: string) => `./${name}/index.tsx`,
    (name: string) => `./${name}/index.jsx`,
  ];

  let esModule;
  while (!esModule && interfacePathBuilders.length > 0) {
    const interfacePathBuilder = interfacePathBuilders.shift()!;
    const interfacePath = interfacePathBuilder(name);
    try {
      esModule = requireInterface(interfacePath);
    } catch (err) {
      if (err.code !== 'MODULE_NOT_FOUND') {
        throw err;
      }
    }
  }

  if (!esModule) {
    return routingError('notFound', name);
  }

  const Component = esModule[name];
  if (!Component) {
    return routingError('missingExport', name);
  }

  return Component;
}
