import { BooleanLike } from 'common/react';
import { createSearch } from 'common/string';
import { useState } from 'react';
import { Box, Button, Icon, Input, Section, Table } from 'tgui-core/components';

import { useBackend } from '../backend';
import { COLORS } from '../constants';
import { Window } from '../layouts';

const HEALTH_COLOR_BY_LEVEL = [
  '#17d568',
  '#c4cf2d',
  '#e67e22',
  '#ed5100',
  '#e74c3c',
  '#801308',
];

const SORT_NAMES = {
  ijob: 'Job',
  name: 'Name',
  area: 'Position',
  health: 'Vitals',
};

const STAT_LIVING = 0;
const STAT_DEAD = 4;

const SORT_OPTIONS = ['ijob', 'name', 'area', 'health'];

const jobIsHead = (jobId: number) => jobId % 10 === 0;

const jobToColor = (jobId: number) => {
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
  if (jobId >= 60 && jobId < 200) {
    return COLORS.department.service;
  }
  if (jobId >= 200 && jobId < 230) {
    return COLORS.department.centcom;
  }
  return COLORS.department.other;
};

const statToIcon = (life_status: number) => {
  switch (life_status) {
    case STAT_LIVING:
      return 'heart';
    case STAT_DEAD:
      return 'skull';
  }
  return 'heartbeat';
};

const healthSort = (a: CrewSensor, b: CrewSensor) => {
  if (a.life_status < b.life_status) return -1;
  if (a.life_status > b.life_status) return 1;
  if (a.health > b.health) return -1;
  if (a.health < b.health) return 1;
  return 0;
};

const areaSort = (a: CrewSensor, b: CrewSensor) => {
  a.area ??= '~';
  b.area ??= '~';
  if (a.area < b.area) return -1;
  if (a.area > b.area) return 1;
  return 0;
};

const healthToAttribute = (
  oxy: number,
  tox: number,
  burn: number,
  brute: number,
  attributeList: string[],
) => {
  const healthSum = oxy + tox + burn + brute;
  const level = Math.min(Math.max(Math.ceil(healthSum / 25), 0), 5);
  return attributeList[level];
};

type HealthStatProps = {
  type: string;
  value: number;
};

const HealthStat = (props: HealthStatProps) => {
  const { type, value } = props;
  return (
    <Box inline width={2} color={COLORS.damageType[type]} textAlign="center">
      {value}
    </Box>
  );
};

export const CrewConsole = () => {
  return (
    <Window title="Crew Monitor" width={600} height={600}>
      <Window.Content scrollable>
        <Section minHeight="540px">
          <CrewTable />
        </Section>
      </Window.Content>
    </Window>
  );
};

type CrewSensor = {
  name: string;
  assignment: string | undefined;
  ijob: number;
  life_status: number;
  oxydam: number;
  toxdam: number;
  burndam: number;
  brutedam: number;
  area: string | undefined;
  health: number;
  can_track: BooleanLike;
  ref: string;
};

type CrewConsoleData = {
  sensors: CrewSensor[];
  link_allowed: BooleanLike;
};

const CrewTable = () => {
  const { data } = useBackend<CrewConsoleData>();
  const { sensors } = data;

  const [sortAsc, setSortAsc] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [sortBy, setSortBy] = useState(SORT_OPTIONS[0]);

  const cycleSortBy = () => {
    let idx = SORT_OPTIONS.indexOf(sortBy) + 1;
    if (idx === SORT_OPTIONS.length) idx = 0;
    setSortBy(SORT_OPTIONS[idx]);
  };

  const nameSearch = createSearch(searchQuery, (crew: CrewSensor) => crew.name);

  const sorted = sensors.filter(nameSearch).sort((a, b) => {
    switch (sortBy) {
      case 'name':
        return sortAsc ? +(a.name > b.name) : +(b.name > a.name);
      case 'ijob':
        return sortAsc ? a.ijob - b.ijob : b.ijob - a.ijob;
      case 'health':
        return sortAsc ? healthSort(a, b) : healthSort(b, a);
      case 'area':
        return sortAsc ? areaSort(a, b) : areaSort(b, a);
      default:
        return 0;
    }
  });

  return (
    <Section
      title={
        <>
          <Button onClick={cycleSortBy}>{SORT_NAMES[sortBy]}</Button>
          <Button onClick={() => setSortAsc(!sortAsc)}>
            <Icon
              style={{ marginLeft: '2px' }}
              name={sortAsc ? 'chevron-up' : 'chevron-down'}
            />
          </Button>
          <Input
            placeholder="Search for name..."
            onInput={(e) =>
              setSearchQuery((e.target as HTMLTextAreaElement).value)
            }
          />
        </>
      }
    >
      <Table>
        <Table.Row>
          <Table.Cell bold>Name</Table.Cell>
          <Table.Cell bold collapsing />
          <Table.Cell bold collapsing textAlign="center">
            Vitals
          </Table.Cell>
          <Table.Cell bold textAlign="center">
            Position
          </Table.Cell>
          {!!data.link_allowed && (
            <Table.Cell bold collapsing textAlign="center">
              Tracking
            </Table.Cell>
          )}
        </Table.Row>
        {sorted.map((sensor) => (
          <CrewTableEntry sensor_data={sensor} key={sensor.ref} />
        ))}
      </Table>
    </Section>
  );
};

type CrewTableEntryProps = {
  sensor_data: CrewSensor;
};

const CrewTableEntry = (props: CrewTableEntryProps) => {
  const { act, data } = useBackend<CrewConsoleData>();
  const { link_allowed } = data;
  const { sensor_data } = props;
  const {
    name,
    assignment,
    ijob,
    life_status,
    oxydam,
    toxdam,
    burndam,
    brutedam,
    area,
    can_track,
  } = sensor_data;

  return (
    <Table.Row className="candystripe">
      <Table.Cell bold={jobIsHead(ijob)} color={jobToColor(ijob)}>
        {name}
        {assignment !== undefined ? ` (${assignment})` : ''}
      </Table.Cell>
      <Table.Cell collapsing textAlign="center">
        {oxydam !== undefined ? (
          <Icon
            name={statToIcon(life_status)}
            color={healthToAttribute(
              oxydam,
              toxdam,
              burndam,
              brutedam,
              HEALTH_COLOR_BY_LEVEL,
            )}
            size={1}
          />
        ) : life_status !== STAT_DEAD ? (
          <Icon name="heart" color="#17d568" size={1} />
        ) : (
          <Icon name="skull" color="#801308" size={1} />
        )}
      </Table.Cell>
      <Table.Cell collapsing textAlign="center">
        {oxydam !== undefined ? (
          <Box inline>
            <HealthStat type="oxy" value={oxydam} />
            {'/'}
            <HealthStat type="toxin" value={toxdam} />
            {'/'}
            <HealthStat type="burn" value={burndam} />
            {'/'}
            <HealthStat type="brute" value={brutedam} />
          </Box>
        ) : life_status !== STAT_DEAD ? (
          'Alive'
        ) : (
          'Dead'
        )}
      </Table.Cell>
      <Table.Cell>
        {area !== '~' && area !== undefined ? (
          area
        ) : (
          <Icon name="question" color="#ffffff" size={1} />
        )}
      </Table.Cell>
      {!!link_allowed && (
        <Table.Cell collapsing>
          <Button
            disabled={!can_track}
            onClick={() =>
              act('select_person', {
                name: name,
              })
            }
          >
            Track
          </Button>
        </Table.Cell>
      )}
    </Table.Row>
  );
};
