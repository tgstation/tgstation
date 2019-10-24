import { classes } from 'common/react';
import { decodeHtmlEntities } from 'common/string';
import { Component, Fragment } from 'inferno';
import { runCommand, winset } from './byond';
import { Box, TitleBar } from './components';
import { Toast } from './components/Toast';
import { UI_INTERACTIVE } from './constants';
import { dragStartHandler, resizeStartHandler } from './drag';
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
    const Component = route.component();
    const { scrollable } = route;
    return (
      <Fragment>
        <TitleBar
          className="Layout__titleBar"
          title={decodeHtmlEntities(config.title)}
          status={config.status}
          fancy={config.fancy}
          onDragStart={dragStartHandler}
          onClose={() => {
            logger.log('pressed close');
            winset(config.window, 'is-visible', false);
            runCommand(`uiclose ${config.ref}`);
          }} />
        <div
          id="Layout__content"
          className={classes([
            'Layout__content',
            scrollable && 'Layout__content--scrollable',
          ])}>
          <Box m={1}>
            <Component state={state} dispatch={dispatch} />
          </Box>
        </div>
        {config.status !== UI_INTERACTIVE && (
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
      </Fragment>
    );
  }
}
