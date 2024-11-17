import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section } from 'tgui-core/components';
import { Window } from '../layouts';

export const TransferValve = (props) => {
  const { act, data } = useBackend();
  const { tank_one, tank_two, attached_device, valve } = data;
  return (
    <Window width={310} height={300}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Valve Status">
              <Button
                icon={valve ? 'unlock' : 'lock'}
                content={valve ? 'Open' : 'Closed'}
                disabled={!tank_one || !tank_two}
                onClick={() => act('toggle')}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title="Valve Attachment"
          buttons={
            <Button
              content="Configure"
              icon={'cog'}
              disabled={!attached_device}
              onClick={() => act('device')}
            />
          }
        >
          <LabeledList>
            <LabeledList.Item label="Attachment">
              {attached_device ? (
                <Button
                  icon={'eject'}
                  content={attached_device}
                  disabled={!attached_device}
                  onClick={() => act('remove_device')}
                />
              ) : (
                <Box color="average">No Assembly</Box>
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Attachment One">
          <LabeledList>
            <LabeledList.Item label="Attachment">
              {tank_one ? (
                <Button
                  icon={'eject'}
                  content={tank_one}
                  disabled={!tank_one}
                  onClick={() => act('tankone')}
                />
              ) : (
                <Box color="average">No Tank</Box>
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Attachment Two">
          <LabeledList>
            <LabeledList.Item label="Attachment">
              {tank_two ? (
                <Button
                  icon={'eject'}
                  content={tank_two}
                  disabled={!tank_two}
                  onClick={() => act('tanktwo')}
                />
              ) : (
                <Box color="average">No Tank</Box>
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
