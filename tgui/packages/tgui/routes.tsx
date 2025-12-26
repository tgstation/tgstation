/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { useAtomValue } from 'jotai';
import { KitchenSink } from './debug/KitchenSink';
import { backendStateAtom } from './events/store';
import { LoadingScreen } from './interfaces/common/LoadingScreen';
import { Window } from './layouts';

const requireInterface = require.context('./interfaces');

type RoutingErrorProps = {
  type: 'notFound' | 'missingExport' | 'unknown';
  name: string;
};

function RoutingErrorWindow(props: RoutingErrorProps) {
  const { type, name } = props;

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
        {type === 'unknown' && <div>An unknown error has occurred.</div>}
      </Window.Content>
    </Window>
  );
}

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
export function getRoutedComponent(name: string) {
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
        throw new Error('notFound');
      }
    }
  }

  if (!esModule) {
    throw new Error('notFound');
  }

  const Component = esModule[name];
  if (!Component) {
    throw new Error('missingExport');
  }

  return Component;
}

export function RoutedComponent() {
  const { suspended, config, debug } = useAtomValue(backendStateAtom);

  if (suspended) {
    return <SuspendedWindow />;
  }
  if (config.refreshing) {
    return <RefreshingWindow />;
  }

  if (process.env.NODE_ENV !== 'production') {
    if (debug.kitchenSink) {
      return <KitchenSink />;
    }
  }

  const name = config?.interface?.name;
  if (!name) {
    return <RoutingErrorWindow type="notFound" name="(undefined)" />;
  }

  try {
    const Component = getRoutedComponent(name);

    return <Component />;
  } catch (err) {
    switch (err.message) {
      case 'notFound':
        return <RoutingErrorWindow type="notFound" name={name} />;
      case 'missingExport':
        return <RoutingErrorWindow type="missingExport" name={name} />;
      default:
        return <RoutingErrorWindow type="unknown" name={name} />;
    }
  }
}
