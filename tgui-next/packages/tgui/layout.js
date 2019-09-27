import { decodeHtmlEntities } from 'string-tools';
import { Box, TitleBar } from './components';
import { dragStartHandler } from './drag';
import { AirAlarm } from './interfaces/AirAlarm';
import { winset, runCommand } from 'byond';
import { createLogger } from './logging';

const logger = createLogger('Layout');

const routedComponents = {
  airalarm: AirAlarm,
};

export const getRoutedComponent = name => routedComponents[name];

export const Layout = props => {
  const { state } = props;
  const { config } = state;
  const Component = getRoutedComponent(config.interface);
  if (!Component) {
    return `Component for '${config.interface}' was not found.`
  }
  return (
    <Fragment>
      <TitleBar
        className="Layout__titleBar"
        title={decodeHtmlEntities(config.title)}
        status={config.status}
        fancy={config.fancy}
        onDragStart={dragStartHandler}
        onClose={() => {
          logger.log('pressed close');
          winset(config.window, 'is-visible', false);
          runCommand(`uiclose ${config.ref}`);
        }} />
      <Box className="Layout__content">
        <Component state={state} />
      </Box>
    </Fragment>
  );
};
