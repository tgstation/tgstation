/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { classes } from 'common/react';
import { decodeHtmlEntities, toTitleCase } from 'common/string';
import { Component, Fragment } from 'inferno';
import { backendSuspendStart, useBackend } from '../backend';
import { callByond, IS_IE8 } from '../byond';
import { Box, Icon } from '../components';
import { UI_DISABLED, UI_INTERACTIVE, UI_UPDATE } from '../constants';
import { toggleKitchenSink, useDebug } from '../debug';
import { dragStartHandler, recallWindowGeometry, resizeStartHandler, setWindowKey } from '../drag';
import { createLogger } from '../logging';
import { useDispatch } from '../store';
import { Layout, refocusLayout } from './Layout';

const logger = createLogger('Window');

const DEFAULT_SIZE = [400, 600];

export class Window extends Component {
  constructor() {
    super();
    this.fancy = null;
  }

  updateFancy() {
    const { config } = useBackend(this.context);
    if (this.fancy === null) {
      this.fancy = config.fancy;
    }
    if (this.fancy !== config.fancy) {
      logger.log('changing fancy mode to', config.fancy);
      this.fancy = config.fancy;
      callByond('winset', {
        id: window.__windowId__,
        titlebar: !config.fancy,
        'can-resize': !config.fancy,
      });
    }
  }

  componentDidMount() {
    const { config, suspended } = useBackend(this.context);
    if (suspended) {
      return;
    }
    logger.log('mounting');
    const size = [
      this.props.width
        || config.window.size && config.window.size[0]
        || DEFAULT_SIZE[0],
      this.props.height
        || config.window.size && config.window.size[1]
        || DEFAULT_SIZE[1],
    ];
    setWindowKey(config.window.key);
    recallWindowGeometry(config.window.key, { size });
    this.updateFancy();
    refocusLayout();
  }

  componentDidUpdate() {
    this.updateFancy();
  }

  render() {
    const {
      resizable,
      theme,
      title,
      children,
    } = this.props;
    const {
      config,
      suspended,
    } = useBackend(this.context);
    const { debugLayout } = useDebug(this.context);
    const dispatch = useDispatch(this.context);
    // Determine when to show dimmer
    const showDimmer = config.user.observer
      ? config.status < UI_DISABLED
      : config.status < UI_INTERACTIVE;
    return (
      <Layout
        className="Window"
        theme={theme}>
        <TitleBar
          className="Window__titleBar"
          title={!suspended && (title || decodeHtmlEntities(config.title))}
          status={config.status}
          fancy={config.fancy}
          onDragStart={dragStartHandler}
          onClose={() => {
            logger.log('pressed close');
            dispatch(backendSuspendStart());
          }} />
        <div
          className={classes([
            'Window__rest',
            debugLayout && 'debug-layout',
          ])}>
          {!suspended && children}
          {showDimmer && (
            <div className="Window__dimmer" />
          )}
        </div>
        {config.fancy && resizable && (
          <Fragment>
            <div className="Window__resizeHandle__e"
              onMousedown={resizeStartHandler(1, 0)} />
            <div className="Window__resizeHandle__s"
              onMousedown={resizeStartHandler(0, 1)} />
            <div className="Window__resizeHandle__se"
              onMousedown={resizeStartHandler(1, 1)} />
          </Fragment>
        )}
      </Layout>
    );
  }
}

const WindowContent = props => {
  const { scrollable, children } = props;
  // A bit lazy to actually write styles for it,
  // so we simply include a Box with margins.
  return (
    <Layout.Content
      scrollable={scrollable}>
      <Box m={1}>
        {children}
      </Box>
    </Layout.Content>
  );
};

Window.Content = WindowContent;

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

const TitleBar = (props, context) => {
  const {
    className,
    title,
    status,
    fancy,
    onDragStart,
    onClose,
  } = props;
  const dispatch = useDispatch(context);
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
        {typeof title === 'string'
          && title === title.toLowerCase()
          && toTitleCase(title)
          || title}
      </div>
      <div
        className="TitleBar__dragZone"
        onMousedown={e => fancy && onDragStart(e)} />
      {process.env.NODE_ENV !== 'production' && (
        <div
          className="TitleBar__devBuildIndicator"
          onClick={() => dispatch(toggleKitchenSink())}>
          <Icon name="bug" />
        </div>
      )}
      {!!fancy && (
        <div
          className="TitleBar__close TitleBar__clickable"
          // IE8: Synthetic onClick event doesn't work on IE8.
          // IE8: Use a plain character instead of a unicode symbol.
          // eslint-disable-next-line react/no-unknown-property
          onclick={onClose}>
          {IS_IE8 ? 'x' : '×'}
        </div>
      )}
    </div>
  );
};
