import { Newscaster } from './Newscaster';
import { Window } from '../layouts';

export const PhysicalNewscaster = () => {
  return (
    <Window width={575} height={560}>
      <Window.Content scrollable>
        <Newscaster />
      </Window.Content>
    </Window>
  );
};
