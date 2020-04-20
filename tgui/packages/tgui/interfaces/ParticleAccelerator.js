import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const ParticleAccelerator = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    assembled,
    power,
    strength,
  } = data;
  return (
    <Window>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item
              label="Status"
              buttons={(
                <Button
                  icon={"sync"}
                  content={"Run Scan"}
                  onClick={() => act('scan')} />
              )}>
              <Box color={assembled ? "good" : "bad"}>
                {assembled
                  ? "Ready - All parts in place"
                  : "Unable to detect all parts"}
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Particle Accelerator Controls">
          <LabeledList>
            <LabeledList.Item label="Power">
              <Button
                icon={power ? 'power-off' : 'times'}
                content={power ? 'On' : 'Off'}
                selected={power}
                disabled={!assembled}
                onClick={() => act('power')} />
            </LabeledList.Item>
            <LabeledList.Item label="Particle Strength">
              <Button
                icon="backward"
                disabled={!assembled}
                onClick={() => act('remove_strength')} />
              {' '}
              {String(strength).padStart(1, '0')}
              {' '}
              <Button
                icon="forward"
                disabled={!assembled}
                onClick={() => act('add_strength')} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
