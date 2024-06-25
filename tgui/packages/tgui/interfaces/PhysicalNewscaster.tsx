import { Window } from '../layouts';
import { Newscaster } from './Newscaster';

export const PhysicalNewscaster = () => {
  return (
    <Window width={575} height={560}>
      <Window.Content scrollable>
        <Newscaster />
      </Window.Content>
    </Window>
  );
};
