import { classes } from 'common/react';
import { decodeHtmlEntities } from 'common/string';
import { Component, Fragment } from 'inferno';
import { runCommand, winset } from './byond';
import { Box, TitleBar } from './components';
import { UI_DISABLED, UI_INTERACTIVE } from './constants';
import { dragStartHandler, resizeStartHandler } from './drag';
import { releaseHeldKeys } from './hotkeys';
import { createLogger } from './logging';
import { refocusLayout } from './refocus';
import { getRoute } from './routes';

const logger = createLogger('Layout');

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

export class Layout extends Component {
  componentDidMount() {
    refocusLayout();
  }

  render() {
    const { props } = this;
    const { state, dispatch } = props;
    const { config } = state;
    const route = getRoute(state);
    const { scrollable, resizable, theme } = route || {};
    let contentElement;
    if (route) {
      const RoutedComponent = route.component();
      const WrapperComponent = route.wrapper && route.wrapper();
      // Render content
      contentElement = (
        <LayoutContent scrollable={scrollable}>
          <RoutedComponent state={state} dispatch={dispatch} />
        </LayoutContent>
      );
      // Wrap into the wrapper component
      if (WrapperComponent) {
        contentElement = (
          <WrapperComponent
            state={state}
            dispatch={dispatch}>
            {contentElement}
          </WrapperComponent>
        );
      }
    }
    else {
      contentElement = (
        <LayoutContent>
          Route entry missing for <b>{config.interface}</b>.
        </LayoutContent>
      );
    }
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
          <div className="Layout__rest">
            {contentElement}
            {showDimmer && (
              <div className="Layout__dimmer" />
            )}
          </div>
          {config.fancy && (scrollable || resizable) && (
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
