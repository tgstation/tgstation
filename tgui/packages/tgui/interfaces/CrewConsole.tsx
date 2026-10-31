import { useState } from 'react';
import {
  Box,
  Button,
  Flex,
  Icon,
  Input,
  Section,
  Table,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { createSearch } from 'tgui-core/string';

import { useBackend } from '../backend';
import { COLORS } from '../constants';
import { Window } from '../layouts';
import { StationMap } from './common/StationMap';

const HEALTH_COLOR_BY_LEVEL = [
  '#17d568',
  '#c4cf2d',
  '#e67e22',
  '#ed5100',
  '#e74c3c',
  '#801308',
];

const STAT_LIVING = 0;
const STAT_DEAD = 4;

const jobIsHead = (jobId: number) => jobId % 10 === 0;

const SORT_OPTIONS = [
  {
    name: 'Job',
    sort: (a: CrewSensor, b: CrewSensor) => {
      return a.ijob - b.ijob;
    },
  },
  {
    name: 'Name',
    sort: (a: CrewSensor, b: CrewSensor) => {
      if (a.name > b.name) return 1;
      if (a.name < b.name) return -1;
      return 0;
    },
  },
  {
    name: 'Area',
    sort: (a: CrewSensor, b: CrewSensor) => {
      if (a.area === undefined) return 1;
      if (b.area === undefined) return -1;
      if (a.area > b.area) return 1;
      if (a.area < b.area) return -1;
      return 0;
    },
  },
  {
    name: 'Vitals',
    sort: (a: CrewSensor, b: CrewSensor) => {
      if (a.life_status > b.life_status) return -1;
      if (a.life_status < b.life_status) return 1;

      if (b.oxydam === undefined) return -1;
      if (a.oxydam === undefined) return 1;

      if (a.health < b.health) return -1;
      if (a.health > b.health) return 1;

      return 0;
    },
  },
];

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
  ref: string;
  x_pos?: number;
  y_pos?: number;
  sechud_icon?: string;
};

type CrewConsoleData = {
  sensors: CrewSensor[];
  link_allowed: BooleanLike;
  has_map?: BooleanLike;
  map_image?: string;
  grid_w?: number;
  grid_h?: number;
  area_grid?: string[][];
};

export const CrewConsole = () => {
  const { act, data } = useBackend<CrewConsoleData>();
  const {
    sensors = [],
    has_map = false,
    map_image,
    grid_w,
    grid_h,
    area_grid,
  } = data;

  const hasMapBool = Boolean(has_map);
  const [hoveredRef, setHoveredRef] = useState<string | null>(null);
  const [trackedTarget, setTrackedTarget] = useState<CrewSensor | null>(null);
  const [showMap, setShowMap] = useState(hasMapBool);
  const mapVisible = hasMapBool && showMap;

  return (
    <Window title="Crew Monitor" width={mapVisible ? 1100 : 720} height={720}>
      <Window.Content>
        <Flex height="100%" gap={2}>
          <Flex.Item
            width={mapVisible ? '500px' : '100%'}
            grow={mapVisible ? 0 : 1}
            shrink={0}
            height="100%"
            style={{ overflowY: 'auto' }}
          >
            <CrewTable
              hoveredRef={hoveredRef}
              setHoveredRef={setHoveredRef}
              onTrack={(sensor) => {
                setTrackedTarget(sensor);
                if (hasMapBool && !showMap) setShowMap(true);
              }}
              hasMap={hasMapBool}
              showMap={showMap}
              setShowMap={setShowMap}
            />
          </Flex.Item>

          {mapVisible ? (
            <Flex.Item grow={1} shrink={1} height="100%">
              <StationMap
                mapImage={map_image}
                gridW={grid_w}
                gridH={grid_h}
                areaGrid={area_grid}
                targetX={trackedTarget?.x_pos}
                targetY={trackedTarget?.y_pos}
              >
                {(zoom) =>
                  sensors
                    .filter(
                      (sensor) =>
                        sensor.x_pos !== undefined &&
                        sensor.y_pos !== undefined,
                    )
                    .map((sensor) => {
                      const isHovered = hoveredRef === sensor.ref;
                      const iconScale = 1 / zoom;

                      return (
                        <div
                          key={sensor.ref}
                          onClick={(e) => {
                            e.stopPropagation();
                            act('select_person', { ref: sensor.ref });
                            setTrackedTarget(sensor);
                          }}
                          onMouseEnter={() => setHoveredRef(sensor.ref)}
                          onMouseLeave={() => setHoveredRef(null)}
                          style={{
                            position: 'absolute',
                            left: `${sensor.x_pos}%`,
                            bottom: `${sensor.y_pos}%`,
                            transform: `translate(-50%, 50%) scale(${iconScale})`,
                            transformOrigin: 'center center',
                            cursor: 'pointer',
                            zIndex: isHovered ? 20 : 2,
                          }}
                        >
                          {!!sensor.sechud_icon && (
                            <img
                              src={`data:image/png;base64,${sensor.sechud_icon}`}
                              style={{
                                display: 'block',
                                width: '16px',
                                height: '16px',
                                imageRendering: 'pixelated',
                                opacity: isHovered ? 1 : 0.85,
                                transform: isHovered
                                  ? 'scale(1.25)'
                                  : 'scale(1)',
                                transition: 'transform 0.1s ease-in-out',
                              }}
                            />
                          )}
                        </div>
                      );
                    })
                }
              </StationMap>
            </Flex.Item>
          ) : null}
        </Flex>
      </Window.Content>
    </Window>
  );
};

