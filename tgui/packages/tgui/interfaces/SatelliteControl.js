import { useBackend } from '../backend';
import { Box, Button, LabeledList, ProgressBar, Section } from '../components';
import { LabeledListItem } from '../components/LabeledList';
import { Window } from '../layouts';

export const SatelliteControl = (props, context) => {
  const { act, data } = useBackend(context);
  const satellites = data.satellites || [];
  return (
    <Window
      width={400}
      height={305}>
      <Window.Content>
        {data.meteor_shield && (
          <Section>
            <LabeledList>
              <LabeledListItem label="Coverage">
                <ProgressBar
                  value={data.meteor_shield_coverage
                    / data.meteor_shield_coverage_max}
                  content={100 * data.meteor_shield_coverage
                    / data.meteor_shield_coverage_max + '%'}
                  ranges={{
                    good: [1, Infinity],
                    average: [0.30, 1],
                    bad: [-Infinity, 0.30],
                  }} />
              </LabeledListItem>
            </LabeledList>
          </Section>
        )}
        <Section title="Satellite Controls">
          <Box mr={-1}>
            {satellites.map(satellite => (
              <Button.Checkbox
                key={satellite.id}
                checked={satellite.active}
                content={"#" + satellite.id + " " + satellite.mode}
                onClick={() => act('toggle', {
                  id: satellite.id,
                })}
              />
            ))}
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};
