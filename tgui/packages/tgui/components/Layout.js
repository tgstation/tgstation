import { classes } from 'common/react';
import { decodeHtmlEntities, toTitleCase } from 'common/string';
import { Component, Fragment } from 'inferno';
import { runCommand, tridentVersion, winset } from '../byond';
import { UI_DISABLED, UI_INTERACTIVE, UI_UPDATE } from '../constants';
import { dragStartHandler, resizeStartHandler } from '../drag';
import { releaseHeldKeys } from '../hotkeys';
import { createLogger } from '../logging';
import { refocusLayout } from '../refocus';
import { Box } from './Box';
import { Icon } from './Icon';
import { useBackend } from '../backend';

const logger = createLogger('Layout');

export class Layout extends Component {
  componentDidMount() {
    refocusLayout();
  }

  render() {
    const {
      resizable,
      theme = 'nanotrasen',
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
      <div className={'theme-' + theme}>
        <div className="Layout">
          <TitleBar
            className="Layout__titleBar"
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
              'Layout__rest',
              debugLayout && 'debug-layout',
            ])}>
            {children}
            {showDimmer && (
              <div className="Layout__dimmer" />
            )}
          </div>
          {config.fancy && resizable && (
            <Fragment>
              <div className="Layout__resizeHandle__e"
                onMousedown={resizeStartHandler(1, 0)} />
              <div className="Layout__resizeHandle__s"
                onMousedown={resizeStartHandler(0, 1)} />
              <div className="Layout__resizeHandle__se"
                onMousedown={resizeStartHandler(1, 1)} />
            </Fragment>
          )}
        </div>
      </div>
    );
  }
}

const LayoutContent = props => {
  const { scrollable, children } = props;
  return (
    <div
      id="Layout__content"
      className={classes([
        'Layout__content',
        scrollable && 'Layout__content--scrollable',
      ])}>
      <Box m={1}>
        {children}
      </Box>
    </div>
  );
};

Layout.Content = LayoutContent;

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
          {tridentVersion <= 4 ? 'x' : '×'}
        </div>
      )}
    </div>
  );
};
