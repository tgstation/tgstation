import { classes, pureComponentHooks } from 'common/react';
import { Box, unit } from './Box';

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
        ])}
        content={label + ':'} />
      <Box
        as="td"
        color={color}
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
  const { size = 1 } = props;
  return (
    <tr className="LabeledList__row">
      <td style={{
        'padding-bottom': unit(size),
      }} />
    </tr>
  );
};

LabeledListDivider.defaultHooks = pureComponentHooks;

LabeledList.Item = LabeledListItem;
LabeledList.Divider = LabeledListDivider;
