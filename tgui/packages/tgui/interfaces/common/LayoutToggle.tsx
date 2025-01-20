import { Button } from 'tgui-core/components';
import { useBackend } from '../../backend';

type Props = {
  /** Current layout state, which will be passed. */
  state: string;
  /** The function to call when the user clicks. */
  onToggle: (newState: string) => void;
};

export enum LAYOUT {
  Default = 'default',
  Grid = 'grid',
  List = 'list',
}

export function getLayoutState(defaultState?) {
  const { config } = useBackend();
  if (config.interface.layout === LAYOUT.Default) {
    return defaultState || LAYOUT.Grid;
  }
  return config.interface.layout;
}

/**
 * Allows the user to toggle between grid and list layouts, if preference on Default value.
 * Otherwise it'll be controlled by preferences.
 */
export function LayoutToggle(props: Props) {
  const { onToggle, state } = props;
  const { config } = useBackend();

  const handleClick = () => {
    const newState = state === LAYOUT.Grid ? LAYOUT.List : LAYOUT.Grid;
    onToggle(newState);
  };

  if (config.interface.layout === LAYOUT.Default) {
    return (
      <Button
        icon={state === LAYOUT.Grid ? 'list' : 'border-all'}
        tooltip={state === LAYOUT.Grid ? 'View as List' : 'View as Grid'}
        tooltipPosition={'bottom-end'}
        onClick={handleClick}
      />
    );
  }
}
