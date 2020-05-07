/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { classes, pureComponentHooks } from 'common/react';
import { Box, unit } from './Box';
import { Divider } from './Divider';

export const LabeledList = props => {
  const { children } = props;
  return (
    <table className="LabeledList">
      {children}
    </table>
  );
};

LabeledList.defaultHooks = pureComponentHooks;

export const LabeledListItem = props => {
  const {
    className,
    label,
    labelColor = 'label',
    color,
    textAlign,
    buttons,
    content,
    children,
  } = props;
  return (
    <tr
      className={classes([
        'LabeledList__row',
        className,
      ])}>
      <Box
        as="td"
        color={labelColor}
        className={classes([
          'LabeledList__cell',
          'LabeledList__label',
        ])}>
        {label ? label + ':' : null}
      </Box>
      <Box
        as="td"
        color={color}
        textAlign={textAlign}
        className={classes([
          'LabeledList__cell',
          'LabeledList__content',
        ])}
        colSpan={buttons ? undefined : 2}>
        {content}
        {children}
      </Box>
      {buttons && (
        <td className="LabeledList__cell LabeledList__buttons">
          {buttons}
        </td>
      )}
    </tr>
  );
};

LabeledListItem.defaultHooks = pureComponentHooks;

export const LabeledListDivider = props => {
  const padding = props.size
    ? unit(Math.max(0, props.size - 1))
    : 0;
  return (
    <tr className="LabeledList__row">
      <td
        colSpan={3}
        style={{
          'padding-top': padding,
          'padding-bottom': padding,
        }}>
        <Divider />
      </td>
    </tr>
  );
};

LabeledListDivider.defaultHooks = pureComponentHooks;

LabeledList.Item = LabeledListItem;
LabeledList.Divider = LabeledListDivider;
