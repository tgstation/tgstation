import { decodeHtmlEntities } from 'string-tools';
import { TitleBar, Box } from './components';
import { AirAlarm } from './interfaces/AirAlarm';
import { createLogger } from './logging';

const logger = createLogger();

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
        status={config.status} />
      <Box className="Layout__content">
        <Box m={2}>
          <Component state={state} />
        </Box>
      </Box>
    </Fragment>
  );
};
