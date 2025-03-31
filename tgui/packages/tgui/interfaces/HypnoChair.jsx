import {
  Button,
  Icon,
  Input,
  LabeledList,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const HypnoChair = (props) => {
  const { act, data } = useBackend();
  return (
    <Window width={375} height={480}>
      <Window.Content>
        <Section title="Information" backgroundColor="#450F44">
          The Enhanced Interrogation Chamber is designed to induce a deep-rooted
          trance trigger into the subject. Once the procedure is complete, by
          using the implanted trigger phrase, the authorities are able to ensure
          immediate and complete obedience and truthfulness.
        </Section>
        <Section title="Occupant Information" textAlign="center">
          <LabeledList>
            <LabeledList.Item label="Name">
              {data.occupant.name ? data.occupant.name : 'No Occupant'}
            </LabeledList.Item>
            {!!data.occupied && (
              <LabeledList.Item
                label="Status"
                color={
                  data.occupant.stat === 0
                    ? 'good'
                    : data.occupant.stat === 1
                      ? 'average'
                      : 'bad'
                }
              >
                {data.occupant.stat === 0
                  ? 'Conscious'
                  : data.occupant.stat === 1
                    ? 'Unconscious'
                    : 'Dead'}
              </LabeledList.Item>
            )}
          </LabeledList>
        </Section>
        <Section title="Operations" textAlign="center">
          <LabeledList>
            <LabeledList.Item label="Door">
              <Button
                icon={data.open ? 'unlock' : 'lock'}
                color={data.open ? 'default' : 'red'}
                content={data.open ? 'Open' : 'Closed'}
                onClick={() => act('door')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Trigger Phrase">
              <Input
                value={data.trigger}
                onChange={(e, value) =>
                  act('set_phrase', {
                    phrase: value,
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label="Interrogate Occupant">
              <Button
                icon="code-branch"
                content={
                  data.interrogating
                    ? 'Interrupt Interrogation'
                    : 'Begin Enhanced Interrogation'
                }
                onClick={() => act('interrogate')}
              />
              {data.interrogating === 1 && (
                <Icon name="cog" color="orange" spin />
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
