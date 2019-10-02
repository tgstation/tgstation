import { classes } from 'react-tools';
import { Icon } from './Icon';
import { Box } from './Box';

export const Button = props => {
  const {
    fluid,
    icon,
    color,
    disabled,
    selected,
    tooltip,
    title,
    content,
    children,
    onClick,
    ...rest
  } = props;
  const hasContent = !!(content || children);
  return (
    <Box as="span"
      className={classes([
        'Button',
        fluid && 'Button--fluid',
        disabled && 'Button--disabled',
        selected && 'Button--selected',
        hasContent && 'Button--hasContent',
        (color && typeof color === 'string')
          ? 'Button--color--' + color
          : 'Button--color--normal',
      ])}
      tabindex={!disabled && '0'}
      data-tooltip={tooltip}
      title={title}
      unselectable={true}
      onclick={e => {
        if (disabled || !onClick) {
          return;
        }
        onClick(e);
      }}
      {...rest}>
      {icon && (
        <Icon name={icon} />
      )}
      {content}
      {children}
    </Box>
  );
};
