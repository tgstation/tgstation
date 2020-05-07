/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { classes } from 'common/react';
import { computeBoxClassName, computeBoxProps } from './Box';
import { Button } from './Button';

export const Tabs = props => {
  const {
    className,
    vertical,
    children,
    ...rest
  } = props;
  return (
    <div
      className={classes([
        'Tabs',
        vertical
          ? 'Tabs--vertical'
          : 'Tabs--horizontal',
        className,
        computeBoxClassName(rest),
      ])}
      {...computeBoxProps(rest)}>
      <div className="Tabs__tabBox">
        {children}
      </div>
    </div>
  );
};

const Tab = props => {
  const {
    className,
    selected,
    altSelection,
    ...rest
  } = props;
  return (
    <Button
      className={classes([
        'Tabs__tab',
        selected && 'Tabs__tab--selected',
        altSelection && selected && 'Tabs__tab--altSelection',
        className,
      ])}
      selected={!altSelection && selected}
      color="transparent"
      {...rest} />
  );
};

Tabs.Tab = Tab;
