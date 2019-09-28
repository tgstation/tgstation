import { classes } from 'react-tools';

export const LabeledList = props => {
  const { children } = props;
  return (
    <table className="LabeledList">
      {children}
    </table>
  );
};

export const LabeledListItem = props => {
  const { label, color, buttons, content, children } = props;
  return (
    <tr className="LabeledList__row">
      <td className="LabeledList__cell LabeledList__label">
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

LabeledList.Item = LabeledListItem;
