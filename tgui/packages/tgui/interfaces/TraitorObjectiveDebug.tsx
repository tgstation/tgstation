import { useState } from 'react';
import { Box, LabeledList, Stack, Tabs, Tooltip } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { getDangerLevel } from './Uplink/calculateDangerLevel';

type Objective = {
  name: string;
  description: string;
  progression_minimum: number;
  progression_maximum: number;
  global_progression_limit_coeff: number;
  global_progression_influence_intensity: number;
  progression_reward: [number, number];
  telecrystal_reward: [number, number];
  telecrystal_penalty: number;
  weight: number;
  type: string;
};

type ObjectiveList = {
  objectives: (ObjectiveList | Objective)[];
  weight: number;
};

type ObjectiveCategory = ObjectiveList & {
  name: string;
};

type PlayerData = {
  player: string;
  progression_points: number;
  total_progression_from_objectives: number;
};

type ObjectiveData = {
  current_progression: number;
  objective_data: ObjectiveCategory[];
  player_data: PlayerData[];
};

const recursivelyGetObjectives = (value: ObjectiveList) => {
  let listToReturn: Objective[] = [];
  for (let i = 0; i < value.objectives.length; i++) {
    const possibleValue = value.objectives[i];
    if ((possibleValue as ObjectiveList).objectives) {
      listToReturn = listToReturn.concat(
        recursivelyGetObjectives(possibleValue as ObjectiveList),
      );
    } else {
      listToReturn.push(possibleValue as Objective);
    }
  }
  return listToReturn;
};

// 150 minutes
const sizeLimit = 90000;

type SortingOption = {
  name: string;
  // Function used to determine the order of the elements.
  // It is expected to return a negative value
  // if first argument is less than second argument,
  // zero if they're equal and a positive value otherwise.
  sort: (a: Objective, b: Objective) => number;
};

const sortingOptions: SortingOption[] = [
  {
    name: 'Minimum Progression',
    sort: (a, b) => {
      if (a.progression_minimum < b.progression_minimum) {
        return -1;
      } else if (a.progression_minimum === b.progression_minimum) {
        return 0;
      }
      return 1;
    },
  },
  {
    name: 'Telecrystal Payout',
    sort: (a, b) => {
      const telecrystalMeanA =
        (a.telecrystal_reward[0] + a.telecrystal_reward[1]) / 2;
      const telecrystalMeanB =
        (b.telecrystal_reward[0] + b.telecrystal_reward[1]) / 2;
      if (telecrystalMeanA < telecrystalMeanB) {
        return -1;
      } else if (telecrystalMeanA === telecrystalMeanB) {
        return 0;
      }
      return 1;
    },
  },
  {
    name: 'Progression Payout',
    sort: (a, b) => {
      const progressionMeanA =
        (a.progression_reward[0] + a.progression_reward[1]) / 2;
      const progressionMeanB =
        (b.progression_reward[0] + b.progression_reward[1]) / 2;
      if (progressionMeanA < progressionMeanB) {
        return -1;
      } else if (progressionMeanA === progressionMeanB) {
        return 0;
      }
      return 1;
    },
  },
  {
    name: 'Progression Payout + Min. Prog.',
    sort: (a, b) => {
      const progressionMeanA =
        (a.progression_reward[0] + a.progression_reward[1]) / 2 +
        a.progression_minimum;
      const progressionMeanB =
        (b.progression_reward[0] + b.progression_reward[1]) / 2 +
        b.progression_minimum;
      if (progressionMeanA < progressionMeanB) {
        return -1;
      } else if (progressionMeanA === progressionMeanB) {
        return 0;
      }
      return 1;
    },
  },
];

