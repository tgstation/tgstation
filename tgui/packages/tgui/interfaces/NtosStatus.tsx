import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import { Flex, Input, Section, Button } from '../components';

type Data = {
  upper: string;
  lower: string;
  maxStatusLineLength: number;
};

export const NtosStatus = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { upper, lower, maxStatusLineLength } = data;

  return (
    <NtosWindow width={400} height={350}>
      <NtosWindow.Content>
        <Section>
          <Button
            icon="toggle-off"
            content="Off"
            color="bad"
            onClick={() => act('stat_picture', { picture: 'blank' })}
          />
          <Button
            icon="space-shuttle"
            content="Shuttle ETA / Off"
            color=""
            onClick={() => act('stat_picture', { picture: 'shuttle' })}
          />
        </Section>

        <Section title="Graphics">
          <Button
            icon="flag"
            content="Logo"
            onClick={() => act('stat_picture', { picture: 'default' })}
          />

          <Button
            icon="bell-o"
            content="Red Alert"
            onClick={() => act('stat_picture', { picture: 'redalert' })}
          />

          <Button
            icon="exclamation-triangle"
            content="Lockdown"
            onClick={() => act('stat_picture', { picture: 'lockdown' })}
          />

          <Button
            icon="biohazard"
            content="Biohazard"
            onClick={() => act('stat_picture', { picture: 'biohazard' })}
          />
        </Section>

        <Section title="Message">
          <Flex direction="column" align="stretch">
            <Flex.Item mb={1}>
              <Input
                fluid
                maxLength={maxStatusLineLength}
                value={upper}
                onChange={(_, value) =>
                  act('stat_update', {
                    position: 'upper',
                    text: value,
                  })
                }
              />
            </Flex.Item>

            <Flex.Item mb={1}>
              <Input
                fluid
                maxLength={maxStatusLineLength}
                value={lower}
                onChange={(_, value) =>
                  act('stat_update', {
                    position: 'lower',
                    text: value,
                  })
                }
              />
            </Flex.Item>

            <Flex.Item>
              <Button
                icon="comment-o"
                onClick={() => act('stat_message')}
                content="Send"
              />
            </Flex.Item>
          </Flex>
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
