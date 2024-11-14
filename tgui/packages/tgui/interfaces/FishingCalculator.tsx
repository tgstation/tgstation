import { useState } from 'react';
import { Button, Dropdown, Input, Stack, Table } from 'tgui-core/components';
import { round } from 'tgui-core/math';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type FishCalculatorEntry = {
  result: string;
  weight: number;
  difficulty: number;
  count: string;
};

type FishingCalculatorData = {
  info: FishCalculatorEntry[] | null;
  hook_types: string[];
  rod_types: string[];
  line_types: string[];
  spot_types: string[];
};

export const FishingCalculator = (props) => {
  const { act, data } = useBackend<FishingCalculatorData>();

  const [bait, setBait] = useState('/obj/item/food/bait/worm');
  const [spot, setSpot] = useState(data.spot_types[0]);
  const [rod, setRod] = useState(data.rod_types[0]);
  const [hook, setHook] = useState(data.hook_types[0]);
  const [line, setLine] = useState(data.line_types[0]);

  const weight_sum = data.info?.reduce((s, w) => s + w.weight, 0) || 1;

  return (
    <Window width={500} height={500}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Dropdown
              options={data.spot_types}
              selected={spot}
              onSelected={(e) => setSpot(e)}
              width="100%"
            />
            <Dropdown
              options={data.rod_types}
              selected={rod}
              onSelected={(e) => setRod(e)}
              width="100%"
            />
            <Dropdown
              options={data.hook_types}
              selected={hook}
              onSelected={(e) => setHook(e)}
              width="100%"
            />
            <Dropdown
              options={data.line_types}
              selected={line}
              onSelected={(e) => setLine(e)}
              width="100%"
            />
            <Input
              value={bait}
              placeholder="Bait"
              onChange={(_, value) => setBait(value)}
              width="100%"
            />
            <Button
              onClick={() =>
                act('recalc', {
                  rod: rod,
                  bait: bait,
                  hook: hook,
                  line: line,
                  spot: spot,
                })
              }
            >
              Calculate
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Table>
              <Table.Row header>
                <Table.Cell>Outcome</Table.Cell>
                <Table.Cell>Weight</Table.Cell>
                <Table.Cell>Probabilty</Table.Cell>
                <Table.Cell>Difficulty</Table.Cell>
                <Table.Cell>Count</Table.Cell>
              </Table.Row>
              {data.info?.map((result) => (
                <Table.Row key={result.result}>
                  <Table.Cell>{result.result}</Table.Cell>
                  <Table.Cell>{result.weight}</Table.Cell>
                  <Table.Cell>
                    {round((result.weight / weight_sum) * 100, 2)}%
                  </Table.Cell>
                  <Table.Cell>{result.difficulty}</Table.Cell>
                  <Table.Cell>{result.count}</Table.Cell>
                </Table.Row>
              ))}
            </Table>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
