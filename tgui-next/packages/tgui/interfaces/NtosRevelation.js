import { Section, Button, LabeledList } from "../components";
import { useBackend } from "../backend";

export const NtosRevelation = props => {
  const { act, data } = useBackend(props);

  return (
    <Section>
      <Button.Input
        fluid
        content="Obfuscate Name..."
        onCommit={(e, value) => act('PRG_obfuscate', { new_name: value })}
        mb={1}
      />
      <LabeledList>
        <LabeledList.Item
          label="Payload Status"
          buttons={(
            <Button
              content={data.armed ? 'ARMED' : 'DISARMED'}
              color={data.armed ? 'bad' : 'average'}
              onClick={() => act('PRG_arm')}
            />
          )}
        />
      </LabeledList>
      <Button
        fluid
        bold
        content="ACTIVATE"
        textAlign="center"
        color="bad"
        disabled={!data.armed}
      />
    </Section>
  );
};
