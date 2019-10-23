import { classes, pureComponentHooks } from 'common/react';
import { tridentVersion } from '../byond';
import { createLogger } from '../logging';
import { Box } from './Box';
import { Icon } from './Icon';
import { Tooltip } from './Tooltip';
import { refocusLayout } from '../refocus';

const logger = createLogger('Button');

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
    tooltipPosition,
    content,
    children,
    onclick,
    onClick,
    ...rest
  } = props;
  const hasContent = !!(content || children);
  // A warning about the lowercase onclick
  if (onclick) {
    logger.warn("Lowercase 'onclick' is not supported on Button and "
      + "lowercase prop names are discouraged in general. "
      + "Please use a camelCase 'onClick' instead and read: "
      + "https://infernojs.org/docs/guides/event-handling");
  }
  // NOTE: Lowercase "onclick" and unselectable are used internally for
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
      tabIndex={!disabled && '0'}
      unselectable={tridentVersion <= 4}
      onclick={e => {
        if (disabled || !onClick) {
          return;
        }
        refocusLayout();
        onClick(e);
      }}
      onKeyPress={e => {
        const keyCode = window.event ? e.which : e.keyCode;
        if (!BUTTON_ACTIVATION_KEYCODES.includes(keyCode)) {
          return;
        }
        if (disabled || !onClick) {
          return;
        }
        e.preventDefault();
        refocusLayout();
        onClick(e);
      }}
      {...rest}>
      {icon && (
        <Icon name={icon} />
      )}
      {content}
      {children}
      {tooltip && (
        <Tooltip
          content={tooltip}
          position={tooltipPosition} />
      )}
    </Box>
  );
};

Button.defaultHooks = pureComponentHooks;
