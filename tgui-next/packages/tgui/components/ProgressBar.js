import { classes, pureComponentHooks } from 'common/react';
import { clamp, toFixed } from 'common/math';

export const ProgressBar = props => {
  const { value, content, color, children } = props;
  const hasContent = !!(content || children);
  return (
    <div
      className={classes([
        'ProgressBar',
        color && 'ProgressBar--color--' + color,
      ])}>
      <div
        className="ProgressBar__fill"
        style={{
          'width': (clamp(value, 0, 1) * 100) + '%',
        }} />
      <div className="ProgressBar__content">
        {value && !hasContent && toFixed(value * 100) + '%'}
        {content}
        {children}
      </div>
    </div>
  );
};

ProgressBar.defaultHooks = pureComponentHooks;
