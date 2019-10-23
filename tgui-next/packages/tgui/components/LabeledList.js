import { classes, pureComponentHooks } from 'common/react';
import { unit } from './Box';

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
    labelColor,
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
      <td
        className={classes(['LabeledList__cell',
          'LabeledList__label',
          'color-' + (labelColor ? labelColor : 'label')])}>
        {label}:
      </td>
      <td
        className={classes([
          'LabeledList__cell',
          'LabeledList__content',
          color && 'color-' + color,
        ])}
        colSpan={buttons ? undefined : 2}>
        {content}
        {children}
      </td>
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
