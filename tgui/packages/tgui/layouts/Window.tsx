/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import {
  type ComponentProps,
  type PropsWithChildren,
  type ReactNode,
  useEffect,
  useLayoutEffect,
  useState,
} from 'react';
import { type Box, KeyListener } from 'tgui-core/components';
import { UI_DISABLED, UI_INTERACTIVE } from 'tgui-core/constants';
import type { KeyEvent } from 'tgui-core/events';
import { KEY_ALT } from 'tgui-core/keycodes';
import { type BooleanLike, classes } from 'tgui-core/react';
import { decodeHtmlEntities } from 'tgui-core/string';
import { useBackend } from '../backend';
import {
  dragStartHandler,
  recallWindowGeometry,
  resizeStartHandler,
  setWindowKey,
  setWindowPosition,
  storeWindowGeometry,
} from '../drag';
import { suspendStart } from '../events/handlers/suspense';
import { createLogger } from '../logging';
import { Layout } from './Layout';
import { TitleBar } from './TitleBar';

const logger = createLogger('Window');
const DEFAULT_SIZE: [number, number] = [400, 600];

type Props = Partial<{
  buttons: ReactNode;
  canClose: BooleanLike;
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

  const { config, suspended, debug } = useBackend();

  const [isReadyToRender, setIsReadyToRender] = useState(false);

  // We need to set the window to be invisible before we can set its geometry
  // Otherwise, we get a flicker effect when the window is first rendered
  useLayoutEffect(() => {
    Byond.winset(Byond.windowId, {
      'is-visible': false,
    });
    setIsReadyToRender(true);
  }, []);

  const { scale } = config?.window || false;

  useEffect(() => {
    if (!suspended && isReadyToRender) {
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
        Byond.winset(Byond.windowId, {
          'is-visible': true,
        });
        logger.log('set to visible');
      };

      Byond.winset(Byond.windowId, {
        'can-close': Boolean(canClose),
      });
      logger.log('mounting');
      updateGeometry();
    }
    return () => {
      logger.log('unmounting');
    };
  }, [isReadyToRender, width, height, scale]);

  // Determine when to show dimmer
  const showDimmer =
    config.user &&
    (config.user.observer
      ? config.status < UI_DISABLED
      : config.status < UI_INTERACTIVE);

  return suspended ? null : (
    <Layout className="Window" theme={theme}>
      <TitleBar
        title={title || decodeHtmlEntities(config.title)}
        status={config.status}
        onDragStart={dragStartHandler}
        onClose={suspendStart}
        canClose={canClose}
      >
        {buttons}
      </TitleBar>
      <div
        className={classes([
          'Window__rest',
          debug.debugLayout && 'debug-layout',
        ])}
      >
        {!suspended && children}
        {showDimmer && <div className="Window__dimmer" />}
      </div>
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
    </Layout>
  );
};

type ContentProps = Partial<{
  className: string;
  fitted: boolean;
  scrollable: boolean;
  vertical: boolean;
}> &
  ComponentProps<typeof Box> &
  PropsWithChildren;

const WindowContent = (props: ContentProps) => {
  const { className, fitted, children, ...rest } = props;
  const [altDown, setAltDown] = useState(false);

  var dragStartIfAltHeld = (event) => {
    if (altDown) {
      dragStartHandler(event);
    }
  };

  Byond.subscribeTo('resetposition', (payload) => {
    setWindowPosition([0, 0]);
    storeWindowGeometry();
  });
  return (
    <Layout.Content
      onMouseDown={dragStartIfAltHeld}
      className={classes(['Window__content', className])}
      {...rest}
    >
      <KeyListener
        onKeyDown={(e: KeyEvent) => {
          if (KEY_ALT === e.code) {
            setAltDown(true);
            logger.log(`alt on ${altDown}`);
          }
        }}
        onKeyUp={(e: KeyEvent) => {
          if (KEY_ALT === e.code) {
            setAltDown(false);
            logger.log(`alt off ${altDown}`);
          }
        }}
      />

      {(fitted && children) || (
        <div className="Window__contentPadding">{children}</div>
      )}
    </Layout.Content>
  );
};

Window.Content = WindowContent;
