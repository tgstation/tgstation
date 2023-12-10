/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { useDispatch, useSelector } from 'tgui/backend';
import { updateSettings, toggleSettings } from './actions';
import { selectSettings } from './selectors';

export const useSettings = () => {
  const settings = useSelector(selectSettings);
  const dispatch = useDispatch();
  return {
    ...settings,
    visible: settings.view.visible,
    toggle: () => dispatch(toggleSettings()),
    update: (obj) => dispatch(updateSettings(obj)),
  };
};
