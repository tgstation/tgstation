import { classes } from 'react-tools';
import { Icon } from './Icon';

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
  } = props;
  const hasContent = !!(content || children);
  return (
    <div
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
      clickable={disabled}
      onClick={e => {
        if (disabled || !onClick) {
          return;
        }
        onClick(e);
      }}>
      {icon && (
        <Icon name={icon} />
      )}
      {content}
      {children}
    </div>
  );
};
