import { sortBy } from 'common/collections';
import { createSearch } from 'common/string';
import { classes } from 'common/react';
import { flow } from 'common/fp';
import { toTitleCase } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Input, Tooltip, Box, ProgressBar, Button, Section, Table, NoticeBox } from '../components';
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
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');
  const search = createSearch(searchText, (item) => {
    return item.name;
  });
  const seed_data = createSeeds(data.seeds);
  const seeds = searchText.length > 0 ? seed_data.filter(search) : seed_data;
  return (
    <Window width={1000} height={400}>
      <Window.Content scrollable>
        <Section>
          <Table>
            <Table.Row header>
              <Table.Cell colspan="2" p={1}>
                <Input
                  autoFocus
                  placeholder={'Search...'}
                  value={searchText}
                  onInput={(e, value) => setSearchText(value)}
                  fluid
                />
              </Table.Cell>
              <Table.Cell collapsing p={1}>
                <Tooltip
                  content={
                    'Determines product mass, reagent volume and strength of effects.'
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
                    'The likelihood of the plant to randomize stats or mutate.'
                  }
                  position="bottom-start">
                  <Box>Instability</Box>
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
                <Tooltip
                  content={`The age required for the first harvest, in ${data.cycle} second long cycles.`}
                  position="bottom-start">
                  <Box>Maturation</Box>
                </Tooltip>
              </Table.Cell>
              <Table.Cell collapsing p={1}>
                <Tooltip
                  content={`The period of product regrowth, in ${data.cycle} second long cycles.`}
                  position="bottom-start">
                  <Box>Production</Box>
                </Tooltip>
              </Table.Cell>
              <Table.Cell collapsing p={1}>
                <Tooltip
                  content={`The age at which the plant starts decaying, in ${data.cycle} second long cycles.`}
                  position="bottom-start">
                  <Box>Lifespan</Box>
                </Tooltip>
              </Table.Cell>
              <Table.Cell collapsing p={1}>
                Amount
              </Table.Cell>
              <Table.Cell collapsing />
            </Table.Row>
            {seeds.length > 0 &&
              seeds.map((item) => (
                <Table.Row
                  key={item.key}
                  style={{ 'border-top': '2px solid #222' }}>
                  <Table.Cell collapsing>
                    <Box
                      mb={-2}
                      className={classes(['seeds32x32', item.icon])}
                    />
                  </Table.Cell>
                  <Table.Cell py={0.5} px={1}>
                    {item.name}
                  </Table.Cell>
                  <Table.Cell py={0.5} px={1} collapsing>
                    <Level value={item.potency} max={100} />
                  </Table.Cell>
                  <Table.Cell py={0.5} px={1} collapsing>
                    <Level value={item.yield} max={10} />
                  </Table.Cell>
                  <Table.Cell py={0.5} px={1} collapsing>
                    <Level value={item.instability} max={100} reverse />
                  </Table.Cell>
                  <Table.Cell py={0.5} px={1} collapsing>
                    <Level value={item.endurance} max={100} />
                  </Table.Cell>
                  <Table.Cell py={0.5} px={1} collapsing>
                    <Box textAlign="right">{item.maturation}</Box>
                  </Table.Cell>
                  <Table.Cell py={0.5} px={1} collapsing>
                    <Box textAlign="right">{item.production}</Box>
                  </Table.Cell>
                  <Table.Cell py={0.5} px={1} collapsing>
                    <Box textAlign="right">{item.lifespan}</Box>
                  </Table.Cell>
                  <Table.Cell py={0.5} px={1} collapsing>
                    <Box textAlign="right">{item.amount}</Box>
                  </Table.Cell>
                  <Table.Cell py={0.5} px={1} collapsing>
                    <Button
                      icon="eject"
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
          {seeds.length === 0 && (
            <NoticeBox m={1} p={1}>
              No seeds found.
            </NoticeBox>
          )}
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
