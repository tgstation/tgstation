import { BooleanLike, classes } from 'common/react';
import { capitalize } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { AnimatedNumber, Box, Button, Section, Table, NumberInput, Tooltip, LabeledList, ColorBox } from '../components';
import { Window } from '../layouts';

type Data = {
  reagentAnalysisMode: BooleanLike;
  analysisData: Analysis;
  transferMode: BooleanLike;
  hasBeaker: BooleanLike;
  beakerCurrentVolume: number;
  beakerMaxVolume: number;
  beakerContents: Reagent[];
  bufferContents: Reagent[];
  bufferCurrentVolume: number;
  categories: Category[];
  selectedContainerRef: string;
  selectedContainerVolume: number;
  hasContainerSuggestion: BooleanLike;
  doSuggestContainer: BooleanLike;
  suggestedContainer: string;
};

type Analysis = {
  name: string;
  state: string;
  pH: number;
  color: string;
  description: string;
  metaRate: number;
  overdose: number;
  addictionTypes: number;
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
  icon: string;
  ref: string;
  name: string;
  volume: number;
};

export const ChemMasterNew = (props, context) => {
  const { data } = useBackend<Data>(context);
  const { reagentAnalysisMode } = data;
  return (
    <Window width={400} height={600}>
      <Window.Content scrollable>
        {reagentAnalysisMode ? <AnalysisResults /> : <ChemMasterContent />}
      </Window.Content>
    </Window>
  );
};

const ChemMasterContent = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const {
    transferMode,
    hasBeaker,
    beakerCurrentVolume,
    beakerMaxVolume,
    beakerContents,
    bufferContents,
    bufferCurrentVolume,
    categories,
    selectedContainerVolume,
    hasContainerSuggestion,
    doSuggestContainer,
    suggestedContainer,
  } = data;

  const [itemCount, setItemCount] = useLocalState(context, 'itemCount', 1);

  return (
    <Box>
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
              Transfer mode:
            </Box>
            <Button
              color={transferMode ? 'good' : 'bad'}
              icon={transferMode ? 'exchange-alt' : 'times'}
              content={transferMode ? 'Transfer' : 'Destroy'}
              onClick={() => act('toggleTransferMode')}
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
              <Button
                content="Create"
                onClick={() =>
                  act('create', {
                    itemCount: itemCount,
                  })
                }
              />
            </Box>
          )
        }>
        {!!hasContainerSuggestion && (
          <Button.Checkbox
            onClick={() => act('toggleContainerSuggestion')}
            checked={doSuggestContainer}
            mb={1}>
            Guess container by main reagent in the buffer
          </Button.Checkbox>
        )}
        {categories.map((category) => (
          <Box key={category.name}>
            {category.containers.map(
              (container) =>
                (!hasContainerSuggestion || // Doesn't have suggestion
                  (!!hasContainerSuggestion && !doSuggestContainer) || // Has sugestion and it's disabled
                  (!!doSuggestContainer &&
                    container.ref === suggestedContainer)) && ( // Suggestion enabled and container matches
                  <ContainerButton
                    key={container.ref}
                    category={category}
                    container={container}
                  />
                )
            )}
          </Box>
        ))}
      </Section>
    </Box>
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
        {`u`}
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
              id: chemical.id,
            })
          }
        />
      </Table.Cell>
    </Table.Row>
  );
};

const ContainerButton = ({ container, category }, context) => {
  const { act, data } = useBackend<Data>(context);
  const { selectedContainerRef } = data;
  const isPillPatch = ['pills', 'patches'].includes(category.name);
  return (
    <Tooltip
      key={container.ref}
      content={`${capitalize(container.name)}\xa0(${container.volume}u)`}>
      <Button
        overflow="hidden"
        color="transparent"
        width={isPillPatch ? '32px' : '48px'}
        height={isPillPatch ? '32px' : '48px'}
        selected={container.ref === selectedContainerRef}
        p={0}
        onClick={() => {
          act('selectContainer', {
            ref: container.ref,
          });
        }}>
        <Box
          m={isPillPatch ? '0' : '8px'}
          style={{
            'transform': 'scale(2)',
          }}
          className={classes(['chemmaster32x32', container.icon])}
        />
      </Button>
    </Tooltip>
  ) as any;
};

const AnalysisResults = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { analysisData } = data;
  return (
    <Section
      title="Analysis Results"
      buttons={
        <Button
          icon="arrow-left"
          content="Back"
          onClick={() => act('stopAnalysis')}
        />
      }>
      <LabeledList>
        <LabeledList.Item label="Name">{analysisData.name}</LabeledList.Item>
        <LabeledList.Item label="State">{analysisData.state}</LabeledList.Item>
        <LabeledList.Item label="pH">{analysisData.pH}</LabeledList.Item>
        <LabeledList.Item label="Color">
          <ColorBox color={analysisData.color} mr={1} />
          {analysisData.color}
        </LabeledList.Item>
        <LabeledList.Item label="Description">
          {analysisData.description}
        </LabeledList.Item>
        <LabeledList.Item label="Metabolization Rate">
          {analysisData.metaRate} units/second
        </LabeledList.Item>
        <LabeledList.Item label="Overdose Threshold">
          {analysisData.overdose > 0 ? `${analysisData.overdose} units` : 'N/A'}
        </LabeledList.Item>
        <LabeledList.Item label="Addiction Types">
          {analysisData.addictionTypes}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
