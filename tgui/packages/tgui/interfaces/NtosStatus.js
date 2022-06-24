import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import { Input, Section, Button } from '../components';

export const NtosStatus = (props, context) => {
  const { act, data } = useBackend(context);
  const { upper, lower } = data;

  return (
    <NtosWindow width={310} height={200}>
      <NtosWindow.Content>
        <Section>
          <Input
            fluid
            value={upper}
            onChange={(e, value) =>
              act('stat_update', {
                position: 'upper',
                text: value,
              })
            }
          />
          <br />
          <Input
            fluid
            value={lower}
            onChange={(e, value) =>
              act('stat_update', {
                position: 'lower',
                text: value,
              })
            }
          />
          <br />
          <Button
            fluid
            onClick={() => act('stat_send')}
            content="Update Status Displays"
          />
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
