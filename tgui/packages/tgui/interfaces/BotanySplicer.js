import { toFixed } from 'common/math';
import { useBackend } from '../backend';
import { Box, Button, Flex, LabeledList, NoticeBox, Section, Table } from '../components';
import { Window } from '../layouts';

export const TimeFormat = (props, context) => {
  const { value } = props;

  const seconds = toFixed(Math.floor((value / 10) % 60)).padStart(2, '0');
  const minutes = toFixed(Math.floor((value / (10 * 60)) % 60)).padStart(
    2,
    '0'
  );
  const hours = toFixed(Math.floor((value / (10 * 60 * 60)) % 24)).padStart(
    2,
    '0'
  );
  const formattedValue = `${hours}:${minutes}:${seconds}`;
  return formattedValue;
};

export const InsertedSeedOne = (props, context) => {
  const { act, data } = useBackend(context);
  const { seedone, working } = data;
  const seed_1 = data.seed_1 || [];
  if (!seedone) {
    return !working && <NoticeBox info>Please insert a seed.</NoticeBox>;
  }
  return (
    <Section
      title="Seed Number One"
      buttons={
        <Button
          icon="eject"
          disabled={!!working}
          onClick={() => act('eject_seed_one')}
          content="Eject Seed"
        />
      }>
      {!seed_1.length && 'No Seed detected.'}
      {!!seed_1.length && (
        <Table>
          {seed_1.map((node) => (
            <Table.Row key={node.ref}>
              <Table.Cell collapsing>
                <img
                  src={`data:image/jpeg;base64,${node.image}`}
                  style={{
                    'vertical-align': 'middle',
                    'horizontal-align': 'middle',
                  }}
                />
              </Table.Cell>
              <Table.Cell>{node.name}</Table.Cell>
              <LabeledList>
                <LabeledList.Item label="Potency">
                  <Box>{node.potency}</Box>
                </LabeledList.Item>
                <LabeledList.Item label="Yield">
                  <Box>{node.yield}</Box>
                </LabeledList.Item>
                <LabeledList.Item label="Production Speed">
                  <Box>{node.production_speed}</Box>
                </LabeledList.Item>
                <LabeledList.Item label="Maturation Speed">
                  <Box>{node.maturation_speed}</Box>
                </LabeledList.Item>
                <LabeledList.Item label="Endurance">
                  <Box>{node.endurance}</Box>
                </LabeledList.Item>
                <LabeledList.Item label="Lifespan">
                  <Box>{node.lifespan}</Box>
                </LabeledList.Item>
                <LabeledList.Item label="Weed Rate">
                  <Box>{node.weed_rate}</Box>
                </LabeledList.Item>
                <LabeledList.Item label="Weed Chance">
                  <Box>{node.weed_chance}</Box>
                </LabeledList.Item>
              </LabeledList>
              <Table.Cell />
            </Table.Row>
          ))}
        </Table>
      )}
    </Section>
  );
};
export const InsertedSeedTwo = (props, context) => {
  const { act, data } = useBackend(context);
  const { seedtwo, working } = data;
  const seed_2 = data.seed_2 || [];
  if (!seedtwo) {
    return !working && <NoticeBox info>Please insert a seed.</NoticeBox>;
  }
  return (
    <Section
      title="Seed Number Two"
      buttons={
        <Button
          icon="eject"
          disabled={!!working}
          onClick={() => act('eject_seed_two')}
          content="Eject Seed"
        />
      }>
      {!seed_2.length && 'No Seed detected.'}
      {!!seed_2.length && (
        <Table>
          {seed_2.map((node) => (
            <Table.Row key={node.ref}>
              <Table.Cell collapsing>
                <img
                  src={`data:image/jpeg;base64,${node.image}`}
                  style={{
                    'vertical-align': 'middle',
                    'horizontal-align': 'middle',
                  }}
                />
              </Table.Cell>
              <Table.Cell>{node.name}</Table.Cell>
              <LabeledList>
                <LabeledList.Item label="Potency">
                  <Box>{node.potency}</Box>
                </LabeledList.Item>
                <LabeledList.Item label="Yield">
                  <Box>{node.yield}</Box>
                </LabeledList.Item>
                <LabeledList.Item label="Production Speed">
                  <Box>{node.production_speed}</Box>
                </LabeledList.Item>
                <LabeledList.Item label="Maturation Speed">
                  <Box>{node.maturation_speed}</Box>
                </LabeledList.Item>
                <LabeledList.Item label="Endurance">
                  <Box>{node.endurance}</Box>
                </LabeledList.Item>
                <LabeledList.Item label="Lifespan">
                  <Box>{node.lifespan}</Box>
                </LabeledList.Item>
                <LabeledList.Item label="Weed Rate">
                  <Box>{node.weed_rate}</Box>
                </LabeledList.Item>
                <LabeledList.Item label="Weed Chance">
                  <Box>{node.weed_chance}</Box>
                </LabeledList.Item>
              </LabeledList>
              <Table.Cell />
            </Table.Row>
          ))}
        </Table>
      )}
    </Section>
  );
};

export const SpliceButton = (props, context) => {
  const { act, data } = useBackend(context);
  const { working, seedone, seedtwo } = data;
  return (
    <Button
      width="380px"
      height="20px"
      icon="eject"
      disabled={!!working && !seedone && !seedtwo}
      onClick={() => act('splice')}
      color="green"
      textAlign="center"
      align-content="center"
      content="Splice Seeds"
    />
  );
};
export const BotanySplicer = (props, context) => {
  const { data } = useBackend(context);
  const { working, timeleft, error } = data;
  return (
    <Window title="Plant Splicer" width={390} height={505}>
      <Window.Content>
        {!!error && <NoticeBox>{error}</NoticeBox>}
        {!!working && (
          <NoticeBox danger>
            <Flex direction="column">
              <Flex.Item mb={0.5}>Operation in progress.</Flex.Item>
              <Flex.Item>
                Time Left: <TimeFormat value={timeleft} />
              </Flex.Item>
            </Flex>
          </NoticeBox>
        )}
        <InsertedSeedOne />
        <InsertedSeedTwo />
        <SpliceButton />
      </Window.Content>
    </Window>
  );
};
