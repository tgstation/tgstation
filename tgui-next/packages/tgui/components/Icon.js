import { classes } from 'common/react';
import { Box } from './Box';

export const Icon = props => {
  const { name, size, className, style = {}, ...rest } = props;
  if (size) {
    style['font-size'] = (size * 100) + '%';
  }
  return (
    <Box
      as="i"
      className={classes([
        className,
        'fa fa-' + name,
      ])}
      style={style}
      {...rest} />
  );
};
