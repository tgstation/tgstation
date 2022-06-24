import { NtosWindow } from '../layouts';
import { useBackend } from '../backend';
import { Stack, Input, Section } from '../components';

type Data = {
  note: string;
};

export const NtosNotepad = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { note } = data;

  return (
    <NtosWindow width={600} height={800}>
      <NtosWindow.Content>
        <Stack fill vertical justify="space-between">
          <Stack.Item>
            <Stack grow>
              <Section>{note}</Section>
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <Section fill>
              <Input
                value={note}
                fluid
                onEnter={(_, value) =>
                  act('UpdateNote', {
                    newnote: value,
                  })
                }
              />
            </Section>
          </Stack.Item>
        </Stack>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
