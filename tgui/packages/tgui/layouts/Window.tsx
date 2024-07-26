/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { classes } from 'common/react';
import { decodeHtmlEntities, toTitleCase } from 'common/string';
import { PropsWithChildren, ReactNode, useEffect } from 'react';

import { backendSuspendStart, useBackend } from '../backend';
import { globalStore } from '../backend';
import { Icon } from '../components';
import { BoxProps } from '../components/Box';
import { UI_DISABLED, UI_INTERACTIVE, UI_UPDATE } from '../constants';
import { useDebug } from '../debug';
import { toggleKitchenSink } from '../debug/actions';
import {
  dragStartHandler,
  recallWindowGeometry,
  resizeStartHandler,
  setWindowKey,
} from '../drag';
import { createLogger } from '../logging';
import { Layout } from './Layout';

const logger = createLogger('Window');

const DEFAULT_SIZE: [number, number] = [400, 600];

type Props = Partial<{
  buttons: ReactNode;
  canClose: boolean;
  height: number;
  theme: string;
  title: string;
  width: number;
}> &
  PropsWithChildren;

export const Window = (props: Props) => {
  const {
    canClose = true,
    theme,
    title,
    children,
    buttons,
    width,
    height,
  } = props;

  const { config, suspended } = useBackend();
  const { debugLayout = false } = useDebug();

  useEffect(() => {
    if (!suspended) {
      const updateGeometry = () => {
        const options = {
          ...config.window,
          size: DEFAULT_SIZE,
        };

        if (width && height) {
          options.size = [width, height];
        }
        if (config.window?.key) {
          setWindowKey(config.window.key);
        }
        recallWindowGeometry(options);
      };

      Byond.winset(Byond.windowId, {
        'can-close': Boolean(canClose),
      });
      logger.log('mounting');
      updateGeometry();

      return () => {
        logger.log('unmounting');
      };
    }
  }, [width, height]);

  const dispatch = globalStore.dispatch;
  const fancy = config.window?.fancy;

  // Determine when to show dimmer
  const showDimmer =
    config.user &&
    (config.user.observer
      ? config.status < UI_DISABLED
      : config.status < UI_INTERACTIVE);

  return suspended ? null : (
    <Layout className="Window" theme={theme}>
      <TitleBar
        className="Window__titleBar"
        title={title || decodeHtmlEntities(config.title)}
        status={config.status}
        fancy={fancy}
        onDragStart={dragStartHandler}
        onClose={() => {
          logger.log('pressed close');
          dispatch(backendSuspendStart());
        }}
        canClose={canClose}
      >
        {buttons}
      </TitleBar>
      <div className={classes(['Window__rest', debugLayout && 'debug-layout'])}>
        {!suspended && children}
        {showDimmer && <div className="Window__dimmer" />}
      </div>
      {fancy && (
        <>
          <div
            className="Window__resizeHandle__e"
            onMouseDown={resizeStartHandler(1, 0) as any}
          />
          <div
            className="Window__resizeHandle__s"
            onMouseDown={resizeStartHandler(0, 1) as any}
          />
          <div
            className="Window__resizeHandle__se"
            onMouseDown={resizeStartHandler(1, 1) as any}
          />
        </>
      )}
    </Layout>
  );
};

type ContentProps = Partial<{
  className: string;
  fitted: boolean;
  scrollable: boolean;
  vertical: boolean;
}> &
  BoxProps &
  PropsWithChildren;

const WindowContent = (props: ContentProps) => {
  const { className, fitted, children, ...rest } = props;

  return (
    <Layout.Content
      className={classes(['Window__content', className])}
      {...rest}
    >
      {(fitted && children) || (
        <div className="Window__contentPadding">{children}</div>
      )}
    </Layout.Content>
  );
};

Window.Content = WindowContent;

const statusToColor = (status) => {
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

type TitleBarProps = Partial<{
  canClose: boolean;
  className: string;
  fancy: boolean;
  onClose: (e) => void;
  onDragStart: (e) => void;
  status: number;
  title: string;
}> &
  PropsWithChildren;

const TitleBar = (props: TitleBarProps) => {
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
      {(status === undefined && (
        <Icon className="TitleBar__statusIcon" name="tools" opacity={0.5} />
      )) || (
        <Icon
          className="TitleBar__statusIcon"
          color={statusToColor(status)}
          name="eye"
        />
      )}
      <div
        className="TitleBar__dragZone"
        onMouseDown={(e) => fancy && onDragStart && onDragStart(e)}
      />
      <div className="TitleBar__title">
        {finalTitle}
        {!!children && <div className="TitleBar__buttons">{children}</div>}
      </div>
      {process.env.NODE_ENV !== 'production' && (
        <div
          className="TitleBar__devBuildIndicator"
          onClick={() => dispatch(toggleKitchenSink())}
        >
          <Icon name="bug" />
        </div>
      )}
      {Boolean(fancy && canClose) && (
        <div className="TitleBar__close TitleBar__clickable" onClick={onClose}>
          ×
        </div>
      )}
    </div>
  );
};
