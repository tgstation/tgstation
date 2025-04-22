import { afterEach, beforeEach, describe, it, vi } from 'vitest';

import { captureExternalLinks } from './links';

describe('captureExternalLinks', () => {
  let addEventListenerSpy;
  let clickHandler;

  beforeEach(() => {
    addEventListenerSpy = vi.spyOn(document, 'addEventListener');
    captureExternalLinks();
    clickHandler = addEventListenerSpy.mock.calls[0][1];
  });

  afterEach(() => {
    addEventListenerSpy.mockRestore();
  });

  it('should subscribe to document clicks', ({ expect }) => {
    expect(addEventListenerSpy).toHaveBeenCalledWith(
      'click',
      expect.any(Function),
    );
  });

  it('should preventDefault and send a message when a non-BYOND external link is clicked', ({
    expect,
  }) => {
    const externalLink = {
      tagName: 'A',
      getAttribute: () => 'https://example.com',
      parentElement: document.body,
    };
    const byond = { sendMessage: vi.fn() };
    // @ts-ignore
    global.Byond = byond;

    const evt = { target: externalLink, preventDefault: vi.fn() };
    clickHandler(evt);

    expect(evt.preventDefault).toHaveBeenCalled();
    expect(byond.sendMessage).toHaveBeenCalledWith({
      type: 'openLink',
      url: 'https://example.com',
    });
  });

  it('should not preventDefault or send a message when a BYOND link is clicked', ({
    expect,
  }) => {
    const byondLink = {
      tagName: 'A',
      getAttribute: () => 'byond://server-address',
      parentElement: document.body,
    };
    const byond = { sendMessage: vi.fn() };
    // @ts-ignore
    global.Byond = byond;

    const evt = { target: byondLink, preventDefault: vi.fn() };
    clickHandler(evt);

    expect(evt.preventDefault).not.toHaveBeenCalled();
    expect(byond.sendMessage).not.toHaveBeenCalled();
  });

  it('should add https:// to www links', ({ expect }) => {
    const wwwLink = {
      tagName: 'A',
      getAttribute: () => 'www.example.com',
      parentElement: document.body,
    };
    const byond = { sendMessage: vi.fn() };
    // @ts-ignore
    global.Byond = byond;

    const evt = { target: wwwLink, preventDefault: vi.fn() };
    clickHandler(evt);

    expect(byond.sendMessage).toHaveBeenCalledWith({
      type: 'openLink',
      url: 'https://www.example.com',
    });
  });
});
