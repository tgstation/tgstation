import { classes } from "react-tools";

export const LabeledList = props => {
  const { children } = props;
  return (
    <div className="LabeledList">
      {children}
    </div>
  );
};

export const LabeledListItem = props => {
  const { label, color, content, children } = props;
  return (
    <div className="LabeledList__row">
      <div className="LabeledList__label">
        {label}:
      </div>
      <div
        className={classes([
          'LabeledList__content',
          color && 'color-' + color,
        ])}>
        {content}
        {children}
      </div>
    </div>
  );
};

LabeledList.Item = LabeledListItem;
