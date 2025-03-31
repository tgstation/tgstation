import { useBackend } from 'tgui/backend';
import { Window } from 'tgui/layouts';
import { Stack } from 'tgui-core/components';

import { BeakerDisplay } from './Beaker';
import { SpecimenDisplay } from './Specimen';
import { Data } from './types';

export const Pandemic = (props) => {
  const { data } = useBackend<Data>();
  const { has_beaker, has_blood } = data;

  return (
    <Window width={650} height={500}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <BeakerDisplay />
          </Stack.Item>
          {!!has_beaker && !!has_blood && (
            <Stack.Item grow>
              <SpecimenDisplay />
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};
