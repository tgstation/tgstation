import { classes, pureComponentHooks } from 'common/react';
import { Box } from './Box';

export const Icon = props => {
  const { name, size, className, style = {}, ...rest } = props;
  if (size) {
    style['font-size'] = (size * 100) + '%';
  }
  const faRegular = name.endsWith('-o');
  const faName = name.replace(/-o$/, '');
  return (
    <Box
      as="i"
      className={classes([
        className,
        faRegular ? 'far' : 'fas',
        'fa-' + faName,
      ])}
      style={style}
      {...rest} />
  );
};

Icon.defaultHooks = pureComponentHooks;
