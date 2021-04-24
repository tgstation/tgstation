import { AppTechweb } from './Techweb.js';
import { useBackend, useLocalState } from '../backend';
import { createLogger } from '../logging';

const logger = createLogger('backend');

export const NtosTechweb = (props, context) => {
  const { config, data, act } = useBackend(context);
  logger.log(config.AppTechweb);
  return (
    <AppTechweb />
  );
};
