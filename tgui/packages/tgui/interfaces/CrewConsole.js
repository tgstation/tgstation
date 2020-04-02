import { useBackend } from '../backend';
import { Box, Button, ColorBox, Section, Table } from '../components';
import { COLORS } from '../constants';

const HEALTH_COLOR_BY_LEVEL = [
  '#17d568',
  '#2ecc71',
  '#e67e22',
  '#ed5100',
  '#e74c3c',
  '#ed2814',
];

const jobIsHead = jobId => jobId % 10 === 0;

const jobToColor = jobId => {
  if (jobId === 0) {
    return COLORS.department.captain;
  }
  if (jobId >= 10 && jobId < 20) {
    return COLORS.department.security;
  }
  if (jobId >= 20 && jobId < 30) {
    return COLORS.department.medbay;
  }
  if (jobId >= 30 && jobId < 40) {
    return COLORS.department.science;
  }
  if (jobId >= 40 && jobId < 50) {
    return COLORS.department.engineering;
  }
  if (jobId >= 50 && jobId < 60) {
    return COLORS.department.cargo;
  }
  if (jobId >= 200 && jobId < 230) {
    return COLORS.department.centcom;
  }
  return COLORS.department.other;
};

const healthToColor = (oxy, tox, burn, brute) => {
  const healthSum = oxy + tox + burn + brute;
  const level = Math.min(Math.max(Math.ceil(healthSum / 25), 0), 5);
  return HEALTH_COLOR_BY_LEVEL[level];
};

const HealthStat = props => {
  const { type, value } = props;
  return (
    <Box
      inline
      width={4}
      color={COLORS.damageType[type]}
      textAlign="center">
      {value}
    </Box>
  );
};

export const CrewConsole = props => {
  const { act, data } = useBackend(props);
  const sensors = data.sensors || [];
  return (
    <Section minHeight={90}>
      <Table>
        <Table.Row>
          <Table.Cell bold>
            Name
          </Table.Cell>
          <Table.Cell bold collapsing />
          <Table.Cell bold collapsing textAlign="center">
            Vitals
          </Table.Cell>
          <Table.Cell bold>
            Position
          </Table.Cell>
          {!!data.link_allowed && (
            <Table.Cell bold collapsing>
              Tracking
            </Table.Cell>
          )}
        </Table.Row>
        {sensors.map(sensor => (
          <Table.Row key={sensor.name}>
            <Table.Cell
              bold={jobIsHead(sensor.ijob)}
              color={jobToColor(sensor.ijob)}>
              {sensor.name} ({sensor.assignment})
            </Table.Cell>
            <Table.Cell collapsing textAlign="center">
              <ColorBox
                color={healthToColor(
                  sensor.oxydam,
                  sensor.toxdam,
                  sensor.burndam,
                  sensor.brutedam)} />
            </Table.Cell>
            <Table.Cell collapsing textAlign="center">
              {sensor.oxydam !== null ? (
                <Box inline>
                  <HealthStat type="oxy" value={sensor.oxydam} />
                  {'/'}
                  <HealthStat type="toxin" value={sensor.toxdam} />
                  {'/'}
                  <HealthStat type="burn" value={sensor.burndam} />
                  {'/'}
                  <HealthStat type="brute" value={sensor.brutedam} />
                </Box>
              ) : (
                sensor.life_status ? 'Alive' : 'Dead'
              )}
            </Table.Cell>
            <Table.Cell>
              {sensor.pos_x !== null ? sensor.area : 'N/A'}
            </Table.Cell>
            {!!data.link_allowed && (
              <Table.Cell collapsing>
                <Button
                  content="Track"
                  disabled={!sensor.can_track}
                  onClick={() => act('select_person', {
                    name: sensor.name,
                  })} />
              </Table.Cell>
            )}
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};
