import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import { Input, Section, Button } from '../components';

type Data = {
  upper: string;
  lower: string;
};

export const NtosStatus = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { upper, lower } = data;

  return (
    <NtosWindow width={310} height={200}>
      <NtosWindow.Content>
        <Section>
          <Input
            fluid
            value={upper}
            onChange={(_, value) =>
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
            onChange={(_, value) =>
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
