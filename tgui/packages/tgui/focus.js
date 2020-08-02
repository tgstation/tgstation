/**
 * Normalized browser focus events and focus helpers.
 */

import { EventEmitter } from 'common/events';
import { logger } from './logging';

const events = new EventEmitter();

let timeout;
let focused = true;

const handleFocus = () => {
  if (focused !== true) {
    focused = true;
    events.emit('focus');
    events.emit('change', focused);
  }
};

const handleBlur = () => {
  if (focused !== false) {
    focused = false;
    events.emit('blur');
    events.emit('change', focused);
  }
};

window.addEventListener('focusin', () => {
  handleFocus();
  clearTimeout(timeout);
});

window.addEventListener('focusout', () => {
  timeout = setTimeout(handleBlur);
});

window.addEventListener('blur', () => {
  clearTimeout(timeout);
  handleBlur();
});

window.addEventListener('beforeunload', handleBlur);

export const isWindowFocused = () => focused;

export const subscribeToLossOfFocus = subscriber => {
  events.on('blur', subscriber);
  return () => {
    events.off('blur', subscriber);
  };
};

export const subscribeToChangeOfFocus = subscriber => {
  events.on('change', subscriber);
  return () => {
    events.off('change', subscriber);
  };
};

export const focusNodeOnMouseOver = node => {
  let focusStolenBy = null;

  const refocusNode = () => {
    if (!focusStolenBy && isWindowFocused()) {
      node.focus();
    }
  };

  const releaseStolenFocus = () => {
    refocusNode();
    focusStolenBy.removeEventListener('blur', releaseStolenFocus);
  };

  const handleFocusIn = e => {
    const tagName = String(e.target.tagName).toLowerCase();
    const elementStealsFocus = (
      tagName === 'input' || tagName === 'textarea'
    );
    if (elementStealsFocus) {
      focusStolenBy = e.target;
      focusStolenBy.addEventListener('blur', releaseStolenFocus);
    }
  };

  window.addEventListener('focusin', handleFocusIn);
  node.addEventListener('mouseenter', refocusNode);
  node.addEventListener('click', refocusNode);

  return () => {
    window.removeEventListener('focusin', handleFocusIn);
    node.removeEventListener('mouseenter', refocusNode);
    node.removeEventListener('click', refocusNode);
  };
};
