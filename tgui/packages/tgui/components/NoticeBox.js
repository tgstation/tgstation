import { classes, pureComponentHooks } from 'common/react';
import { Box } from './Box';

export const NoticeBox = props => {
  const {
    className,
    color,
    info,
    warning,
    success,
    danger,
    ...rest
  } = props;
  return (
    <Box
      className={classes([
        'NoticeBox',
        color && 'NoticeBox--color--' + color,
        info && 'NoticeBox--type--info',
        success && 'NoticeBox--type--success',
        danger && 'NoticeBox--type--danger',
        className,
      ])}
      {...rest} />
  );
};

NoticeBox.defaultHooks = pureComponentHooks;
