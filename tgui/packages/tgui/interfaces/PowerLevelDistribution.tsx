import { range } from 'es-toolkit';
import { Fragment } from 'react';
import {
  Box,
  Button,
  NoticeBox,
  ProgressBar,
  Stack,
  Tooltip,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { useBackend, useSharedState } from '../backend';
import { Window } from '../layouts';

const UNUSED_POWER_BAR_COLOR = 'rgba(255, 184, 0, 0.2)';
const USED_POWER_BAR_COLOR = 'rgba(255, 184, 0, 0.7)';

enum DepartmentName {
  Common = 'common',
  Cargo = 'cargo',
  Engineering = 'engineering',
  Medical = 'medical',
  Science = 'science',
  Security = 'security',
}

type DepartmentAllocations = Record<DepartmentName, number[]>;
type PowerBarAllocations = Record<string, number>;
type PowerBarCounts = Record<DepartmentName, number>;

type PowerLevelDistributionData = {
  all_details: Record<DepartmentName, null | UpgradesForTier>;
  available_power_bars: PowerBarAllocations;
  can_fully_deplete: BooleanLike;
  department_allocations: DepartmentAllocations;
  has_access: BooleanLike;
  max_power_bars: number;
  time_to_distribute: number;
  time_to_next_distribution: number;
};

type UpgradesForTier = {
  direct_upgrades: string[];
  additional_upgrades: string[];
};

const sumAllocations = (allocations: PowerBarAllocations): number =>
  Object.values(allocations).reduce((sum, value) => sum + value, 0);

const limitAllocations = (
  departmentAllocations: DepartmentAllocations,
  available_power_bars: number,
): [PowerBarCounts, PowerBarCounts] => {
  const sortedAllocationEntries: [number, DepartmentName][] = [];

  for (const [department, allocations] of Object.entries(
    departmentAllocations,
  )) {
    for (const time of allocations) {
      sortedAllocationEntries.push([time, department as DepartmentName]);
    }
  }

  sortedAllocationEntries.sort((a, b) => a[0] - b[0]);

  const newAllocations = {} as PowerBarCounts;
  const excessAllocations = {} as PowerBarCounts;

  for (let index = 0; index < sortedAllocationEntries.length; index++) {
    const [, department] = sortedAllocationEntries[index];

    if (index < available_power_bars) {
      newAllocations[department] = (newAllocations[department] ?? 0) + 1;
    } else {
      excessAllocations[department] = (excessAllocations[department] ?? 0) + 1;
    }
  }

  return [newAllocations, excessAllocations];
};

const PowerBarDisplay = (props: { color: string }) => {
  return (
    <Box
      className="PowerLevelDistribution__PowerBarDisplay"
      style={{
        display: 'inline-block',
      }}
      mr="3px"
      backgroundColor={props.color}
      height="100%"
      width="12px"
    />
  );
};

const PowerBarTotal = ({
  availablePowerBars,
  usedPowerBars,
  excess,
}: {
  availablePowerBars: PowerBarAllocations;
  usedPowerBars: number;
  excess: number;
}) => {
  return (
    <Tooltip
      content={Object.entries(availablePowerBars).map(([source, count]) => (
        <Fragment key={source}>
          <b>{source}:</b> +{count}
          <br />
        </Fragment>
      ))}
      position="bottom-start"
    >
      <Stack.Item>
        {range(0, usedPowerBars).map((_, i) => (
          <PowerBarDisplay color={USED_POWER_BAR_COLOR} key={i} />
        ))}

        {range(0, sumAllocations(availablePowerBars) - usedPowerBars).map(
          (_, i) => (
            <PowerBarDisplay color={UNUSED_POWER_BAR_COLOR} key={i} />
          ),
        )}

        {range(0, excess).map((_, i) => (
          <PowerBarDisplay color={'red'} key={i} />
        ))}
      </Stack.Item>
    </Tooltip>
  );
};

const UpgradeDetails = ({
  details: { direct_upgrades, additional_upgrades },
}: {
  details: UpgradesForTier;
}) => {
  const additionalUpgradeText = additional_upgrades.map((upgrade, index) => (
    <li key={index}>{upgrade}</li>
  ));

  return (
    <Box>
      Upgrading gets you better machinery in the department, as well as...
      {direct_upgrades.length > 0 && (
        <ul>
          {direct_upgrades.map((upgrade, index) => (
            <li key={index}>{upgrade}</li>
          ))}
        </ul>
      )}
      {additional_upgrades.length > 0 &&
        (direct_upgrades.length > 0 ? (
          <Box fontSize="9px">
            <b>plus, from the previous tier...</b>
            <ul>{additionalUpgradeText}</ul>
          </Box>
        ) : (
          <ul>{additionalUpgradeText}</ul>
        ))}
    </Box>
  );
};

type DepartmentEntryProps = {
  name: DepartmentName;
  hoveredAllocations: number | undefined;
  hover: (allocations: number) => void;
  unhover: () => void;
};

const DepartmentEntry = (props: DepartmentEntryProps) => {
  const { act, data } = useBackend<PowerLevelDistributionData>();
  const { name, hoveredAllocations, hover, unhover } = props;

  const [usedAllocations, excessAllocations] = limitAllocations(
    data.department_allocations,
    sumAllocations(data.available_power_bars),
  );

  const totalUsedBars = Object.values(usedAllocations).reduce(
    (sum, value) => sum + value,
    0,
  );

  const [usedPowerBars, excessPowerBars] = [
    usedAllocations[name] ?? 0,
    excessAllocations[name] ?? 0,
  ];

  const totalPowerBars = usedPowerBars + excessPowerBars;

  return (
    <Stack.Item grow height="100%">
      <fieldset
        style={{
          height: '100%',
        }}
      >
        <legend
          style={{
            fontSize: '16px',
            fontWeight: 'bold',
          }}
        >
          {name.toUpperCase()}
        </legend>

        <Stack vertical fill height="96%">
          {range(0, data.max_power_bars).map((_, index) => {
            const tier = data.max_power_bars - index;
            const wouldBeExcess =
              tier - usedPowerBars + totalUsedBars >
              sumAllocations(data.available_power_bars);

            const details = data.all_details[name]?.[tier - 1];

            return (
              <Stack.Item key={index} grow width="100%">
                <Button
                  width="100%"
                  height="100%"
                  style={{
                    border:
                      totalPowerBars >= tier
                        ? `5px inset ${USED_POWER_BAR_COLOR}`
                        : undefined,
                  }}
                  backgroundColor={
                    tier > (hoveredAllocations ?? totalPowerBars)
                      ? UNUSED_POWER_BAR_COLOR
                      : // Red if it is excess
                        wouldBeExcess
                        ? 'rgba(255, 0, 0, 0.7)'
                        : USED_POWER_BAR_COLOR
                  }
                  onClick={() => {
                    if (!wouldBeExcess) {
                      act('set_department_power', {
                        department: name,
                        allocations: tier,
                      });
                    }
                  }}
                  onMouseEnter={() => {
                    hover(tier);
                  }}
                  onMouseLeave={() => unhover()}
                  tooltip={
                    details ? <UpgradeDetails details={details} /> : null
                  }
                />
              </Stack.Item>
            );
          })}

          <Stack.Item>
            <Button
              align="center"
              width="100%"
              fontSize="15px"
              disabled={!data.can_fully_deplete}
              color="bad"
              tooltip={
                data.can_fully_deplete
                  ? ''
                  : 'The CE can fully drain a department'
              }
              tooltipPosition="top"
              onClick={() => {
                act('set_department_power', {
                  department: name,
                  allocations: 0,
                });
              }}
            >
              Drain
            </Button>
          </Stack.Item>
        </Stack>
      </fieldset>
    </Stack.Item>
  );
};

export const PowerLevelDistribution = (props, context) => {
  const { act, data } = useBackend<PowerLevelDistributionData>();

  const [allHoveredAllocations, setHoveredAllocations] = useSharedState<
    | {
        name: DepartmentName;
        allocations: number;
      }
    | undefined
  >('hovered_allocations', undefined);

  const getHoveredAllocations = (name: DepartmentName) => {
    return allHoveredAllocations?.name === name
      ? allHoveredAllocations?.allocations
      : undefined;
  };

  const createHover = (department: DepartmentName) => (allocations: number) => {
    setHoveredAllocations({
      name: department,
      allocations,
    });
  };

  const unhover = () => {
    setHoveredAllocations(undefined);
  };

  const [usedAllocations, excessAllocations] = limitAllocations(
    data.department_allocations,
    sumAllocations(data.available_power_bars),
  );

  const usedPowerBars = Object.values(usedAllocations).reduce(
    (sum, value) => sum + value,
    0,
  );

  return (
    <Window title="Power Level Distribution Console" width={990} height={510}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item height="18px">
            <Stack fill align="space-evenly">
              <PowerBarTotal
                availablePowerBars={data.available_power_bars}
                usedPowerBars={usedPowerBars}
                excess={sumAllocations(excessAllocations)}
              />

              <Stack.Item grow>
                {!data.has_access && (
                  <NoticeBox danger>You do not have access.</NoticeBox>
                )}
              </Stack.Item>

              <Stack.Item width="25%">
                {data.time_to_next_distribution && (
                  <ProgressBar
                    value={data.time_to_next_distribution}
                    maxValue={data.time_to_distribute}
                  >
                    {/* melbert todo : make this fill from right to left
                      if (fillPosition === 'right') {
                            fillStyles['right'] = '0px';
                            fillStyles['left'] = 'auto';
                      }
                    */}
                    {(data.time_to_next_distribution / 10).toFixed(1)}s until
                    distribution
                  </ProgressBar>
                )}
              </Stack.Item>
            </Stack>
          </Stack.Item>

          <Stack.Item grow>
            <Stack fill height="100%">
              <DepartmentEntry
                hoveredAllocations={getHoveredAllocations(DepartmentName.Cargo)}
                name={DepartmentName.Cargo}
                hover={createHover(DepartmentName.Cargo)}
                unhover={unhover}
              />

              <DepartmentEntry
                hoveredAllocations={getHoveredAllocations(
                  DepartmentName.Engineering,
                )}
                name={DepartmentName.Engineering}
                hover={createHover(DepartmentName.Engineering)}
                unhover={unhover}
              />

              <DepartmentEntry
                hoveredAllocations={getHoveredAllocations(
                  DepartmentName.Medical,
                )}
                name={DepartmentName.Medical}
                hover={createHover(DepartmentName.Medical)}
                unhover={unhover}
              />

              <DepartmentEntry
                hoveredAllocations={getHoveredAllocations(
                  DepartmentName.Science,
                )}
                name={DepartmentName.Science}
                hover={createHover(DepartmentName.Science)}
                unhover={unhover}
              />

              <DepartmentEntry
                hoveredAllocations={getHoveredAllocations(
                  DepartmentName.Security,
                )}
                name={DepartmentName.Security}
                hover={createHover(DepartmentName.Security)}
                unhover={unhover}
              />

              <DepartmentEntry
                hoveredAllocations={getHoveredAllocations(
                  DepartmentName.Common,
                )}
                name={DepartmentName.Common}
                hover={createHover(DepartmentName.Common)}
                unhover={unhover}
              />
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
