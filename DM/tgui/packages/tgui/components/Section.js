/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { classes, isFalsy, pureComponentHooks } from 'common/react';
import { Box } from './Box';

export const Section = props => {
  const {
    className,
    title,
    level = 1,
    buttons,
    content,
    children,
    ...rest
  } = props;
  const hasTitle = !isFalsy(title) || !isFalsy(buttons);
  const hasContent = !isFalsy(content) || !isFalsy(children);
  return (
    <Box
      className={classes([
        'Section',
        'Section--level--' + level,
        className,
      ])}
      {...rest}>
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
      {hasContent && (
        <div className="Section__content">
          {content}
          {children}
        </div>
      )}
    </Box>
  );
};

Section.defaultHooks = pureComponentHooks;
