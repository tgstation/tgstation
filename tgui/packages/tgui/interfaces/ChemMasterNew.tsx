import { BooleanLike } from 'common/react';
import { useBackend } from '../backend';
import { AnimatedNumber, Box, Button, Section, Table } from '../components';
import { Window } from '../layouts';

type Data = {
  mode: BooleanLike;
  hasBeaker: BooleanLike;
  beakerCurrentVolume: number;
  beakerMaxVolume: number;
  beakerContents: Reagent[];
  bufferContents: Reagent[];
};

type Reagent = {
  id: number;
  name: string;
  volume: number;
};

export const ChemMasterNew = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const {
    mode,
    hasBeaker,
    beakerCurrentVolume,
    beakerMaxVolume,
    beakerContents,
    bufferContents,
  } = data;
  return (
    <Window width={400} height={600}>
      <Window.Content scrollable>
        <Section
          title="Beaker"
          buttons={
            !!hasBeaker && (
              <Box>
                <Box inline color="label" mr={2}>
                  <AnimatedNumber value={beakerCurrentVolume} initial={0} />
                  {` / ${beakerMaxVolume} units`}
                </Box>
                <Button
                  icon="eject"
                  content="Eject"
                  onClick={() => act('eject')}
                />
              </Box>
            )
          }>
          {!hasBeaker && (
            <Box color="label" my={'4px'}>
              No beaker loaded.
            </Box>
          )}
          {!!hasBeaker && beakerCurrentVolume === 0 && (
            <Box color="label" my={'4px'}>
              Beaker is empty.
            </Box>
          )}
          <Table>
            {beakerContents.map((chemical) => (
              <ReagentEntry
                key={chemical.id}
                chemical={chemical}
                transferTo="buffer"
              />
            ))}
          </Table>
        </Section>

        <Section
          title="Buffer"
          buttons={
            <>
              <Box inline color="label" mr={1}>
                Mode:
              </Box>
              <Button
                color={mode ? 'good' : 'bad'}
                icon={mode ? 'exchange-alt' : 'times'}
                content={mode ? 'Transfer' : 'Destroy'}
                onClick={() => act('toggleMode')}
              />
            </>
          }>
          {bufferContents.length === 0 && (
            <Box color="label" my={'4px'}>
              Buffer is empty.
            </Box>
          )}
          <Table>
            {bufferContents.map((chemical) => (
              <ReagentEntry
                key={chemical.id}
                chemical={chemical}
                transferTo="beaker"
              />
            ))}
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
};

const ReagentEntry = (props, context) => {
  const { act } = useBackend(context);
  const { chemical, transferTo } = props;
  return (
    <Table.Row key={chemical.id}>
      <Table.Cell color="label">
        {`${chemical.name} `}
        <AnimatedNumber value={chemical.volume} initial={0} />
        {`u.`}
      </Table.Cell>
      <Table.Cell collapsing>
        <Button
          content="1"
          onClick={() =>
            act('transfer', {
              reagentId: chemical.id,
              amount: 1,
              target: transferTo,
            })
          }
        />
        <Button
          content="5"
          onClick={() =>
            act('transfer', {
              reagentId: chemical.id,
              amount: 5,
              target: transferTo,
            })
          }
        />
        <Button
          content="10"
          onClick={() =>
            act('transfer', {
              reagentId: chemical.id,
              amount: 10,
              target: transferTo,
            })
          }
        />
        <Button
          content="All"
          onClick={() =>
            act('transfer', {
              reagentId: chemical.id,
              amount: 1000,
              target: transferTo,
            })
          }
        />
        <Button
          icon="ellipsis-h"
          title="Custom amount"
          onClick={() =>
            act('transfer', {
              reagentId: chemical.id,
              amount: -1,
              target: transferTo,
            })
          }
        />
        <Button
          icon="question"
          title="Analyze"
          onClick={() =>
            act('analyze', {
              reagentId: chemical.id,
            })
          }
        />
      </Table.Cell>
    </Table.Row>
  );
};
