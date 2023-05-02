import { useBackend } from 'tgui/backend';
import { Stack } from 'tgui/components';
import { Window } from 'tgui/layouts';
import { Data } from './types';
import { BeakerDisplay } from './Beaker';
import { SpecimenDisplay } from './Specimen';

export const Pandemic = (props, context) => {
  const { data } = useBackend<Data>(context);
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
