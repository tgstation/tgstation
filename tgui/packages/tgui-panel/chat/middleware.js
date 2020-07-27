import { updateMessageCount } from './actions';
import { chatRenderer } from './renderer';

export const chatMiddleware = store => {
  chatRenderer.onBatchProcesed(countByType => {
    store.dispatch(updateMessageCount(countByType));
  });
  return next => action => {
    const { type, payload } = action;
    if (type === 'chat/message') {
      // Normalize the payload
      const batch = Array.isArray(payload) ? payload : [payload];
      chatRenderer.processBatch(batch);
      return;
    }
    if (type === 'chat/changePage') {
      const { page } = payload;
      chatRenderer.changePage(page);
      return next(action);
    }
    return next(action);
  };
};
