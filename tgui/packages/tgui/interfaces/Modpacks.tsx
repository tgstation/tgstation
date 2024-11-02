// THIS IS A MASSMETA UI FILE

import { useBackend } from '../backend';
import { Button, Table } from '../components';
import { Window } from '../layouts';

type Modpack = {
  name: string;
  desc: string;
  author: string;
};

type Data = {
  modpacks: Modpack[];
};

export const Modpacks = (props) => {
  const { act, data } = useBackend<Data>();
  const { modpacks } = data;

  return (
    <Window title="Список модификаций" width={480} height={580}>
      <Window.Content scrollable>
	    <Table>
		  {modpacks.map(([name, desc, author]) => (
		    <Table.Row key={name} className="candystripe">
              <Table.Cell bold>{name}</Table.Cell>
              <Table.Cell>({desc})</Table.Cell>
              <Table.Cell>({author})</Table.Cell>
            </Table.Row>
          ))}
		</Table>
      </Window.Content>
    </Window>
  );
};
