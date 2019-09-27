import { Icon } from './Icon';
import { classes } from 'react-tools';

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
  return (
    <div
      className={classes([
        'Button',
        fluid && 'Button--fluid',
        disabled && 'Button--disabled',
        selected && 'Button--selected',
        (color && typeof color === 'string')
          ? 'Button--color--' + color
          : 'Button--color--normal',
      ])}
      tabindex={!disabled && '0'}
      data-tooltip={tooltip}
      title={title}
      clickable={disabled}
      onClick={e => {
        if (disabled) {
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
