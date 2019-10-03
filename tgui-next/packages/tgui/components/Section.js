import { classes } from 'common/react';

export const Section = props => {
  const { title, level = 1, buttons, children } = props;
  const hasTitle = !!(title || buttons);
  return (
    <div
      className={classes([
        'Section',
        'Section--level--' + level,
      ])}>
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
      <div className="Section__content">
        {children}
      </div>
    </div>
  );
};
