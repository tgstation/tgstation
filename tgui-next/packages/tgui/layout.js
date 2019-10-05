import { classes } from 'common/react';
import { decodeHtmlEntities } from 'common/string';
import { Component, createRef } from 'inferno';
import { runCommand, winset } from './byond';
import { TitleBar } from './components';
import { BUTTON_ACTIVATION_KEYCODES } from './components/Button';
import { Toast } from './components/Toast';
import { UI_INTERACTIVE } from './constants';
import { dragStartHandler, resizeStartHandler } from './drag';
import { Acclimator } from './interfaces/Acclimator';
import { AIAirlock } from './interfaces/AIAirlock';
import { AirAlarm } from './interfaces/AirAlarm';
import { ChemDispenser } from './interfaces/ChemDispenser';
import { KitchenSink } from './interfaces/KitchenSink';
import { createLogger } from './logging';

const logger = createLogger('Layout');

const ROUTES = {
  airalarm: {
    component: () => AirAlarm,
    scrollable: true,
  },
  acclimator: {
    component: () => Acclimator,
    scrollable: false,
  },
  ai_airlock: {
    component: () => AIAirlock,
    scrollable: false,
  },
  chem_dispenser: {
    component: () => ChemDispenser,
    scrollable: true,
  },
};

export const getRoute = state => {
  // Show a kitchen sink
  if (state.showKitchenSink) {
    return {
      component: () => KitchenSink,
      scrollable: true,
    };
  }
  // Refer to the routing table
  return ROUTES[state.config && state.config.interface];
};

export class Layout extends Component {
  constructor() {
    super();
    this.contentRef = createRef();
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
          ref={this.contentRef}
          className={classes([
            'Layout__content',
            scrollable && 'Layout__content--scrollable',
          ])}
          onclick={() => {
            // Bring focus back to the window on every click
            this.contentRef.current.focus();
          }}
          onKeyPress={e => {
            // Bring focus back to the window on every keypress
            const keyCode = window.event ? e.which : e.keyCode;
            if (BUTTON_ACTIVATION_KEYCODES.includes(keyCode)) {
              this.contentRef.current.focus();
            }
          }}>
          <Component state={state} dispatch={dispatch} />
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
