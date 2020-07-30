import { AudioPlayer } from './player';

export const audioMiddleware = store => {
  let initialized = false;
  const player = new AudioPlayer();
  return next => action => {
    const { type, payload } = action;
    if (!initialized) {
      initialized = true;
      player.onPlay(() => {
        store.dispatch({ type: 'audio/playing' });
      });
      player.onStop(() => {
        store.dispatch({ type: 'audio/stopped' });
      });
    }
    if (type === 'audio/playMusic') {
      const { url, ...options } = payload;
      player.play(url, options);
      return next(action);
    }
    if (type === 'audio/stopMusic') {
      player.stop();
      return next(action);
    }
    if (type === 'settings/update' || type === 'settings/load') {
      const { adminMusicVolume } = payload;
      if (typeof adminMusicVolume === 'number') {
        player.setVolume(adminMusicVolume);
      }
      return next(action);
    }
    return next(action);
  };
};
