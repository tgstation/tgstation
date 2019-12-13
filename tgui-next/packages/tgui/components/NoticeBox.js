import { classes, pureComponentHooks } from 'common/react';
import { Box } from './Box';

export const NoticeBox = props => {
  const { className, ...rest } = props;
  return (
    <Box
      className={classes([
        'NoticeBox',
        className,
      ])}
      {...rest} />
  );
};

NoticeBox.defaultHooks = pureComponentHooks;
