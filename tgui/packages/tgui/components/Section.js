/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { canRender, classes, pureComponentHooks } from 'common/react';
import { computeBoxClassName, computeBoxProps } from './Box';

export const Section = props => {
  const {
    className,
    title,
    level = 1,
    buttons,
    fill,
    fitted,
    children,
    ...rest
  } = props;
  const hasTitle = canRender(title) || canRender(buttons);
  const hasContent = canRender(children);
  return (
    <div
      className={classes([
        'Section',
        'Section--level--' + level,
        fill && 'Section--fill',
        fitted && 'Section--fitted',
        className,
        ...computeBoxClassName(rest),
      ])}
      {...computeBoxProps(rest)}>
      {hasTitle && (
        <div className="Section__title">
          <span className="Section__titleText">
            {title}
          </span>
          <div className="Section__buttons">
            {buttons}
          </div>
        </div>
      )}
      {fitted && children
        || hasContent && (
          <div className="Section__content">
            {children}
          </div>
        )}
    </div>
  );
};

Section.defaultHooks = pureComponentHooks;
