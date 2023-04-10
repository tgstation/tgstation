import { captureExternalLinks } from './links';

describe('captureExternalLinks', () => {
  let originalDocumentAddEventListener: any;
  let mockDocumentAddEventListener: jest.Mock;

  beforeAll(() => {
    // Store the original `addEventListener` function on the `document` object
    originalDocumentAddEventListener = document.addEventListener;

    // Replace `addEventListener` with a Jest mock function
    mockDocumentAddEventListener = jest.fn();
    document.addEventListener = mockDocumentAddEventListener;
  });

  afterAll(() => {
    // Restore the original `addEventListener` function on the `document` object
    document.addEventListener = originalDocumentAddEventListener;
  });

  beforeEach(() => {
    // Reset the mock function before each test
    mockDocumentAddEventListener.mockReset();
  });

  it('should attach click event listener to the document', () => {
    captureExternalLinks();
    expect(mockDocumentAddEventListener).toHaveBeenCalledTimes(1);
    expect(mockDocumentAddEventListener).toHaveBeenCalledWith(
      'click',
      expect.any(Function)
    );
  });

  it('should prevent default action and open external links in Byond', () => {
    // Mock the Byond object
    (window as any).Byond = {
      sendMessage: jest.fn(),
    };

    const mockEvent = {
      target: document.createElement('a'),
      preventDefault: jest.fn(),
    } as unknown as MouseEvent;

    // External link
    (mockEvent.target as HTMLElement)?.setAttribute(
      'href',
      'https://example.com'
    );
    mockDocumentAddEventListener.mock.calls[0][1](mockEvent);
    expect(mockEvent.preventDefault).toHaveBeenCalledTimes(1);
    expect((window as any).Byond.sendMessage).toHaveBeenCalledTimes(1);
    expect((window as any).Byond.sendMessage).toHaveBeenCalledWith({
      type: 'openLink',
      url: 'https://example.com',
    });

    // Internal link
    (mockEvent.target as HTMLElement)?.setAttribute('href', '?param=value');
    mockDocumentAddEventListener.mock.calls[0][1](mockEvent);
    expect(mockEvent.preventDefault).toHaveBeenCalledTimes(1);
    expect((window as any).Byond.sendMessage).toHaveBeenCalledTimes(1);
  });

  it('should ignore BYOND links', () => {
    // Mock the Byond object
    (window as any).Byond = {
      sendMessage: jest.fn(),
    };

    const mockEvent = {
      target: document.createElement('a'),
      preventDefault: jest.fn(),
    } as unknown as MouseEvent;

    // BYOND link
    (mockEvent.target as HTMLElement)?.setAttribute(
      'href',
      'byond://127.0.0.1:1234'
    );
    mockDocumentAddEventListener.mock.calls[0][1](mockEvent);
    expect(mockEvent.preventDefault).not.toHaveBeenCalled();
    expect((window as any).Byond.sendMessage).not.toHaveBeenCalled();
  });
});
