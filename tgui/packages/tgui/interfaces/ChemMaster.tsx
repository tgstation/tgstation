import { useState } from 'react';
import {
  AnimatedNumber,
  Box,
  Button,
  ColorBox,
  Divider,
  DmIcon,
  Icon,
  LabeledList,
  NumberInput,
  ProgressBar,
  Section,
  Stack,
  Table,
  Tooltip,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { capitalize } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import type { Beaker, BeakerReagent } from './common/BeakerDisplay';

type Container = {
  icon: string;
  icon_state: string;
  ref: string;
  name: string;
  volume: number;
};

type Category = {
  name: string;
  containers: Container[];
};

type AnalyzableReagent = BeakerReagent & {
  ref: string;
  pH: number;
  color: string;
  description: string;
  purity: number;
  metaRate: number;
  overdose: number;
  addictionTypes: string[];
};

type AnalyzableBeaker = {
  contents: AnalyzableReagent[];
} & Beaker;

type Data = {
  categories: Category[];
  isPrinting: BooleanLike;
  printingProgress: number;
  printingTotal: number;
  selectedPillDuration: number;
  maxPrintable: number;
  maxPillDuration: number;
  beaker: AnalyzableBeaker;
  buffer: AnalyzableBeaker;
  isTransfering: BooleanLike;
  suggestedContainerRef: string;
  selectedContainerRef: string;
  selectedContainerVolume: number;
  selectedContainerCategory?: string;
};

export const ChemMaster = (props) => {
  const [analyzedReagent, setAnalyzedReagent] = useState<AnalyzableReagent>();

  return (
    <Window width={450} height={620}>
      <Window.Content scrollable>
        {analyzedReagent ? (
          <AnalysisResults
            analysisData={analyzedReagent}
            onExit={() => setAnalyzedReagent(undefined)}
          />
        ) : (
          <ChemMasterContent
            analyze={(chemical: AnalyzableReagent) =>
              setAnalyzedReagent(chemical)
            }
          />
        )}
      </Window.Content>
    </Window>
  );
};

const ChemMasterContent = (props: {
  analyze: (chemical: AnalyzableReagent) => void;
}) => {
  const { act, data } = useBackend<Data>();
  const {
    isPrinting,
    printingProgress,
    printingTotal,
    selectedPillDuration,
    maxPrintable,
    maxPillDuration,
    isTransfering,
    beaker,
    buffer,
    categories,
    selectedContainerVolume,
    selectedContainerCategory,
  } = data;

  const [itemCount, setItemCount] = useState<number>(1);
  const [showPreferredContainer, setShowPreferredContainer] =
    useState<BooleanLike>(false);
  const buffer_contents = buffer.contents;

  return (
    <Box>
      <Section
        title="Beaker"
        buttons={
          beaker && (
            <Box>
              <Box inline color="label" mr={2}>
                <AnimatedNumber value={beaker.currentVolume} initial={0} />
                {` / ${beaker.maxVolume} units`}
              </Box>
              <Button icon="eject" onClick={() => act('eject')}>
                Eject
              </Button>
            </Box>
          )
        }
      >
        {!beaker ? (
          <Box color="label" my={'4px'}>
            No beaker loaded.
          </Box>
        ) : beaker.currentVolume === 0 ? (
          <Box color="label" my={'4px'}>
            Beaker is empty.
          </Box>
        ) : (
          <Table>
            {beaker.contents.map((chemical) => (
              <ReagentEntry
                key={chemical.ref}
                chemical={chemical}
                transferTo="buffer"
                analyze={props.analyze}
              />
            ))}
          </Table>
        )}
      </Section>
      <Section
        title="Buffer"
        buttons={
          <>
            <Box inline color="label" mr={1}>
              <AnimatedNumber value={buffer.currentVolume} initial={0} />
              {` / ${buffer.maxVolume} units`}
            </Box>
            <Button
              color={isTransfering ? 'good' : 'bad'}
              icon={isTransfering ? 'exchange-alt' : 'trash'}
              onClick={() => act('toggleTransferMode')}
            >
              {isTransfering ? 'Moving reagents' : 'Destroying reagents'}
            </Button>
          </>
        }
      >
        {buffer_contents.length === 0 ? (
          <Box color="label" my={'4px'}>
            Buffer is empty.
          </Box>
        ) : (
          <Table>
            {buffer_contents.map((chemical) => (
              <ReagentEntry
                key={chemical.ref}
                chemical={chemical}
                transferTo="beaker"
                analyze={props.analyze}
              />
            ))}
          </Table>
        )}
      </Section>
      {!isPrinting && (
        <Section
          title="Packaging"
          buttons={
            buffer_contents.length !== 0 && (
              <Box>
                <Button.Checkbox
                  checked={showPreferredContainer}
                  onClick={() =>
                    setShowPreferredContainer((currentValue) => !currentValue)
                  }
                >
                  Suggest
                </Button.Checkbox>
                <NumberInput
                  unit={'items'}
                  step={1}
                  value={itemCount}
                  minValue={1}
                  maxValue={maxPrintable}
                  onChange={(value) => {
                    setItemCount(value);
                  }}
                />
                {selectedContainerCategory === 'pills' && (
                  <NumberInput
                    unit="s"
                    step={1}
                    value={selectedPillDuration}
                    minValue={0}
                    maxValue={maxPillDuration}
                    onChange={(value) => {
                      act('setPillDuration', {
                        duration: value,
                      });
                    }}
                  />
                )}
                <Box inline mx={1}>
                  {`${
                    Math.round(
                      Math.min(
                        selectedContainerVolume,
                        buffer.currentVolume / itemCount,
                      ) * 100,
                    ) / 100
                  } u. each`}
                </Box>
                <Button
                  icon="flask"
                  onClick={() =>
                    act('create', {
                      itemCount: itemCount,
                    })
                  }
                >
                  Print
                </Button>
              </Box>
            )
          }
        >
          {categories.map((category) => (
            <Box key={category.name}>
              <GroupTitle title={category.name} />
              {category.containers.map((container) => (
                <ContainerButton
                  key={container.ref}
                  category={category}
                  container={container}
                  showPreferredContainer={showPreferredContainer}
                />
              ))}
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
              onClick={() => act('stopPrinting')}
            >
              Stop
            </Button>
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

type ReagentProps = {
  chemical: AnalyzableReagent;
  transferTo: string;
  analyze: (chemical: AnalyzableReagent) => void;
};

const ReagentEntry = (props: ReagentProps) => {
  const { data, act } = useBackend<Data>();
  const { chemical, transferTo, analyze } = props;
  const { isPrinting } = data;
  return (
    <Table.Row key={chemical.ref}>
      <Table.Cell color="label">
        {`${chemical.name} `}
        <AnimatedNumber value={chemical.volume} initial={0} />
        {'u'}
      </Table.Cell>
      <Table.Cell collapsing>
        <Button
          disabled={isPrinting}
          onClick={() => {
            act('transfer', {
              reagentRef: chemical.ref,
              amount: 1,
              target: transferTo,
            });
          }}
        >
          1
        </Button>
        <Button
          disabled={isPrinting}
          onClick={() =>
            act('transfer', {
              reagentRef: chemical.ref,
              amount: 5,
              target: transferTo,
            })
          }
        >
          5
        </Button>
        <Button
          disabled={isPrinting}
          onClick={() =>
            act('transfer', {
              reagentRef: chemical.ref,
              amount: 10,
              target: transferTo,
            })
          }
        >
          10
        </Button>
        <Button
          disabled={isPrinting}
          onClick={() =>
            act('transfer', {
              reagentRef: chemical.ref,
              amount: 1000,
              target: transferTo,
            })
          }
        >
          All
        </Button>
        <Button
          icon="ellipsis-h"
          tooltip="Custom amount"
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
          tooltip="Analyze"
          onClick={() => analyze(chemical)}
        />
      </Table.Cell>
    </Table.Row>
  );
};

type CategoryButtonProps = {
  category: Category;
  container: Container;
  showPreferredContainer: BooleanLike;
};

const ContainerButton = (props: CategoryButtonProps) => {
  const { act, data } = useBackend<Data>();
  const { isPrinting, selectedContainerRef, suggestedContainerRef } = data;
  const { category, container, showPreferredContainer } = props;
  const isPillPatch = ['pills', 'patches'].includes(category.name);
  const fallback = <Icon m="18px" name="spinner" spin />;
  const fallbackPillPatch = <Icon m="10px" name="spinner" spin />;

  return (
    <Tooltip
      key={container.ref}
      content={`${capitalize(container.name)}\xa0(${container.volume}u)`}
    >
      <Button
        overflow="hidden"
        color={'transparent'}
        backgroundColor={
          showPreferredContainer &&
          selectedContainerRef !== suggestedContainerRef && // if we selected the same container as the suggested then don't override color
          container.ref === suggestedContainerRef
            ? 'blue'
            : 'transparent'
        }
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
        <DmIcon
          m={isPillPatch ? '-16px' : '-8px'}
          fallback={isPillPatch ? fallbackPillPatch : fallback}
          icon={container.icon}
          icon_state={container.icon_state}
          height="64px"
          width="64px"
        />
      </Button>
    </Tooltip>
  );
};

const AnalysisResults = (props: {
  analysisData: AnalyzableReagent;
  onExit: () => void;
}) => {
  const {
    name,
    pH,
    color,
    description,
    purity,
    metaRate,
    overdose,
    addictionTypes,
  } = props.analysisData;

  const purityLevel =
    purity <= 0.5 ? 'bad' : purity <= 0.75 ? 'average' : 'good'; // Color names

  return (
    <Section
      title="Analysis Results"
      buttons={
        <Button icon="arrow-left" onClick={() => props.onExit()}>
          Back
        </Button>
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
  );
};
