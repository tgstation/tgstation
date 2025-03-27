import { PropsWithChildren } from 'react';
import { Button, Icon } from 'tgui-core/components';
import { UI_DISABLED, UI_INTERACTIVE, UI_UPDATE } from 'tgui-core/constants';
import { BooleanLike, classes } from 'tgui-core/react';
import { toTitleCase } from 'tgui-core/string';

import { globalStore } from '../backend';
import { toggleKitchenSink } from '../debug/actions';

type TitleBarProps = Partial<{
  className: string;
  title: string;
  status: number;
  fancy: BooleanLike;
  canClose: BooleanLike;
  onClose: (e) => void;
  onDragStart: (e) => void;
}> &
  PropsWithChildren;

function statusToColor(status: number): string {
  switch (status) {
    case UI_INTERACTIVE:
      return 'good';
    case UI_UPDATE:
      return 'average';
    case UI_DISABLED:
    default:
      return 'bad';
  }
}

export function TitleBar(props: TitleBarProps) {
  const {
    className,
    title,
    status,
    canClose,
    fancy,
    onDragStart,
    onClose,
    children,
  } = props;
  const dispatch = globalStore.dispatch;

  const finalTitle =
    (typeof title === 'string' &&
      title === title.toLowerCase() &&
      toTitleCase(title)) ||
    title;

  return (
    <div className={classes(['TitleBar', className])}>
      <div
        className="TitleBar__dragZone"
        onMouseDown={(e) => fancy && onDragStart && onDragStart(e)}
      />
      {status === undefined ? (
        <Icon className="TitleBar__statusIcon" name="tools" opacity={0.5} />
      ) : (
        <Icon
          className="TitleBar__statusIcon"
          color={statusToColor(status)}
          name={status === UI_DISABLED ? 'eye-slash' : 'eye'}
        />
      )}
      <div className="TitleBar__title">{finalTitle}</div>
      {!!children && <div className="TitleBar__buttons">{children}</div>}
      {process.env.NODE_ENV !== 'production' && (
        <Button
          className="TitleBar__buttons TitleBar__KitchenSink"
          icon="bug"
          onClick={() => dispatch(toggleKitchenSink())}
        />
      )}
      {Boolean(fancy && canClose) && (
        <div className="TitleBar__close" onClick={onClose}>
          <Icon className="TitleBar__close--icon" name="times" />
        </div>
      )}
    </div>
  );
}
