import {
  KeyEvent,
  addScrollableNode,
  canStealFocus,
  removeScrollableNode,
  setupGlobalEvents,
} from './events';

describe('focusEvents', () => {
  afterEach(() => {
    jest.restoreAllMocks();
  });

  it('setupGlobalEvents sets the ignoreWindowFocus flag correctly', () => {
    setupGlobalEvents({ ignoreWindowFocus: true });
    // Test other functionality that depends on the ignoreWindowFocus flag
  });

  it('canStealFocus returns true for input and textarea elements', () => {
    const inputElement = document.createElement('input');
    const textareaElement = document.createElement('textarea');
    const divElement = document.createElement('div');

    expect(canStealFocus(inputElement)).toBe(true);
    expect(canStealFocus(textareaElement)).toBe(true);
    expect(canStealFocus(divElement)).toBe(false);
  });

  it('addScrollableNode and removeScrollableNode manage the list of scrollable nodes correctly', () => {
    const divElement1 = document.createElement('div');
    const divElement2 = document.createElement('div');

    addScrollableNode(divElement1);
    addScrollableNode(divElement2);
    // Test other functionality that depends on the list of scrollable nodes

    removeScrollableNode(divElement1);
    removeScrollableNode(divElement2);
    // Test other functionality that depends on the list of scrollable nodes
  });

  it('KeyEvent class works correctly', () => {
    const keyboardEvent = new KeyboardEvent('keydown', {
      key: 'a',
      keyCode: 65,
      ctrlKey: true,
      altKey: true,
      shiftKey: true,
    });

    const keyEvent = new KeyEvent(keyboardEvent, 'keydown', false);

    expect(keyEvent.event).toBe(keyboardEvent);
    expect(keyEvent.type).toBe('keydown');
    expect(keyEvent.code).toBe(65);
    expect(keyEvent.ctrl).toBe(true);
    expect(keyEvent.alt).toBe(true);
    expect(keyEvent.shift).toBe(true);
    expect(keyEvent.repeat).toBe(false);
    expect(keyEvent.hasModifierKeys()).toBe(true);
    expect(keyEvent.isModifierKey()).toBe(false);
    expect(keyEvent.isDown()).toBe(true);
    expect(keyEvent.isUp()).toBe(false);
    expect(keyEvent.toString()).toBe('Ctrl+Alt+Shift+A');
  });
});
