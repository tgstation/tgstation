import { Section, Button, LabeledList } from '../components';
import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import { BooleanLike } from 'common/react';

type Data = {
  armed: BooleanLike;
};

export const NtosRevelation = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { armed } = data;

  return (
    <NtosWindow width={400} height={250}>
      <NtosWindow.Content>
        <Section>
          <Button.Input
            fluid
            content="Obfuscate Name..."
            onCommit={(_, value) =>
              act('PRG_obfuscate', {
                new_name: value,
              })
            }
            mb={1}
          />
          <LabeledList>
            <LabeledList.Item
              label="Payload Status"
              buttons={
                <Button
                  content={armed ? 'ARMED' : 'DISARMED'}
                  color={armed ? 'bad' : 'average'}
                  onClick={() => act('PRG_arm')}
                />
              }
            />
          </LabeledList>
          <Button
            fluid
            bold
            content="ACTIVATE"
            textAlign="center"
            color="bad"
            disabled={!armed}
          />
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
