import { toFixed } from 'common/math';
import { decodeHtmlEntities } from 'common/string';
import { Fragment } from 'inferno';
import { act } from '../byond';
import { Box, Button, LabeledList, Section, Table } from '../components';
import { InterfaceLockNoticeBox } from './common/InterfaceLockNoticeBox';
import { classes } from 'common/react';

export const HealthIcon = props => {
  const {level} = props;
  const healthColorMap = [
    "#17d568",
    "#2ecc71",
    "#e67e22",
    "#ed5100",
    "#e74c3c",
    "#ed2814",
  ];
  return (
    <Box
      inline={1}
      width="16px"
      height="16px"
      position="relative"
      ml={2.5}
      style={{ "background-color": healthColorMap[level], "vertical-align": "text-bottom" }}
    />
  );
};

export const CrewConsole = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  const locked = data.locked && !data.siliconUser;
  const isHead = function (jobId) {
    return jobId % 10 === 0;
  };
  const deptClass = function (jobId) {
    if (jobId === 0)	{ // captain
      return "dept-cap";
    }
    else if	(jobId >= 10 && jobId < 20)	{ // security
      return "dept-sec";
    }
    else if (jobId >= 20 && jobId < 30)	{ // medical
      return "dept-med";
    }
    else if (jobId >= 30 && jobId < 40)	{ // science
      return "dept-sci";
    }
    else if (jobId >= 40 && jobId < 50)	{ // engineering
      return "dept-eng";
    }
    else if (jobId >= 50 && jobId < 60)	{ // cargo
      return "dept-cargo";
    }
    else if (jobId >= 200 && jobId < 230)	{ // CentCom
      return "dept-cent";
    }
    else { // other / unknown
      return "dept-other";
    }
  };
  const healthLevel = function (oxy, tox, burn, brute) {
    const healthSum = oxy + tox + burn + brute;
    return Math.min(Math.max(Math.ceil(healthSum / 25), 0), 5);
  };
  const sensors = data.sensors || [];
  return (
    <Section minHeight={90}>
      <Table>
        <Table.Row>
          <Table.Cell bold width="40%">
            Name
          </Table.Cell>
          <Table.Cell bold width="5%">
            Status
          </Table.Cell>
          <Table.Cell bold width="20%" textAlign="center">
            Vitals
          </Table.Cell>
          <Table.Cell bold>
            Position
          </Table.Cell>
          {!!data.link_allowed && (
            <Table.Cell bold>
              Tracking
            </Table.Cell>
          )}
        </Table.Row>
        {sensors.map(sensor => (
          <Table.Row key={sensor.name}>
            <Table.Cell
              bold={isHead(sensor.ijob)}
              color={deptClass(sensor.ijob)}>
              {sensor.name} ({sensor.assignment})
            </Table.Cell>
            <Table.Cell>
              <HealthIcon
                level={healthLevel(sensor.oxydam, sensor.toxdam, sensor.brutedam, sensor.brutedam)}
              />
            </Table.Cell>
            <Table.Cell>
              {sensor.oxydam !== null ? (
                <Box textAlign="center">
                  (
                  <Box inline width={4} color="damage-oxy" textAlign="center">
                    {sensor.oxydam}
                  </Box>
                  /
                  <Box inline width={4} color="damage-toxin" textAlign="center">
                    {sensor.toxdam}
                  </Box>
                  /
                  <Box inline width={4} color="damage-burn" textAlign="center">
                    {sensor.burndam}
                  </Box>
                  /
                  <Box inline width={4} color="damage-brute" textAlign="center">
                    {sensor.brutedam}
                  </Box>
                  )
                </Box>
              ) : (
                sensor.life_status ? "Alive" : "Dead"
              )}
            </Table.Cell>
            <Table.Cell>
              {sensor.pos_x !== null ? (
                sensor.area
              ) : (
                "N/A"
              )}
            </Table.Cell>
            {!!data.link_allowed && (
              <Table.Cell>
                <Button
                  content="Track"
                  disabled={!sensor.can_track}
                  onClick={() => act(ref, "select_person", {name: sensor.name})}
                />
              </Table.Cell>
            )}
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};
