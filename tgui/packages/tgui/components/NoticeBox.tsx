/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { classes, pureComponentHooks } from 'common/react';
import { Box, BoxProps } from './Box';

type Props = Partial<{
  className: string;
  color: string;
  info: boolean;
  warning: boolean;
  success: boolean;
  danger: boolean;
}> &
  BoxProps;

export const NoticeBox = (props: Props) => {
  const { className, color, info, warning, success, danger, ...rest } = props;

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
      {...rest}
    />
  );
};

NoticeBox.defaultHooks = pureComponentHooks;
