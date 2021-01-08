import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const TransferValve = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    payload,
    attached_device,
    failed,
  } = data;
  return (
    <Window
      width={310}
      height={300}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Valve Status">
              <Button
                icon={failed ? "unlock" : "lock"}
                content={failed ? "Open" : "Closed"}
                disabled={!payload || failed}
                onClick={() => act('toggle')} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title="Valve Attachment"
          buttons={(
            <Button
              content="Configure"
              icon={"cog"}
              disabled={!attached_device}
              onClick={() => act('device')} />
          )}>
          <LabeledList>
            <LabeledList.Item label="Attachment">
              {attached_device ? (
                <Button
                  icon={"eject"}
                  content={attached_device}
                  disabled={!attached_device}
                  onClick={() => act('remove_device')} />
              ) : (
                <Box color="average">
                  No Assembly
                </Box>
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Payload">
          <LabeledList>
            <LabeledList.Item label="Tank Payload">
              {payload ? (
                <Button
                  icon={"eject"}
                  content={payload}
                  disabled={!payload || failed}
                  onClick={() => act('payload')} />
              ) : (
                <Box color="average">
                  No Tank
                </Box>
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
