/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { classes } from 'common/react';
import { IS_IE8 } from '../byond';

/**
 * Brings Layout__content DOM element back to focus.
 *
 * Commonly used to keep the content scrollable in IE.
 */
export const refocusLayout = () => {
  // IE8: Focus method is seemingly fucked.
  if (IS_IE8) {
    return;
  }
  const element = document.getElementById('Layout__content');
  if (element) {
    element.focus();
  }
};

export const Layout = props => {
  const {
    className,
    theme = 'nanotrasen',
    children,
  } = props;
  return (
    <div className={'theme-' + theme}>
      <div
        className={classes([
          'Layout',
          className,
        ])}>
        {children}
      </div>
    </div>
  );
};

const LayoutContent = props => {
  const {
    className,
    scrollable,
    children,
  } = props;
  return (
    <div
      id="Layout__content"
      className={classes([
        'Layout__content',
        scrollable && 'Layout__content--scrollable',
        className,
      ])}>
      {children}
    </div>
  );
};

Layout.Content = LayoutContent;
