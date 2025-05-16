import { BooleanLike, Button, ProgressBar, Table } from 'tgui-core/components';

import { useBackend } from '../backend';

type GeneratorStats = {
  name: string;
  id: number;
  max_strength: number;
  current_strength: number;
  active: BooleanLike;
  recovering: BooleanLike;
};

type ModularShieldConsoleData = {
  stats: GeneratorStats[];
};

const GeneratorTable = () => {
  return (
    <Table>
      <Table.Row>
        <Table.Cell bold>Name</Table.Cell>
        <Table.Cell bold collapsing />
        <Table.Cell bold collapsing textAlign="center">
          Status
        </Table.Cell>
        <Table.Cell bold textAlign="center">
          Toggle
        </Table.Cell>
      </Table.Row>
    </Table>
  );
};

type GeneratorTableEntryProps = {
  generator_data: GeneratorStats;
};

const GeneratorTableEntry = (props: GeneratorTableEntryProps) => {
  const { act, data } = useBackend<ModularShieldConsoleData>();
  const { generator_data } = props;
  const { name, id, max_strength, current_strength, active, recovering } =
    generator_data;

  return (
    <Table.Row className="candystripe">
      <Table.Cell>
        {id}
        {name}
      </Table.Cell>
      <Table.Cell collapsing textAlign="center">
        <ProgressBar
          value={current_strength}
          maxValue={max_strength}
          ranges={{
            good: [max_strength * 0.75, max_strength],
            average: [max_strength * 0.25, max_strength * 0.75],
            bad: [0, max_strength * 0.25],
          }}
        >
          {current_strength}/{max_strength}
        </ProgressBar>
      </Table.Cell>
      <Table.Cell collapsing textAlign="center" />
      <Table.Cell>
        <Button
          bold
          disabled={recovering}
          selected={active}
          content={active ? 'On' : 'Off'}
          icon="power-off"
          onClick={() => act('toggle_shields')}
        />
      </Table.Cell>
    </Table.Row>
  );
};
