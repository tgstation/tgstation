import { BooleanLike, classes } from 'common/react';
import { capitalize } from 'common/string';
import { useState } from 'react';

import { useBackend } from '../backend';
import {
  AnimatedNumber,
  Box,
  Button,
  ColorBox,
  Divider,
  LabeledList,
  NumberInput,
  ProgressBar,
  Section,
  Stack,
  Table,
  Tooltip,
} from '../components';
import { Window } from '../layouts';

type Data = {
  reagentAnalysisMode: BooleanLike;
  analysisData: Analysis;
  isPrinting: BooleanLike;
  printingProgress: number;
  printingTotal: number;
  transferMode: BooleanLike;
  hasBeaker: BooleanLike;
  beakerCurrentVolume: number;
  beakerMaxVolume: number;
  beakerContents: Reagent[];
  bufferContents: Reagent[];
  bufferCurrentVolume: number;
  bufferMaxVolume: number;
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
  purity: number;
  metaRate: number;
  overdose: number;
  addictionTypes: string[];
};

type Category = {
  name: string;
  containers: Container[];
};

type Reagent = {
  ref: string;
  name: string;
  volume: number;
};

type Container = {
  icon: string;
  ref: string;
  name: string;
  volume: number;
};

export const ChemMaster = (props) => {
  const { data } = useBackend<Data>();
  const { reagentAnalysisMode } = data;
  return (
    <Window width={400} height={620}>
      <Window.Content scrollable>
        {reagentAnalysisMode ? <AnalysisResults /> : <ChemMasterContent />}
      </Window.Content>
    </Window>
  );
};

const ChemMasterContent = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    isPrinting,
    printingProgress,
    printingTotal,
    transferMode,
    hasBeaker,
    beakerCurrentVolume,
    beakerMaxVolume,
    beakerContents,
    bufferContents,
    bufferCurrentVolume,
    bufferMaxVolume,
    categories,
    selectedContainerVolume,
    hasContainerSuggestion,
    doSuggestContainer,
    suggestedContainer,
  } = data;

  const [itemCount, setItemCount] = useState(1);

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
        }
      >
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
              key={chemical.ref}
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
              <AnimatedNumber value={bufferCurrentVolume} initial={0} />
              {` / ${bufferMaxVolume} units`}
            </Box>
            <Button
              color={transferMode ? 'good' : 'bad'}
              icon={transferMode ? 'exchange-alt' : 'trash'}
              content={transferMode ? 'Moving reagents' : 'Destroying reagents'}
              onClick={() => act('toggleTransferMode')}
            />
          </>
        }
      >
        {bufferContents.length === 0 && (
          <Box color="label" my={'4px'}>
            Buffer is empty.
          </Box>
        )}
        <Table>
          {bufferContents.map((chemical) => (
            <ReagentEntry
              key={chemical.ref}
              chemical={chemical}
              transferTo="beaker"
            />
          ))}
        </Table>
      </Section>
      {!isPrinting && (
        <Section
          title="Packaging"
          buttons={
            bufferContents.length !== 0 &&
            (!isPrinting ? (
              <Box>
                <NumberInput
                  unit={'items'}
                  step={1}
                  value={itemCount}
                  minValue={1}
                  maxValue={50}
                  onChange={(e, value) => {
                    setItemCount(value);
                  }}
                />
                <Box inline mx={1}>
                  {`${
                    Math.round(
                      Math.min(
                        selectedContainerVolume,
                        bufferCurrentVolume / itemCount,
                      ) * 100,
                    ) / 100
                  } u. each`}
                </Box>
                <Button
                  content="Print"
                  icon="flask"
                  onClick={() =>
                    act('create', {
                      itemCount: itemCount,
                    })
                  }
                />
              </Box>
            ) : (
              <Button content="Printing..." icon="gear" iconSpin disabled />
            ))
          }
        >
          {!!hasContainerSuggestion && (
            <Button.Checkbox
              onClick={() => act('toggleContainerSuggestion')}
              checked={doSuggestContainer}
              mb={1}
            >
              Guess container by main reagent in the buffer
            </Button.Checkbox>
          )}
          {categories.map((category) => (
            <Box key={category.name}>
              <GroupTitle title={category.name} />
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
                  ),
              )}
            </Box>
          ))}
        </Section>
      )}
      {!!isPrinting && (
        <Section
          title="Printing"
          buttons={
            <Button
              color="bad"
              icon="times"
              content="Stop"
              onClick={() => act('stopPrinting')}
            />
          }
        >
          <ProgressBar
            value={printingProgress}
            minValue={0}
            maxValue={printingTotal}
            color="good"
          >
            <Box
              lineHeight={1.9}
              style={{
                textShadow: '1px 1px 0 black',
              }}
            >
              {`Printing ${printingProgress} out of ${printingTotal}`}
            </Box>
          </ProgressBar>
        </Section>
      )}
    </Box>
  );
};

