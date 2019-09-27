import { classes } from 'react-tools';
import { UI_DISABLED, UI_INTERACTIVE, UI_UPDATE } from '../constants';
import { Icon } from './Icon';

const statusToClassName = status => {
  switch (status) {
    case UI_INTERACTIVE:
      return 'color-good';
    case UI_UPDATE:
      return 'color-average';
    case UI_DISABLED:
    default:
      return 'color-bad';
  }
};

export const TitleBar = props => {
  const { title, status, onDrag } = props;
  return (
    <div className="TitleBar" onMousedown={onDrag}>
      <Icon
        className={classes([
          'TitleBar__statusIcon',
          statusToClassName(status),
        ])}
        name="eye"
        size={2} />
      <span className="TitleBar__title">
        {title}
      </span>
    </div>
  );
};
