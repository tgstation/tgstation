import { classes } from 'common/react';

export const ProgressBar = props => {
  const { value, content, color, children } = props;
  const hasContent = !!(content || children);
  return (
    <div className="ProgressBar">
      <div
        className={classes([
          'ProgressBar__fill',
          color && 'ProgressBar--color--' + color,
        ])}
        style={{
          'width': (value * 100) + '%',
        }} />
      <div className="ProgressBar__content">
        {value && !hasContent && Math.round(value * 100) + '%'}
        {content}
        {children}
      </div>
    </div>
  );
};
