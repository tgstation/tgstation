import { useBackend } from '../backend';
import { Button, Section, Input, Dropdown } from '../components';
import { Window } from '../layouts';

export const AiVoiceChanger = (props, context) => {
  const { act, data } = useBackend(context);

  return (
    <Window resizable title="Voice changer settings">
      <Section>
        <Button
          icon={data.on ? 'power-off' : 'times'}
          content={data.on ? 'On' : 'Off'}
          selected={data.on}
          onClick={() => act('power')} />
        <Button
          icon={data.loud ? 'power-off' : 'times'}
          content={data.loud ? 'Loudmode on' : 'Loudmode Off'}
          selected={data.loud}
          onClick={() => act('loud')} />
      </Section>
      <Section title="Voice look" >
        <Dropdown
          options={data.voices}
          onSelected={(value) => act('look', {
            look: value,
          })} />
      </Section>
      <Section title="Say verb">
        <Input
          default={data.say_verb}
          onChange={(e, value) => act("verb", {
            verb: value,
          })} />
      </Section>
      <Section title="Fake name">
        <Input
          default={data.name}
          onChange={(e, value) => act("name", {
            name: value,
          })} />
      </Section>
    </Window>
  );
};
