import { useBackend } from '../backend';
import { Button, LabeledList, NoticeBox, Section } from '../components';
import { Window } from '../layouts';

export const StackingConsole = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    machine,
  } = data;
  return (
    <Window
      width={320}
      height={340}
      resizable>
      <Window.Content scrollable>
        {!machine ? (
          <NoticeBox>
            No connected stacking machine
          </NoticeBox>
        ) : (
          <StackingConsoleContent />
        )}
      </Window.Content>
    </Window>
  );
};

export const StackingConsoleContent = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    stacking_amount,
    contents = [],
  } = data;
  return (
    <>
      <Section>
        <LabeledList>
          <LabeledList.Item label="Stacking Amount">
            {stacking_amount || "Unknown"}
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section title="Stored Materials">
        {!contents.length ? (
          <NoticeBox>
            No stored materials
          </NoticeBox>
        ) : (
          <LabeledList>
            {contents.map(sheet => (
              <LabeledList.Item
                key={sheet.type}
                label={sheet.name}
                buttons={(
                  <Button
                    icon="eject"
                    content="Release"
                    onClick={() => act('release', {
                      type: sheet.type,
                    })} />
                )}>
                {sheet.amount || "Unknown"}
              </LabeledList.Item>
            ))}
          </LabeledList>
        )}
      </Section>
    </>
  );
};
