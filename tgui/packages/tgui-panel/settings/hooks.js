import { useSelector, useDispatch } from 'tgui/store';
import { selectSettings } from './selectors';
import { toggleSettings } from './actions';

export const useSettings = context => {
  const settings = useSelector(context, selectSettings);
  const dispatch = useDispatch(context);
  return {
    ...settings,
    toggle: () => dispatch(toggleSettings()),
  };
};
