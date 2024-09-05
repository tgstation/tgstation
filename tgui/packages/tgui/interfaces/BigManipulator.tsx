import { BooleanLike } from 'common/react';

import { useBackend } from '../backend';
import { Button, Section, Stack } from '../components';
import { Window } from '../layouts';

type ManipulatorData = {
  active: BooleanLike;
};

export const BigManipulator = (props) => {
  const { data, act } = useBackend<ManipulatorData>();
  const { active } = data;
  return (
    <Window title="Manipulator Interface" width={320} height={160}>
      <Window.Content>
        <Section title="Action panel">
          <Stack>
            <Button
              icon="power-off"
              content={active ? 'On' : 'Off'}
              selected={active}
              onClick={() => act('on')}
            />
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
