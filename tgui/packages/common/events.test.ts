import { EventEmitter } from './events';

describe('EventEmitter', () => {
  it('should add and trigger an event listener', () => {
    const emitter = new EventEmitter();
    const mockListener = jest.fn();
    emitter.on('test', mockListener);
    emitter.emit('test', 'payload');
    expect(mockListener).toHaveBeenCalledWith('payload');
  });

  it('should remove an event listener', () => {
    const emitter = new EventEmitter();
    const mockListener = jest.fn();
    emitter.on('test', mockListener);
    emitter.off('test', mockListener);
    emitter.emit('test', 'payload');
    expect(mockListener).not.toHaveBeenCalled();
  });

  it('should not fail when emitting an event with no listeners', () => {
    const emitter = new EventEmitter();
    expect(() => emitter.emit('test', 'payload')).not.toThrow();
  });

  it('should clear all event listeners', () => {
    const emitter = new EventEmitter();
    const mockListener = jest.fn();
    emitter.on('test', mockListener);
    emitter.clear();
    emitter.emit('test', 'payload');
    expect(mockListener).not.toHaveBeenCalled();
  });
});
