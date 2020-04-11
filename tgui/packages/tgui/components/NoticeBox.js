import { classes, pureComponentHooks } from 'common/react';
import { Box } from './Box';

export const NoticeBox = props => {
  const {
    className,
    color,
    backgroundColor,
    ...rest
  } = props;
  return (
    <Box
      className={classes([
        'NoticeBox',
        className,
      ])}
      backgroundColor={backgroundColor || color}
      {...rest} />
  );
};

NoticeBox.defaultHooks = pureComponentHooks;
