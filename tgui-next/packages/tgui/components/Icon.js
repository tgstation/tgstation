import { classes } from 'react-tools';

export const Icon = props => {
  const { name, size, color, className, style = {} } = props;
  if (size) {
    style['font-size'] = (size * 100) + '%';
  }
  return (
    <i
      className={classes([
        className,
        'fa fa-' + name,
        color && 'color-' + color,
      ])}
      style={style} />
  );
};
