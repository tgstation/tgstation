import { Button } from 'tgui-core/components';
import { useBackend } from '../../backend';

type Props = {
  /** Current layout state, which will be passed. */
  state: string;
  /** The function to call when the user clicks. */
  onToggle: () => void;
};

export enum LAYOUT {
  Default = 'default',
  Grid = 'grid',
  List = 'list',
}

/**
 * Allows the user to toggle between grid and list layouts, if preference on Default value.
 * Otherwise it'll be controlled by preferences.
 */
export function LayoutToggle(props: Props) {
  const { config } = useBackend();
  const { onToggle, state } = props;

  if (config.window.layout === LAYOUT.Default) {
    return (
      <Button
        icon={state === LAYOUT.Grid ? 'list' : 'border-all'}
        tooltip={state === LAYOUT.Grid ? 'View as List' : 'View as Grid'}
        tooltipPosition={'bottom-end'}
        onClick={() => onToggle()}
      />
    );
  }
}
