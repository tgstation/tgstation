import { BooleanLike, classes } from 'common/react';
import { capitalize } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { AnimatedNumber, Box, Button, Section, Table, Tooltip, Tabs, NumberInput } from '../components';
import { Window } from '../layouts';

type Data = {
  mode: BooleanLike;
  hasBeaker: BooleanLike;
  beakerCurrentVolume: number;
  beakerMaxVolume: number;
  beakerContents: Reagent[];
  bufferContents: Reagent[];
  bufferCurrentVolume: number;
  containers: Container[];
  selectedContainerId: string;
  selectedContainerVolume: number;
};

type Reagent = {
  id: number;
  name: string;
  volume: number;
};

type Container = {
  id: string;
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
    bufferCurrentVolume,
    containers,
    selectedContainerVolume,
  } = data;

  const [itemCount, setItemCount] = useLocalState(context, 'itemCount', 1);
  const [selectedVolume, setSelectedVolume] = useLocalState(
    context,
    'selectedVolume',
    1
  );
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
        <Section
          title="Packaging"
          buttons={
            bufferContents.length !== 0 && (
              <Box>
                <NumberInput
                  unit={'items'}
                  step={1}
                  value={itemCount}
                  minValue={1}
                  maxValue={100}
                  onChange={(e, value) => {
                    setItemCount(value);
                    setSelectedVolume(Math.floor(bufferCurrentVolume / value));
                  }}
                />
                <NumberInput
                  unit={'u. each'}
                  step={1}
                  value={selectedVolume}
                  minValue={1}
                  maxValue={selectedContainerVolume}
                  onChange={(e, value) => {
                    setSelectedVolume(value);
                    setItemCount(
                      Math.min(100, Math.ceil(bufferCurrentVolume / value))
                    );
                  }}
                />
                <Button ml={1} content="Create" />
              </Box>
            )
          }>
          <Tabs fluid>
            {['Containers', 'Pills', 'Patches'].map((category) => (
              <Tabs.Tab
                align="center"
                key={category}
                selected={category === 'Containers'}
                onClick={() => ''}>
                {category}
              </Tabs.Tab>
            ))}
          </Tabs>
          {containers.map((container) => (
            // <ContainerButton key={container.id} container={container} />
            <Tooltip
              key={container.id}
              content={`${capitalize(container.name)}\xa0(${
                container.volume
              } u.)`}>
              <Button
                color="transparent"
                width="32px"
                height="32px"
                selected={container.id === data.selectedContainerId}
                p={0}
                onClick={() => {
                  setSelectedVolume(container.volume);
                  setItemCount(
                    Math.min(
                      100,
                      Math.ceil(data.bufferCurrentVolume / container.volume)
                    )
                  );
                  act('selectContainer', {
                    id: container.id,
                    volume: container.volume,
                  });
                }}>
                <Box className={classes(['chemmaster32x32', container.id])} />
              </Button>
            </Tooltip>
          ))}
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
        {` u.`}
      </Table.Cell>
      <Table.Cell collapsing>
        <Button
          content="1"
          onClick={() => {
            act('transfer', {
              reagentId: chemical.id,
              amount: 1,
              target: transferTo,
            });
          }}
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

// const ContainerButton = ({ container }, context) => {
//   const { act, data } = useBackend<Data>(context);
//   return (
//     <Tooltip
//       content={`${capitalize(container.name)}\xa0(${container.volume}u)`}>
//       <Button
//         color="transparent"
//         width="32px"
//         height="32px"
//         selected={container.id === data.selectedContainerId}
//         p={0}
//         onClick={() => {
//           context.setSelectedVolume(container.volume);
//           context.setItemCount(
//             Math.min(
//               100,
//               Math.ceil(data.bufferCurrentVolume / container.volume)
//             )
//           );
//           act('selectContainer', {
//             id: container.id,
//             volume: container.volume,
//           });
//         }}>
//         <Box className={classes(['chemmaster32x32', container.id])} />
//       </Button>
//     </Tooltip>
//   ) as any;
// };
