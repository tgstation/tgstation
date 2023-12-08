/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { classes } from 'common/react';
import { decodeHtmlEntities, toTitleCase } from 'common/string';
import { Component } from 'inferno';
import { backendSuspendStart, useBackend } from '../backend';
import { Icon } from '../components';
import { UI_DISABLED, UI_INTERACTIVE, UI_UPDATE } from '../constants';
import { toggleKitchenSink } from '../debug/actions';
import { dragStartHandler, recallWindowGeometry, resizeStartHandler, setWindowKey } from '../drag';
import { createLogger } from '../logging';
import { Layout } from './Layout';
import { globalStore } from '../backend';

const logger = createLogger('Window');

const DEFAULT_SIZE = [400, 600];

export class Window extends Component {
  componentDidMount() {
    const { suspended } = useBackend();
    const { canClose = true } = this.props;
    if (suspended) {
      return;
    }
    Byond.winset(Byond.windowId, {
      'can-close': Boolean(canClose),
    });
    logger.log('mounting');
    this.updateGeometry();
  }

  componentDidUpdate(prevProps) {
    // prettier-ignore
    const shouldUpdateGeometry = (
      this.props.width !== prevProps.width
      || this.props.height !== prevProps.height
    );
    if (shouldUpdateGeometry) {
      this.updateGeometry();
    }
  }

  updateGeometry() {
    const { config } = useBackend();
    const options = {
      size: DEFAULT_SIZE,
      ...config.window,
    };
    if (this.props.width && this.props.height) {
      options.size = [this.props.width, this.props.height];
    }
    if (config.window?.key) {
      setWindowKey(config.window.key);
    }
    recallWindowGeometry(options);
  }

  render() {
    const { canClose = true, theme, title, children, buttons } = this.props;
    const { config, suspended, debug } = useBackend();

    let debugLayout = false;
    if (debug) {
      debugLayout = debug.debugLayout;
    }

    const dispatch = globalStore.dispatch;
    const fancy = config.window?.fancy;
    // Determine when to show dimmer
    // prettier-ignore
    const showDimmer = config.user && (
      config.user.observer
        ? config.status < UI_DISABLED
        : config.status < UI_INTERACTIVE
    );
    return (
      <Layout className="Window" theme={theme}>
        <TitleBar
          className="Window__titleBar"
          title={!suspended && (title || decodeHtmlEntities(config.title))}
          status={config.status}
          fancy={fancy}
          onDragStart={dragStartHandler}
          onClose={() => {
            logger.log('pressed close');
            dispatch(backendSuspendStart());
          }}
          canClose={canClose}>
          {buttons}
        </TitleBar>
        <div
          className={classes(['Window__rest', debugLayout && 'debug-layout'])}>
          {!suspended && children}
          {showDimmer && <div className="Window__dimmer" />}
        </div>
        {fancy && (
          <>
            <div
              className="Window__resizeHandle__e"
              onMousedown={resizeStartHandler(1, 0)}
            />
            <div
              className="Window__resizeHandle__s"
              onMousedown={resizeStartHandler(0, 1)}
            />
            <div
              className="Window__resizeHandle__se"
              onMousedown={resizeStartHandler(1, 1)}
            />
          </>
        )}
      </Layout>
    );
  }
}

const WindowContent = (props) => {
  const { className, fitted, children, ...rest } = props;
  return (
    <Layout.Content
      className={classes(['Window__content', className])}
      {...rest}>
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

const TitleBar = (props) => {
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
  // prettier-ignore
  const finalTitle = (
    typeof title === 'string'
    && title === title.toLowerCase()
    && toTitleCase(title)
    || title
  );
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
        onMousedown={(e) => fancy && onDragStart(e)}
      />
      <div className="TitleBar__title">
        {finalTitle}
        {!!children && <div className="TitleBar__buttons">{children}</div>}
      </div>
      {process.env.NODE_ENV !== 'production' && (
        <div
          className="TitleBar__devBuildIndicator"
          onClick={() => dispatch(toggleKitchenSink())}>
          <Icon name="bug" />
        </div>
      )}
      {Boolean(fancy && canClose) && (
        <div
          className="TitleBar__close TitleBar__clickable"
          // IE8: Synthetic onClick event doesn't work on IE8.
          // IE8: Use a plain character instead of a unicode symbol.
          // eslint-disable-next-line react/no-unknown-property
          onclick={onClose}>
          {Byond.IS_LTE_IE8 ? 'x' : '×'}
        </div>
      )}
    </div>
  );
};
