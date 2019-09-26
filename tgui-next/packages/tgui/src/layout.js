import { decodeHtmlEntities } from 'string-tools';
import { TitleBar, Box } from './components';
import { AirAlarm } from './interfaces/AirAlarm';
import { createLogger } from './logging';

const logger = createLogger();

const routedComponents = {
  airalarm: AirAlarm,
};

export const Layout = props => {
  const { state } = props;
  const { config } = state;
  const Component = routedComponents[config.interface];
  if (!Component) {
    return `Component for '${config.interface}' was not found.`
  }
  return (
    <Fragment>
      <TitleBar
        title={decodeHtmlEntities(config.title)}
        status={config.status} />
      <Box m={1} mt={6}>
        <Component state={state} />
      </Box>
    </Fragment>
  );
};
