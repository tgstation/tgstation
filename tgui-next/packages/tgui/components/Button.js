import { classes, pureComponentHooks } from 'common/react';
import { Box } from './Box';
import { Icon } from './Icon';

export const BUTTON_ACTIVATION_KEYCODES = [
  13, // Enter
  32, // Space
];

export const Button = props => {
  const {
    className,
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
  // NOTE: Lowercase "onclick" and unselectable is used for
  // compatibility with IE8. Do not change it!
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
        className,
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
      onKeyPress={e => {
        const keyCode = window.event ? e.which : e.keyCode;
        if (BUTTON_ACTIVATION_KEYCODES.includes(keyCode)) {
          e.preventDefault();
          onClick(e);
        }
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

Button.defaultHooks = pureComponentHooks;
