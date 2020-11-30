import { sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { toTitleCase } from 'common/string';
import { useBackend } from '../backend';
import { Button, Section, Table } from '../components';
import { Window } from '../layouts';

/**
 * This method takes a seed string and splits the values
 * into an object
 */
const splitSeedString = text => {
  const re = /([^;=]+)=([^;]+)/g;
  const ret = {};
  let m;
  do {
    m = re.exec(text);
    if (m) {
      ret[m[1]] = m[2] + '';
    }
  } while (m);
  return ret;
};

/**
 * This method splits up the string "name" we get for the seeds
 * and creates an object from it include the value that is the
 * ammount
 *
 * @returns {any[]}
 */
const createSeeds = seedStrings => {
  const objs = Object.keys(seedStrings).map(key => {
    const obj = splitSeedString(key);
    obj.amount = seedStrings[key];
    obj.key = key;
    obj.name = toTitleCase(obj.name.replace('pack of ', ''));
    return obj;
  });
  return flow([
    sortBy(item => item.name),
  ])(objs);
};

export const SeedExtractor = (props, context) => {
  const { act, data } = useBackend(context);
  const seeds = createSeeds(data.seeds);
  return (
    <Window
      width={1000}
      height={400}
      resizable>
      <Window.Content scrollable>
        <Section title="Stored seeds:">
          <Table cellpadding="3" textAlign="center">
            <Table.Row header>
              <Table.Cell>Name</Table.Cell>
              <Table.Cell>Lifespan</Table.Cell>
              <Table.Cell>Endurance</Table.Cell>
              <Table.Cell>Maturation</Table.Cell>
              <Table.Cell>Production</Table.Cell>
              <Table.Cell>Yield</Table.Cell>
              <Table.Cell>Potency</Table.Cell>
              <Table.Cell>Instability</Table.Cell>
              <Table.Cell>Stock</Table.Cell>
            </Table.Row>
            {seeds.map(item => (
              <Table.Row key={item.key}>
                <Table.Cell bold>{item.name}</Table.Cell>
                <Table.Cell>{item.lifespan}</Table.Cell>
                <Table.Cell>{item.endurance}</Table.Cell>
                <Table.Cell>{item.maturation}</Table.Cell>
                <Table.Cell>{item.production}</Table.Cell>
                <Table.Cell>{item.yield}</Table.Cell>
                <Table.Cell>{item.potency}</Table.Cell>
                <Table.Cell>{item.instability}</Table.Cell>
                <Table.Cell>
                  <Button
                    content="Vend"
                    onClick={() => act('select', {
                      item: item.key,
                    })} />
                  ({item.amount} left)
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
};
