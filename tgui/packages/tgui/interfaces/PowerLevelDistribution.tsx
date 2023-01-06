import { range } from 'common/collections';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, ProgressBar, Stack } from '../components';
import { Window } from '../layouts';
import { logger } from '../logging';

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
type PowerBarCounts = Record<DepartmentName, number>;

type PowerLevelDistributionData = {
  available_power_bars: number;
  can_fully_deplete: boolean;
  department_allocations: DepartmentAllocations;
  max_power_bars: number;
  time_to_distribute: number;
  time_to_next_distribution: number;
};

const limitAllocations = (
  departmentAllocations: DepartmentAllocations,
  available_power_bars: number
): [PowerBarCounts, PowerBarCounts] => {
  const sortedAllocationEntries: [number, DepartmentName][] = [];

  for (const [department, allocations] of Object.entries(
    departmentAllocations
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

const DepartmentEntry = (
  {
    name,
    hoveredAllocations,
    hover,
    unhover,
  }: {
    name: DepartmentName;
    hoveredAllocations: number | undefined;
    hover: (allocations: number) => void;
    unhover: () => void;
  },
  context
) => {
  const { act, data } = useBackend<PowerLevelDistributionData>(context);

  const [usedAllocations, excessAllocations] = limitAllocations(
    data.department_allocations,
    data.available_power_bars
  );

  const totalUsedBars = Object.values(usedAllocations).reduce(
    (sum, value) => sum + value
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
        }}>
        <legend
          style={{
            'font-size': '16px',
            'font-weight': 'bold',
          }}>
          {name.toUpperCase()}
        </legend>

        <Stack vertical fill height="96%">
          {range(0, data.max_power_bars).map((_, index) => {
            // Clicking on the top power bar will deplete it
            let allocationsIfClicked =
              totalPowerBars === data.max_power_bars - index
                ? totalPowerBars - 1
                : data.max_power_bars - index;

            if (allocationsIfClicked === 0 && !data.can_fully_deplete) {
              allocationsIfClicked = 1;
            }

            const wouldBeExcess =
              data.max_power_bars - index - usedPowerBars + totalUsedBars >
              data.available_power_bars;

            return (
              <Stack.Item key={index} grow width="100%">
                <Button
                  width="100%"
                  height="100%"
                  style={{
                    border:
                      totalPowerBars >= data.max_power_bars - index &&
                      `5px inset ${USED_POWER_BAR_COLOR}`,
                  }}
                  backgroundColor={
                    data.max_power_bars - index >
                    (hoveredAllocations ?? totalPowerBars)
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
                        allocations: allocationsIfClicked,
                      });
                    }
                  }}
                  onMouseEnter={() => {
                    hover(allocationsIfClicked);
                  }}
                  onMouseLeave={() => unhover()}
                />
              </Stack.Item>
            );
          })}
        </Stack>
      </fieldset>
    </Stack.Item>
  );
};

export const PowerLevelDistribution = (props, context) => {
  const { act, data } = useBackend<PowerLevelDistributionData>(context);

  const [allHoveredAllocations, setHoveredAllocations] = useLocalState<
    | {
        name: DepartmentName;
        allocations: number;
      }
    | undefined
  >(context, 'hovered_allocations', undefined);

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
    data.available_power_bars
  );

  const usedPowerBars = Object.values(usedAllocations).reduce(
    (sum, value) => sum + value,
    0
  );

  return (
    <Window title="Power Level Distribution Console" width={990} height={510}>
      <Window.Content>
        <Stack vertical fill>
          {/* MBTODO: Hovering over this area (not the bars) should tell you what is giving what */}
          {/* MBTODO: With the laser thing, show the bars as a special effect */}
          <Stack.Item height="18px">
            <Stack fill align="space-evenly">
              <Stack.Item grow>
                {range(0, usedPowerBars).map((_, i) => (
                  <PowerBarDisplay color={USED_POWER_BAR_COLOR} key={i} />
                ))}

                {range(0, data.available_power_bars - usedPowerBars).map(
                  (_, i) => (
                    <PowerBarDisplay color={UNUSED_POWER_BAR_COLOR} key={i} />
                  )
                )}

                {/* MBTODO: Show excess */}
              </Stack.Item>

              <Stack.Item width="25%">
                {data.time_to_next_distribution && (
                  <ProgressBar
                    value={data.time_to_next_distribution}
                    maxValue={data.time_to_distribute}
                    fillPosition="right">
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
                  DepartmentName.Engineering
                )}
                name={DepartmentName.Engineering}
                hover={createHover(DepartmentName.Engineering)}
                unhover={unhover}
              />

              <DepartmentEntry
                hoveredAllocations={getHoveredAllocations(
                  DepartmentName.Medical
                )}
                name={DepartmentName.Medical}
                hover={createHover(DepartmentName.Medical)}
                unhover={unhover}
              />

              <DepartmentEntry
                hoveredAllocations={getHoveredAllocations(
                  DepartmentName.Science
                )}
                name={DepartmentName.Science}
                hover={createHover(DepartmentName.Science)}
                unhover={unhover}
              />

              <DepartmentEntry
                hoveredAllocations={getHoveredAllocations(
                  DepartmentName.Security
                )}
                name={DepartmentName.Security}
                hover={createHover(DepartmentName.Security)}
                unhover={unhover}
              />

              <DepartmentEntry
                hoveredAllocations={getHoveredAllocations(
                  DepartmentName.Common
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
