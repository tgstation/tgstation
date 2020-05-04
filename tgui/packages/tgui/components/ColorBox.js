import { classes, pureComponentHooks } from 'common/react';
import { computeBoxClassName, computeBoxProps } from './Box';

export const ColorBox = props => {
  const {
    content,
    children,
    className,
    color,
    backgroundColor,
    ...rest
  } = props;
  rest.color = content ? null : 'transparent';
  rest.backgroundColor = color || backgroundColor;
  return (
    <div
      className={classes([
        'ColorBox',
        className,
        computeBoxClassName(rest),
      ])}
      {...computeBoxProps(rest)}>
      {content || '.'}
    </div>
  );
};

ColorBox.defaultHooks = pureComponentHooks;
