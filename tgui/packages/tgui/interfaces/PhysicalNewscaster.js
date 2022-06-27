import { Newscaster } from '../interfaces/Newscaster';
import { Window } from '../layouts';

export const PhysicalNewscaster = (props, context) => {
  return (
    <Window width={575} height={560}>
      <Window.Content scrollable>
        <Newscaster />
      </Window.Content>
    </Window>
  );
};
