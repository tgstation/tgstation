import { Window } from '../layouts';
import { WarrantConsole } from './WarrantConsole';

export const PhysicalWarrantConsole = () => {
  return (
    <Window width={500} height={500}>
      <Window.Content scrollable>
        <WarrantConsole />
      </Window.Content>
    </Window>
  );
};
