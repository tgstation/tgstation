/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { useDispatch, useSelector } from 'common/redux';
import { updateSettings, toggleSettings } from './actions';
import { selectSettings } from './selectors';

export const useSettings = context => {
  const settings = useSelector(context, selectSettings);
  const dispatch = useDispatch(context);
  return {
    ...settings,
    visible: settings.view.visible,
    toggle: () => dispatch(toggleSettings()),
    update: obj => dispatch(updateSettings(obj)),
  };
};
