import { useBackend } from '../backend';

import { Section, Button } from '../components';
import { Window } from '../layouts';

export const ArtifactForm = (props) => {
  const { act, data } = useBackend();
  const {
    allorigins,
    chosenorigin,
    alltypes,
    chosentype,
    alltriggers,
    chosentriggers,
  } = data;
  return (
    <Window width={480} height={400} title={'Analysis Form'} theme={'paper'}>
      <Window.Content>
        <Section title="Origin">
          {allorigins.map((key) => (
            <Button
              key={key}
              icon={chosenorigin === key ? 'check-square-o' : 'square-o'}
              content={key}
              selected={chosenorigin === key}
              onClick={() =>
                act('origin', {
                  origin: key,
                })
              }
            />
          ))}
        </Section>
        <Section title="Type">
          {alltypes.map((x) => (
            <Button
              key={x}
              icon={chosentype.includes(x) ? 'check-square-o' : 'square-o'}
              content={x}
              selected={chosentype.includes(x)}
              onClick={() =>
                act('type', {
                  type: x,
                })
              }
            />
          ))}
        </Section>
        <Section title="Triggers">
          {alltriggers.map((trig) => (
            <Button
              key={trig}
              icon={
                chosentriggers.includes(trig) ? 'check-square-o' : 'square-o'
              }
              content={trig}
              selected={chosentriggers.includes(trig)}
              onClick={() =>
                act('trigger', {
                  trigger: trig,
                })
              }
            />
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