const ReagentEntry = (props) => {
  const { data, act } = useBackend<Data>();
  const { chemical, transferTo } = props;
  const { isPrinting } = data;
  return (
    <Table.Row key={chemical.ref}>
      <Table.Cell color="label">
        {`${chemical.name} `}
        <AnimatedNumber value={chemical.volume} initial={0} />
        {`u`}
      </Table.Cell>
      <Table.Cell collapsing>
        <Button
          content="1"
          disabled={isPrinting}
          onClick={() => {
            act('transfer', {
              reagentRef: chemical.ref,
              amount: 1,
              target: transferTo,
            });
          }}
        />
        <Button
          content="5"
          disabled={isPrinting}
          onClick={() =>
            act('transfer', {
              reagentRef: chemical.ref,
              amount: 5,
              target: transferTo,
            })
          }
        />
        <Button
          content="10"
          disabled={isPrinting}
          onClick={() =>
            act('transfer', {
              reagentRef: chemical.ref,
              amount: 10,
              target: transferTo,
            })
          }
        />
        <Button
          content="All"
          disabled={isPrinting}
          onClick={() =>
            act('transfer', {
              reagentRef: chemical.ref,
              amount: 1000,
              target: transferTo,
            })
          }
        />
        <Button
          icon="ellipsis-h"
          title="Custom amount"
          disabled={isPrinting}
          onClick={() =>
            act('transfer', {
              reagentRef: chemical.ref,
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
              reagentRef: chemical.ref,
            })
          }
        />
      </Table.Cell>
    </Table.Row>
  );
};

const ContainerButton = ({ container, category }) => {
  const { act, data } = useBackend<Data>();
  const { isPrinting, selectedContainerRef } = data;
  const isPillPatch = ['pills', 'patches'].includes(category.name);
  return (
    <Tooltip
      key={container.ref}
      content={`${capitalize(container.name)}\xa0(${container.volume}u)`}
    >
      <Button
        overflow="hidden"
        color="transparent"
        width={isPillPatch ? '32px' : '48px'}
        height={isPillPatch ? '32px' : '48px'}
        selected={container.ref === selectedContainerRef}
        disabled={isPrinting}
        p={0}
        onClick={() => {
          act('selectContainer', {
            ref: container.ref,
          });
        }}
      >
        <Box
          m={isPillPatch ? '0' : '8px'}
          style={{
            transform: 'scale(2)',
          }}
          className={classes(['chemmaster32x32', container.icon])}
        />
      </Button>
    </Tooltip>
  ) as any;
};

const AnalysisResults = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    name,
    state,
    pH,
    color,
    description,
    purity,
    metaRate,
    overdose,
    addictionTypes,
  } = data.analysisData;
  const purityLevel =
    purity <= 0.5 ? 'bad' : purity <= 0.75 ? 'average' : 'good'; // Color names
  return (
    <Section
      title="Analysis Results"
      buttons={
        <Button
          icon="arrow-left"
          content="Back"
          onClick={() => act('stopAnalysis')}
        />
      }
    >
      <LabeledList>
        <LabeledList.Item label="Name">{name}</LabeledList.Item>
        <LabeledList.Item label="Purity">
          <Box
            style={{
              textTransform: 'capitalize',
            }}
            color={purityLevel}
          >
            {purityLevel}
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label="pH">{pH}</LabeledList.Item>
        <LabeledList.Item label="State">{state}</LabeledList.Item>
        <LabeledList.Item label="Color">
          <ColorBox color={color} mr={1} />
          {color}
        </LabeledList.Item>
        <LabeledList.Item label="Description">{description}</LabeledList.Item>
        <LabeledList.Item label="Metabolization Rate">
          {metaRate} units/second
        </LabeledList.Item>
        <LabeledList.Item label="Overdose Threshold">
          {overdose > 0 ? `${overdose} units` : 'N/A'}
        </LabeledList.Item>
        <LabeledList.Item label="Addiction Types">
          {addictionTypes.length ? addictionTypes.toString() : 'N/A'}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const GroupTitle = ({ title }) => {
  return (
    <Stack my={1}>
      <Stack.Item grow>
        <Divider />
      </Stack.Item>
      <Stack.Item
        style={{
          textTransform: 'capitalize',
        }}
        color={'gray'}
      >
        {title}
      </Stack.Item>
      <Stack.Item grow>
        <Divider />
      </Stack.Item>
    </Stack>
  ) as any;
};
