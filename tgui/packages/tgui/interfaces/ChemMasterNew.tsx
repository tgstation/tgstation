import { BooleanLike, classes } from 'common/react';
import { capitalize } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { AnimatedNumber, Box, Button, Section, Table, NumberInput, Tooltip } from '../components';
import { Window } from '../layouts';

type Data = {
  mode: BooleanLike;
  hasBeaker: BooleanLike;
  beakerCurrentVolume: number;
  beakerMaxVolume: number;
  beakerContents: Reagent[];
  bufferContents: Reagent[];
  bufferCurrentVolume: number;
  categories: Category[];
  selectedContainerId: string;
  selectedContainerVolume: number;
};

type Category = {
  name: string;
  containers: Container[];
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
    categories,
    selectedContainerVolume,
  } = data;

  const [itemCount, setItemCount] = useLocalState(context, 'itemCount', 1);

  return (
    <Window width={550} height={600}>
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
                  maxValue={10}
                  onChange={(e, value) => {
                    setItemCount(value);
                  }}
                />
                <Box inline mx={1}>
                  {`${
                    Math.round(
                      Math.min(
                        selectedContainerVolume,
                        bufferCurrentVolume / itemCount
                      ) * 100
                    ) / 100
                  } u. each`}
                </Box>
                <Button content="Create" />
              </Box>
            )
          }>
          {categories.map((category) => (
            <Box key={category.name}>
              {category.containers.map((container) => (
                // <ContainerButton key={container.id} container={container} />
                <Tooltip
                  key={container.id}
                  content={`${capitalize(container.name)}\xa0(${
                    container.volume
                  } u.)`}>
                  <Button
                    overflow="hidden"
                    color="transparent"
                    width="48px"
                    height="48px"
                    selected={container.id === data.selectedContainerId}
                    p={0}
                    onClick={() => {
                      act('selectContainer', {
                        id: container.id,
                        volume: container.volume,
                      });
                    }}>
                    <Box
                      style={{
                        'transform': ['pills', 'patches'].includes(
                          category.name
                        )
                          ? 'scale(3)'
                          : 'scale(2)',
                      }}
                      m={'8px'}
                      className={classes(['chemmaster32x32', container.id])}
                    />
                  </Button>
                </Tooltip>
              ))}
            </Box>
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