export const TraitorObjectiveDebug = (props) => {
  const { data, act } = useBackend<ObjectiveData>();
  const { objective_data, player_data, current_progression } = data;
  const lines: JSX.Element[] = [];
  lines.sort();
  for (let i = 10; i < 100; i += 10) {
    lines.push(
      <Box
        position="absolute"
        height="100%"
        top={0}
        left={`${i}%`}
        width="2px"
        backgroundColor="green"
      >
        <Box
          position="absolute"
          top={0}
          left={0}
          width="2px"
          backgroundColor="green"
          height="5px"
          style={{
            zIndex: '5',
          }}
        />
        <Box
          position="absolute"
          top={0}
          left={1}
          style={{
            zIndex: '5',
          }}
        >
          {/* Time in minutes of this threshold */}
          {Math.round((sizeLimit * (i / 100)) / 600)} mins
        </Box>
      </Box>,
    );
  }
  let objectivesToRender: Objective[] = [];
  const [currentTab, setCurrentTab] = useState('All');
  const [sortingFunc, setSortingFunc] = useState(sortingOptions[0].name);
  // true = ascending, false = descending
  const [sortDirection, setSortingDirection] = useState(true);

  let actualSortingFunc;
  for (let index = 0; index < sortingOptions.length; index++) {
    const value = sortingOptions[index];
    if (value.name === sortingFunc) {
      actualSortingFunc = value.sort;
    }
  }

  for (let index = 0; index < objective_data.length; index++) {
    const value = objective_data[index];
    if (value.name !== currentTab && currentTab !== 'All') {
      continue;
    }
    objectivesToRender = objectivesToRender.concat(
      recursivelyGetObjectives(value),
    );
  }

  objectivesToRender.sort(actualSortingFunc);
  if (!sortDirection) {
    objectivesToRender.reverse();
  }

  return (
    <Window width={1000} height={1000} theme="admin">
      <Window.Content scrollable>
        <Box position="absolute" height="100px" width="100%" top={0} left={0}>
          <Stack vertical>
            <Stack.Item>
              <Tabs width="100%" fluid textAlign="center">
                {sortingOptions.map((value) => (
                  <Tabs.Tab
                    key={value.name}
                    selected={value.name === sortingFunc}
                    onClick={() => setSortingFunc(value.name)}
                  >
                    {value.name}
                  </Tabs.Tab>
                ))}
              </Tabs>
            </Stack.Item>
            <Stack.Item>
              <Tabs height="100%" width="100%" fluid textAlign="center">
                <Tabs.Tab
                  selected={currentTab === 'All'}
                  onClick={() => setCurrentTab('All')}
                >
                  All
                </Tabs.Tab>
                {objective_data.map((value) => (
                  <Tabs.Tab
                    key={value.name}
                    selected={value.name === currentTab}
                    onClick={() => setCurrentTab(value.name)}
                  >
                    {value.name}
                  </Tabs.Tab>
                ))}
              </Tabs>
            </Stack.Item>
            <Stack.Item>
              <Tabs width="100%" fluid textAlign="center">
                <Tabs.Tab
                  selected={sortDirection === true}
                  onClick={() => setSortingDirection(true)}
                >
                  Ascending
                </Tabs.Tab>
                <Tabs.Tab
                  selected={sortDirection === false}
                  onClick={() => setSortingDirection(false)}
                >
                  Descending
                </Tabs.Tab>
              </Tabs>
            </Stack.Item>
          </Stack>
        </Box>
        <Box
          position="absolute"
          width="100%"
          backgroundColor="black"
          left={0}
          top="100px"
        >
          {lines}
          <Stack vertical mt={8}>
            {objectivesToRender.map((value, index) => (
              <Stack.Item key={index} position="relative" basis="100px">
                <ObjectiveBox objective={value} />
              </Stack.Item>
            ))}
          </Stack>
          {player_data.map((value) => {
            const rep = getDangerLevel(value.progression_points);
            return (
              <Tooltip
                key={value.player}
                content={
                  <Box>
                    <LabeledList>
                      <LabeledList.Item label={'Key'}>
                        {value.player}
                      </LabeledList.Item>
                      <LabeledList.Item label={'Total PR'}>
                        {Math.floor(value.progression_points / 600)} mins
                      </LabeledList.Item>
                      <LabeledList.Item label={'Obj PR'}>
                        {Math.floor(
                          value.total_progression_from_objectives / 600,
                        )}{' '}
                        mins
                      </LabeledList.Item>
                    </LabeledList>
                  </Box>
                }
                position="top"
              >
                <Box
                  backgroundColor="red"
                  position="absolute"
                  left={`${
                    (value.progression_points / sizeLimit) * window.innerWidth
                  }px`}
                  width="3px"
                  height="100%"
                  top={0}
                  opacity={0.8}
                >
                  <Box
                    position="absolute"
                    top={0}
                    left="-50px"
                    width="100px"
                    height="100%"
                  />
                </Box>
              </Tooltip>
            );
          })}
          <Tooltip
            content={`Expected Progression: ${Math.floor(
              current_progression / 600,
            )} mins`}
            position="top"
          >
            <Box
              position="absolute"
              left={`${
                (current_progression / sizeLimit) * window.innerWidth
              }px`}
              width="3px"
              height="100%"
              top={0}
              opacity={1}
              backgroundColor="pink"
            >
              <Box
                position="absolute"
                top={0}
                left="-50px"
                width="100px"
                height="100%"
              />
            </Box>
          </Tooltip>
        </Box>
      </Window.Content>
    </Window>
  );
};

type ObjectiveBoxProps = {
  objective: Objective;
};

const ObjectiveBox = (props: ObjectiveBoxProps) => {
  const { objective } = props;
  let width = `${
    (objective.progression_maximum / sizeLimit) * window.innerWidth
  }px`;
  if (objective.progression_maximum > sizeLimit) {
    width = '100%';
  }
  return (
    <Box
      backgroundColor="grey"
      position="absolute"
      left={`${
        (objective.progression_minimum / sizeLimit) * window.innerWidth
      }px`}
      width={width}
      height="95px"
    >
      <Stack vertical width="100%">
        <Stack.Item
          style={{
            textOverflow: 'ellipsis',
            whiteSpace: 'nowrap',
            overflow: 'hidden',
          }}
        >
          {objective.name}
        </Stack.Item>
        <Stack.Item>
          <Stack>
            <Stack.Item grow>
              {objective.progression_minimum / 600} mins
            </Stack.Item>
            {objective.progression_maximum <= sizeLimit && (
              <Stack.Item>
                {objective.progression_maximum / 600} mins
              </Stack.Item>
            )}
          </Stack>
        </Stack.Item>
        <Stack.Item position="relative" basis="18px">
          <Box
            position="absolute"
            left={0}
            height="100%"
            backgroundColor="green"
            width={`${
              (objective.progression_reward[1] / sizeLimit) * window.innerWidth
            }px`}
            style={{
              whiteSpace: 'nowrap',
            }}
          >
            {objective.progression_reward[0] / 600}
            &nbsp;to {objective.progression_reward[1] / 600} pr
          </Box>
        </Stack.Item>
        <Stack.Item position="relative" basis="18px">
          <Box
            position="absolute"
            left={0}
            height="100%"
            backgroundColor="red"
            width={`${objective.telecrystal_reward[1] * 10}px`}
            style={{
              whiteSpace: 'nowrap',
            }}
          >
            {objective.telecrystal_reward[0]}
            &nbsp;to {objective.telecrystal_reward[1]} tc
          </Box>
        </Stack.Item>
      </Stack>
    </Box>
  );
};
