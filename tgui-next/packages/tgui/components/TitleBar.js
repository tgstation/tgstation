import { classes, pureComponentHooks } from 'common/react';
import { toTitleCase } from 'common/string';
import { tridentVersion } from '../byond';
import { UI_DISABLED, UI_INTERACTIVE, UI_UPDATE } from '../constants';
import { Icon } from './Icon';

const statusToColor = status => {
  switch (status) {
    case UI_INTERACTIVE:
      return 'good';
    case UI_UPDATE:
      return 'average';
    case UI_DISABLED:
    default:
      return 'bad';
  }
};

export const TitleBar = props => {
  const { className, title, status, fancy, onDragStart, onClose } = props;
  return (
    <div
      className={classes([
        'TitleBar',
        className,
      ])}>
      <Icon
        className="TitleBar__statusIcon"
        color={statusToColor(status)}
        name="eye" />
      <div className="TitleBar__title">
        {title === title.toLowerCase() ? toTitleCase(title) : title}
      </div>
      <div
        className="TitleBar__dragZone"
        onMousedown={e => fancy && onDragStart(e)} />
      {!!fancy && (
        <div
          className="TitleBar__close TitleBar__clickable"
          // IE8: Synthetic onClick event doesn't work on IE8.
          // IE8: Use a plain character instead of a unicode symbol.
          // eslint-disable-next-line react/no-unknown-property
          onclick={onClose}>
          {tridentVersion <= 4 ? 'x' : '×'}
        </div>
      )}
    </div>
  );
};

TitleBar.defaultHooks = pureComponentHooks;
