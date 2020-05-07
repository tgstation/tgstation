import { classes } from 'common/react';
import { decodeHtmlEntities, toTitleCase } from 'common/string';
import { Component, Fragment } from 'inferno';
import { useBackend } from '../backend';
import { IS_IE8, runCommand, winset } from '../byond';
import { Box, Icon } from '../components';
import { UI_DISABLED, UI_INTERACTIVE, UI_UPDATE } from '../constants';
import { dragStartHandler, resizeStartHandler } from '../drag';
import { releaseHeldKeys } from '../hotkeys';
import { createLogger } from '../logging';
import { Layout, refocusLayout } from './Layout';

const logger = createLogger('Window');

export class Window extends Component {
  componentDidMount() {
    refocusLayout();
  }

  render() {
    const {
      resizable,
      theme,
      children,
    } = this.props;
    const {
      config,
      debugLayout,
    } = useBackend(this.context);
    // Determine when to show dimmer
    const showDimmer = config.observer
      ? config.status < UI_DISABLED
      : config.status < UI_INTERACTIVE;
    return (
      <Layout
        className="Window"
        theme={theme}>
        <TitleBar
          className="Window__titleBar"
          title={decodeHtmlEntities(config.title)}
          status={config.status}
          fancy={config.fancy}
          onDragStart={dragStartHandler}
          onClose={() => {
            logger.log('pressed close');
            releaseHeldKeys();
            winset(config.window, 'is-visible', false);
            runCommand(`uiclose ${config.ref}`);
          }} />
        <div
          className={classes([
            'Window__rest',
            debugLayout && 'debug-layout',
          ])}>
          {children}
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

const TitleBar = props => {
  const {
    className,
    title,
    status,
    fancy,
    onDragStart,
    onClose,
  } = props;
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
        {title === title.toLowerCase()
          ? toTitleCase(title)
          : title}
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
          {IS_IE8 ? 'x' : '×'}
        </div>
      )}
    </div>
  );
};
