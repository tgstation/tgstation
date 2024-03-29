import { perf } from 'common/perf';
import { ReactNode } from 'react';
import { createRoot, Root } from 'react-dom/client';

import { createLogger } from './logging';

const logger = createLogger('renderer');

let reactRoot: Root;
let initialRender: string | boolean = true;
let suspended = false;

// These functions are used purely for profiling.
export const resumeRenderer = () => {
  initialRender = initialRender || 'resumed';
  suspended = false;
};

export const suspendRenderer = () => {
  suspended = true;
};

type CreateRenderer = <T extends unknown[] = [unknown]>(
  getVNode?: (...args: T) => ReactNode,
) => (...args: T) => void;

enum Render {
  Start = 'render/start',
  Finish = 'render/finish',
}

// prettier-ignore
export const createRenderer: CreateRenderer = (getVNode) => (...args) => {
  perf.mark(Render.Start);
  // Start rendering
  if (!reactRoot) {
    const element = document.getElementById('react-root');
    reactRoot = createRoot(element!);
  }
  if (getVNode) {
    reactRoot.render(getVNode(...args));
  }
  else {
    reactRoot.render(args[0] as any);
  }
  perf.mark(Render.Finish);
  if (suspended) {
    return;
  }
  // Report rendering time
  if (process.env.NODE_ENV !== 'production') {
    if (initialRender === 'resumed') {
      logger.log('rendered in',
        perf.measure(Render.Start, Render.Finish));
    }
    else if (initialRender) {
      logger.debug('serving from:', location.href);
      logger.debug('bundle entered in',
        perf.measure('inception', 'init'));
      logger.debug('initialized in',
        perf.measure('init', Render.Start));
      logger.log('rendered in',
        perf.measure(Render.Start, Render.Finish));
      logger.log('fully loaded in',
        perf.measure('inception', Render.Finish));
    }
    else {
      logger.debug('rendered in',
        perf.measure(Render.Start, Render.Finish));
    }
  }
  if (initialRender) {
    initialRender = false;
  }
};
