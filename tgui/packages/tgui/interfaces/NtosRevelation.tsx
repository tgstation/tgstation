import { Button, LabeledList, Section } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';

type Data = {
  armed: BooleanLike;
};

export const NtosRevelation = (props) => {
  const { act, data } = useBackend<Data>();
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
            onClick={() => act('PRG_activate')}
          />
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