type CrewTableProps = {
  hoveredRef: string | null;
  setHoveredRef: (ref: string | null) => void;
  onTrack: (sensor: CrewSensor) => void;
  hasMap: boolean;
  showMap: boolean;
  setShowMap: (show: boolean) => void;
};

const CrewTable = (props: CrewTableProps) => {
  const { data } = useBackend<CrewConsoleData>();
  const { sensors = [], link_allowed } = data;
  const { hoveredRef, setHoveredRef, onTrack, hasMap, showMap, setShowMap } =
    props;

  const [sortAsc, setSortAsc] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [indexOfSortingOption, setIndexOfSortingOption] = useState(0);

  const cycleSortBy = () => {
    setIndexOfSortingOption((indexOfSortingOption + 1) % SORT_OPTIONS.length);
  };

  const nameSearch = createSearch(searchQuery, (crew: CrewSensor) => crew.name);

  const sorted = sensors
    .filter(nameSearch)
    .sort((a, b) =>
      sortAsc
        ? SORT_OPTIONS[indexOfSortingOption].sort(a, b)
        : SORT_OPTIONS[indexOfSortingOption].sort(b, a),
    );

  const trackingEnabled = Boolean(link_allowed && hasMap);

  return (
    <Section
      title={
        <>
          <Button onClick={cycleSortBy}>
            {SORT_OPTIONS[indexOfSortingOption].name}
          </Button>
          <Button onClick={() => setSortAsc(!sortAsc)}>
            <Icon
              style={{ marginLeft: '2px' }}
              name={sortAsc ? 'chevron-up' : 'chevron-down'}
            />
          </Button>
          <Input
            placeholder="Search for name..."
            onChange={setSearchQuery}
            value={searchQuery}
          />
          {hasMap ? (
            <Button
              style={{ marginLeft: '4px' }}
              icon={showMap ? 'chevron-right' : 'chevron-left'}
              tooltip={showMap ? 'Hide Map' : 'Show Map'}
              selected={showMap}
              onClick={() => setShowMap(!showMap)}
            />
          ) : null}
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
          {trackingEnabled ? (
            <Table.Cell bold collapsing textAlign="center">
              Tracking
            </Table.Cell>
          ) : null}
        </Table.Row>
        {sorted.map((sensor) => (
          <CrewTableEntry
            sensor_data={sensor}
            key={sensor.ref}
            isHovered={hoveredRef === sensor.ref}
            onMouseEnter={() => setHoveredRef(sensor.ref)}
            onMouseLeave={() => setHoveredRef(null)}
            onTrack={onTrack}
            hasMap={hasMap}
          />
        ))}
      </Table>
    </Section>
  );
};

type CrewTableEntryProps = {
  sensor_data: CrewSensor;
  isHovered: boolean;
  onMouseEnter: () => void;
  onMouseLeave: () => void;
  onTrack: (sensor: CrewSensor) => void;
  hasMap: boolean;
};

const CrewTableEntry = (props: CrewTableEntryProps) => {
  const { act, data } = useBackend<CrewConsoleData>();
  const { link_allowed } = data;
  const { sensor_data, onMouseEnter, onMouseLeave, onTrack, hasMap } = props;
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
    ref,
    x_pos,
    y_pos,
    sechud_icon,
  } = sensor_data;

  const canTrack = x_pos !== undefined && y_pos !== undefined;
  const trackingEnabled = Boolean(link_allowed && hasMap);

  return (
    <Table.Row
      className="candystripe"
      onMouseEnter={onMouseEnter}
      onMouseLeave={onMouseLeave}
    >
      <Table.Cell bold={jobIsHead(ijob)} color={jobToColor(ijob)}>
        <Flex align="center" gap={1}>
          {!!sechud_icon && (
            <img
              src={`data:image/png;base64,${sechud_icon}`}
              style={{
                width: '16px',
                height: '16px',
                imageRendering: 'pixelated',
                flexShrink: 0,
                marginRight: '6px',
              }}
            />
          )}
          <Box>
            {name}
            {assignment !== undefined ? ` (${assignment})` : ''}
          </Box>
        </Flex>
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
      {trackingEnabled ? (
        <Table.Cell collapsing>
          <Button
            disabled={!canTrack}
            onClick={() => {
              if (!canTrack) return;
              act('select_person', { ref: ref });
              onTrack(sensor_data);
            }}
          >
            Track
          </Button>
        </Table.Cell>
      ) : null}
    </Table.Row>
  );
};
