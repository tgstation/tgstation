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
  const { className, title, status, fancy, onDragStart, onClose } = props;
  return (
    <div className={classes('TitleBar', className)}>
      <Icon
        className={classes([
          'TitleBar__statusIcon',
          statusToClassName(status),
        ])}
        name="eye"
        size={2} />
      <div className="TitleBar__title">
        {title}
      </div>
      <div className="TitleBar__dragZone"
        onMousedown={e => fancy && onDragStart(e)} />
      {fancy && (
        <div className="TitleBar__close TitleBar__clickable"
          onClick={onClose} />
      )}
    </div>
  );
};
