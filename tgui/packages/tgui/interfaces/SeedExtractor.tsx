import { classes } from 'common/react';
import { createSearch } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Input, Tooltip, Box, ProgressBar, Button, Section, Table, NoticeBox } from '../components';
import { Window } from '../layouts';

type SeedExtractorData = {
  seeds: SeedData[];
  cycle: number;
};

type SeedData = {
  key: string;
  amount: number;
  name: string;
  lifespan: number;
  endurance: number;
  maturation: number;
  production: number;
  yield: number;
  potency: number;
  instability: number;
  icon: string;
};

export const SeedExtractor = (props, context) => {
  const { act, data } = useBackend<SeedExtractorData>(context);
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');
  const search = createSearch(searchText, (item: string) => item);
  // const seeds = filterSeedList(data.seeds, search);
  const seeds = data.seeds;
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
                  content={`The age at which the plant starts decaying, in ${data.cycle} second long cycles.`}
                  position="bottom-start">
                  <Box>Lifespan</Box>
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
                    <Level value={item.lifespan} max={100} />
                  </Table.Cell>
                  <Table.Cell py={0.5} px={1} collapsing>
                    <Box textAlign="right">{item.maturation}</Box>
                  </Table.Cell>
                  <Table.Cell py={0.5} px={1} collapsing>
                    <Box textAlign="right">{item.production}</Box>
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
