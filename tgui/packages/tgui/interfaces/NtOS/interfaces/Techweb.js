import { AppTechweb } from '../../Techweb';
import { useBackend } from 'tgui/backend';
import { createLogger } from 'tgui/logging';

const logger = createLogger('backend');

export const NtosTechweb = (props, context) => {
  const { config, data, act } = useBackend(context);
  logger.log(config.AppTechweb);
  return (
    <AppTechweb />
  );
};
