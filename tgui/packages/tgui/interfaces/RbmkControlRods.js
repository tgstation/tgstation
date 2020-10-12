import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Section, ProgressBar, Slider } from '../components';
import { Window } from '../layouts';

export const RbmkControlRods = (props, context) => {
  const { act, data } = useBackend(context);
  const control_rods = data.control_rods;
  const k = data.k;
  const desiredK = data.desiredK;
  return (
    <Window resizable theme="ntos">
      <Window.Content>
        <Section title="Control Rod Management:">
          Control Rod Insertion:
          <ProgressBar
            value={(control_rods / 100 * 100) * 0.01}
            ranges={{
              good: [0.7, Infinity],
              average: [0.4, 0.7],
              bad: [-Infinity, 0.4],
            }} />
          <br />
          Neutrons per generation (K):
          <br />
          <ProgressBar
            value={(k / 3 * 100) * 0.01}
            ranges={{
              good: [-Infinity, 0.4],
              average: [0.4, 0.6],
              bad: [0.6, Infinity],
            }}>
            {k}
          </ProgressBar>
          <br />
          Target criticality:
          <br />
          <Slider
            value={desiredK}
            fillValue={k}
            minValue={0}
            maxValue={3}
            step={0.1}
            stepPixelSize={5}
            onDrag={(e, value) => act('input', {
              target: value,
            })} />
        </Section>
      </Window.Content>
    </Window>
  );
};
