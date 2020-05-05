import { useBackend } from '../backend';
import { Box, Button, Flex, Section, Table } from '../components';
import { Window } from '../layouts';
import { createLogger } from '../logging';
import { sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { toTitleCase } from 'common/string';


const logger = createLogger('SeedExtractor');


/**
 * This method takes a seed string and splits the values
 * into an object
 *
 * @returns {any{}}
 */
const split_seed_string = text => {
  const re = /([^;=]+)=([^;]+)/g;
  let ret = {};
  let m;
  do {
    m = re.exec(text);
    if (m) { ret[m[1]] = m[2]+""; }
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
  let objs = [];
  Object.keys(seedStrings).forEach(key => {
    let o = split_seed_string(key);
    o.amount = seedStrings[key];
    o.key = key;
    objs.push(o);
    o.name = o.name.replace("pack of ", "").toTitleCase();
  });
  return flow([
    sortBy(item => item.name),
  ])(objs);
};

export const SeedExtractor = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    seeds,
  } = data;
  // / I  don't know why, but map dosn't work with this
  return (
    <Window resizable>
      <Window.Content scrollable>
        <Section title="Stored seeds:">
          <Table cellpadding="3" textAlign="center">
            <Table.Row>
              <Table.Cell>Name</Table.Cell>
              <Table.Cell >Lifespan</Table.Cell>
              <Table.Cell >Endurance</Table.Cell>
              <Table.Cell >Maturation</Table.Cell>
              <Table.Cell >Production</Table.Cell>
              <Table.Cell >Yield</Table.Cell>
              <Table.Cell >Potency</Table.Cell>
              <Table.Cell >Instability</Table.Cell>
              <Table.Cell >Stock</Table.Cell>
            </Table.Row>
            {createSeeds(seeds).map(item => (
              <Table.Row key={item.key}>
                <Table.Cell bold>{item.name}</Table.Cell>
                <Table.Cell >{item.lifespan}</Table.Cell>
                <Table.Cell >{item.endurance}</Table.Cell>
                <Table.Cell >{item.maturation}</Table.Cell>
                <Table.Cell >{item.production}</Table.Cell>
                <Table.Cell >{item.yield}</Table.Cell>
                <Table.Cell >{item.potency}</Table.Cell>
                <Table.Cell >{item.instability}</Table.Cell>
                <Table.Cell>
                  <Button
                    content="Vend"
                    onClick={() => act('select', { item: item.key })}
                  />
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
