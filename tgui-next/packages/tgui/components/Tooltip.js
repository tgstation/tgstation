import { classes } from 'common/react';

export const Tooltip = props => {
  const {
    content,
    position = 'bottom',
  } = props;
  return (
    <div
      className={classes([
        'Tooltip',
        position && 'Tooltip--' + position,
      ])}
      data-tooltip={content} />
  );
};
