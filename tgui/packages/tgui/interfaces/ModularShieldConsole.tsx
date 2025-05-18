import {
  Button,
  Input,
  NoticeBox,
  ProgressBar,
  Section,
  Table,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type GeneratorStats = {
  name: string;
  id: number;
  max_strength: number;
  current_strength: number;
  active: BooleanLike;
  recovering: BooleanLike;
};

type ModularShieldConsoleData = {
  generators: GeneratorStats[];
};

export const ModularShieldConsole = () => {
  const { data } = useBackend<ModularShieldConsoleData>();
  const { generators } = data;
  return (
    <Window title="Modular Shield Console" width={500} height={300}>
      <Window.Content scrollable>
        {generators.length === 0 ? (
          <NoticeBox>No Generators Connected</NoticeBox>
        ) : (
          <Section minHeight="200px">
            <GeneratorTable />
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};

const GeneratorTable = () => {
  const { data } = useBackend<ModularShieldConsoleData>();
  const { generators } = data;
  return (
    <Table>
      <Table.Row>
        <Table.Cell bold>Name</Table.Cell>
        <Table.Cell bold collapsing textAlign="center">
          Status
        </Table.Cell>
        <Table.Cell bold textAlign="center">
          Toggle
        </Table.Cell>
      </Table.Row>
      {generators.map((stat) => (
        <GeneratorTableEntry generator_data={stat} key={stat.id} />
      ))}
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
        <Input
          value={name}
          width="170px"
          onChange={(value) =>
            act('rename', {
              id: id,
              name: value,
            })
          }
        />
      </Table.Cell>
      <Table.Cell
        collapsing
        textAlign="center"
        color={recovering ? 'red' : 'white'}
      >
        <ProgressBar
          width="170px"
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
      <Table.Cell>
        <Button
          bold
          disabled={recovering}
          selected={active}
          content={active ? 'On' : 'Off'}
          icon="power-off"
          onClick={() => act('toggle_shields', { id })}
        />
      </Table.Cell>
    </Table.Row>
  );
};
