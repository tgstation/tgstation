import { useBackend } from '../backend';
import { Button, LabeledList, ProgressBar, Section, Table, Box } from '../components';
import { Fragment } from 'inferno';
import { LabeledListItem } from '../components/LabeledList';

export const SatelliteControl = props => {
  const { act, data } = useBackend(props);
  const satellites = data.satellites || [];
  return (
    <Fragment>
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
    </Fragment>
  );
};
