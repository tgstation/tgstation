import { sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { toTitleCase } from 'common/string';
import { useBackend } from '../backend';
import { Tooltip, Box, ProgressBar, Button, Section, Table } from '../components';
import { Window } from '../layouts';

/**
 * This method takes a seed string and splits the values
 * into an object
 */
const splitSeedString = (text) => {
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
const createSeeds = (seedStrings) => {
  const objs = Object.keys(seedStrings).map((key) => {
    const obj = splitSeedString(key);
    obj.amount = seedStrings[key];
    obj.key = key;
    obj.name = toTitleCase(obj.name.replace('pack of ', ''));
    return obj;
  });
  return flow([sortBy((item) => item.name)])(objs);
};

export const SeedExtractor = (props, context) => {
  const { act, data } = useBackend(context);
  const seeds = createSeeds(data.seeds);
  return (
    <Window width={1000} height={400}>
      <Window.Content scrollable>
        <Section>
          <Table>
            <Table.Row header>
              <Table.Cell />
              <Table.Cell collapsing p={1}>
                <Tooltip
                  content={
                    'Determines the mass of a single product, its volume and potency.'
                  }
                  position="bottom-start">
                  <Box>Potency</Box>
                </Tooltip>
              </Table.Cell>
              <Table.Cell collapsing p={1}>
                <Tooltip
                  content={
                    'The number of products gathered in a single harvest.'
                  }
                  position="bottom-start">
                  <Box>Yield</Box>
                </Tooltip>
              </Table.Cell>
              <Table.Cell collapsing p={1}>
                <Tooltip
                  content={
                    'The period of product regrowt after the first harvest.'
                  }
                  position="bottom-start">
                  <Box>Instability</Box>
                </Tooltip>
              </Table.Cell>
              <Table.Cell collapsing p={1}>
                <Tooltip
                  content={
                    'The time needed for the plant for the first harvest.'
                  }
                  position="bottom-start">
                  <Box>Maturation</Box>
                </Tooltip>
              </Table.Cell>
              <Table.Cell collapsing p={1}>
                <Tooltip
                  content={
                    'The period of product regrowt after the first harvest.'
                  }
                  position="bottom-start">
                  <Box>Production</Box>
                </Tooltip>
              </Table.Cell>
              <Table.Cell collapsing p={1}>
                <Tooltip
                  content={'The age at which the plant starts taking damage.'}
                  position="bottom-start">
                  <Box>Lifespan</Box>
                </Tooltip>
              </Table.Cell>
              <Table.Cell collapsing p={1}>
                <Tooltip
                  content={'The health pool of the plant that delays death.'}
                  position="bottom-start">
                  <Box>Endurance</Box>
                </Tooltip>
              </Table.Cell>
              <Table.Cell collapsing p={1}>
                Amount
              </Table.Cell>
              <Table.Cell collapsing />
            </Table.Row>
            {seeds.map((item) => (
              <Table.Row
                key={item.key}
                style={{ 'border-top': '2px solid #222' }}>
                <Table.Cell p={0.5} pl={1} pr={1}>
                  {item.name}
                </Table.Cell>
                <Table.Cell p={0.5} pl={1} pr={1} collapsing>
                  <Level value={item.potency} max={100} />
                </Table.Cell>
                <Table.Cell p={0.5} pl={1} pr={1} collapsing>
                  <Level value={item.yield} max={10} />
                </Table.Cell>
                <Table.Cell p={0.5} pl={1} pr={1} collapsing>
                  <Level value={item.instability} max={100} reverse />
                </Table.Cell>
                <Table.Cell p={0.5} pl={1} pr={1} collapsing>
                  {item.maturation} ({item.maturation * 20}s)
                </Table.Cell>
                <Table.Cell p={0.5} pl={1} pr={1} collapsing>
                  {item.production} ({item.production * 20}s)
                </Table.Cell>
                <Table.Cell p={0.5} pl={1} pr={1} collapsing>
                  {item.lifespan} ({item.lifespan * 20}s)
                </Table.Cell>
                <Table.Cell p={0.5} pl={1} pr={1} collapsing>
                  <Level value={item.endurance} max={100} />
                </Table.Cell>
                <Table.Cell p={0.5} pl={1} pr={1} collapsing>
                  <Box textAlign="right">{item.amount}</Box>
                </Table.Cell>
                <Table.Cell p={0.5} pl={1} pr={1} collapsing>
                  <Button
                    content="Take"
                    onClick={() =>
                      act('select', {
                        item: item.key,
                      })
                    }
                  />
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
};

const Level = (props) => {
  return (
    <ProgressBar
      value={props.value}
      maxValue={props.max}
      ranges={
        props.reverse
          ? {
            good: [0, props.max * 0.2],
            average: [props.max * 0.2, props.max * 0.6],
            bad: [props.max * 0.6, props.max],
          }
          : {
            bad: [0, props.max * 0.2],
            good: [props.max * 0.8, props.max],
          }
      }>
      <span
        style={{
          'text-shadow': '1px 1px 0 black',
        }}>
        {props.value}
      </span>
    </ProgressBar>
  );
};
