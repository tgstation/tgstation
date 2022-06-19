import { round } from 'common/math';
import { useBackend, useLocalState } from '../backend';
import { Button, Dropdown, Input, Stack, Table } from '../components';
import { TableCell, TableRow } from '../components/Table';
import { Window } from '../layouts';

type FishCalculatorEntry = {
  result: string,
  weight: number,
  difficulty: number,
  count: string,
}

type FishingCalculatorData = {
  info : FishCalculatorEntry[] | null,
  hook_types: string[],
  rod_types: string[],
  line_types: string[],
  spot_types: string[]
}

export const FishingCalculator = (props, context) => {
  const { act, data } = useBackend<FishingCalculatorData>(context);

  const [bait, setBait] = useLocalState<string>(context, "bait", "/obj/item/food/bait/worm");
  const [spot, setSpot] = useLocalState<string>(context, "spot", data.spot_types[0]);
  const [rod, setRod] = useLocalState<string>(context, "rod", data.rod_types[0]);
  const [hook, setHook] = useLocalState<string>(context, "hook", data.hook_types[0]);
  const [line, setLine] = useLocalState<string>(context, "line", data.line_types[0]);

  const weight_sum = data.info?.reduce((s, w) => s + w.weight, 0) || 1;

  return (
    <Window
      width={500}
      height={500}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Dropdown
              options={data.spot_types}
              selected={spot}
              onSelected={e => setSpot(e)} width="100%" />
            <Dropdown
              options={data.rod_types}
              selected={rod}
              onSelected={e => setRod(e)} width="100%" />
            <Dropdown
              options={data.hook_types}
              selected={hook}
              onSelected={e => setHook(e)} width="100%" />
            <Dropdown
              options={data.line_types}
              selected={line}
              onSelected={e => setLine(e)} width="100%" />
            <Input value={bait} label="Bait" onChange={(_, value) => setBait(value)} width="100%" />
            <Button onClick={() => act("recalc", { "rod": rod, "bait": bait, "hook": hook, "line": line, "spot": spot })}>Calculate</Button>
          </Stack.Item>
          <Stack.Item>
            <Table>
              <TableRow header>
                <TableCell>Outcome</TableCell>
                <TableCell>Weight</TableCell>
                <TableCell>Probabilty</TableCell>
                <TableCell>Difficulty</TableCell>
                <TableCell>Count</TableCell>
              </TableRow>
              {data.info?.map(result => (
                <TableRow key={result.result}>
                  <TableCell>{result.result}</TableCell>
                  <TableCell>{result.weight}</TableCell>
                  <TableCell>
                    {round(result.weight / weight_sum * 100, 2) }%
                  </TableCell>
                  <TableCell>{result.difficulty}</TableCell>
                  <TableCell>{result.count}</TableCell>
                </TableRow>))}
            </Table>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
