import { useBackend } from '../backend';
import { Button, LabeledList, NoticeBox, Section } from '../components';
import { Window } from '../layouts';

export const TransferValve = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    tank_one,
    tank_two,
    attached_device,
    valve,
  } = data;
  return (
    <Window>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Valve Status">
              <Button
                icon={valve ? "unlock" : "lock"}
                content={valve ? "Open" : "Closed"}
                disabled={!tank_one || !tank_two}
                onClick={() => act('toggle')} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title="Valve Attachment"
          buttons={(
            <Button
              textAlign="center"
              width="30px"
              icon={"cog"}
              disabled={(!attached_device)}
              onClick={() => act('device')} />
          )}>
          <LabeledList>
            {attached_device ? (
              <LabeledList.Item label="Attachment">
                <Button
                  icon={"wrench"}
                  content={attached_device}
                  disabled={!attached_device}
                  onClick={() => act('remove_device')} />
              </LabeledList.Item>
            ) : (
              <NoticeBox textAlign="center">
                Insert Assembly
              </NoticeBox>
            )}
          </LabeledList>
        </Section>
        <Section title="Attachment One">
          <LabeledList>
            {tank_one ? (
              <LabeledList.Item label="Attachment">
                <Button
                  icon={"wrench"}
                  content={tank_one}
                  disabled={!tank_one}
                  onClick={() => act('tankone')} />
              </LabeledList.Item>
            ) : (
              <NoticeBox textAlign="center">
                Insert Tank
              </NoticeBox>
            )}
          </LabeledList>
        </Section>
        <Section title="Attachment Two">
          <LabeledList>
            {tank_two ? (
              <LabeledList.Item label="Attachment">
                <Button
                  icon={"wrench"}
                  content={tank_two}
                  disabled={!tank_two}
                  onClick={() => act('tanktwo')} />
              </LabeledList.Item>
            ) : (
              <NoticeBox textAlign="center">
                Insert Tank
              </NoticeBox>
            )}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
