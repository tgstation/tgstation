import { classes } from 'common/react';
import { decodeHtmlEntities } from 'common/string';
import { Component, Fragment } from 'inferno';
import { runCommand, winset } from './byond';
import { Box, TitleBar } from './components';
import { Toast } from './components/Toast';
import { UI_DISABLED, UI_INTERACTIVE } from './constants';
import { dragStartHandler, resizeStartHandler } from './drag';
import { releaseHeldKeys } from './hotkeys';
import { createLogger } from './logging';
import { refocusLayout } from './refocus';
import { getRoute } from './routes';

const logger = createLogger('Layout');

export class Layout extends Component {
  componentDidMount() {
    refocusLayout();
  }

  render() {
    const { props } = this;
    const { state, dispatch } = props;
    const { config } = state;
    const route = getRoute(state);
    if (!route) {
      return `Component for '${config.interface}' was not found.`;
    }
    const RoutedComponent = route.component();
    const WrapperComponent = route.wrapper && route.wrapper();
    const { scrollable, theme } = route;
    // Render content
    let contentElement = (
      <div
        id="Layout__content"
        className={classes([
          'Layout__content',
          scrollable && 'Layout__content--scrollable',
        ])}>
        <Box m={1}>
          <RoutedComponent state={state} dispatch={dispatch} />
        </Box>
      </div>
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
          {contentElement}
          {showDimmer && (
            <div className="Layout__dimmer" />
          )}
          {state.toastText && (
            <Toast content={state.toastText} />
          )}
          {config.fancy && scrollable && (
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
