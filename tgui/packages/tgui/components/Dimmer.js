/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { classes } from 'common/react';
import { Box } from './Box';

export const Dimmer = props => {
  const { className, children, ...rest } = props;
  return (
    <Box
      className={classes([
        'Dimmer',
        ...className,
      ])}
      {...rest}>
      <div className="Dimmer__inner">
        {children}
      </div>
    </Box>
  );
};
