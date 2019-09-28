import { decodeHtmlEntities } from 'string-tools';
import { Box, TitleBar } from './components';
import { dragStartHandler } from './drag';
import { AirAlarm } from './interfaces/AirAlarm';
import { winset, runCommand } from 'byond';
import { createLogger } from './logging';
import { UI_INTERACTIVE } from './constants';
import { classes } from 'react-tools';
import { Toast } from './components/Toast';

const logger = createLogger('Layout');

const ROUTES = {
  airalarm: {
    scrollable: true,
    component: () => AirAlarm,
  },
};

export const getRoute = name => ROUTES[name];

export const Layout = props => {
  const { state } = props;
  const { config } = state;
  const route = getRoute(config.interface);
  if (!route) {
    return `Component for '${config.interface}' was not found.`
  }
  const Component = route.component();
  const { scrollable } = route;
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
      <Box
        className={classes([
          'Layout__content',
          scrollable && 'Layout__content--scrollable',
        ])}>
        <Component state={state} />
      </Box>
      {config.status !== UI_INTERACTIVE && (
        <Box className="Layout__dimmer" />
      )}
      {state.toastText && (
        <Toast content={state.toastText} />
      )}
    </Fragment>
  );
};
