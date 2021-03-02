import { useBackend, useSharedState } from '../backend';
import { AnimatedNumber, Box, Button, ColorBox, LabeledList, NumberInput, Section, Table } from '../components';
import { Window } from '../layouts';

export const ChemMaster = (props, context) => {
  const { data } = useBackend(context);
  const { screen } = data;
  return (
    <Window
      width={465}
      height={550}>
      <Window.Content scrollable>
        {screen === 'analyze' && (
          <AnalysisResults />
        ) || (
          <ChemMasterContent />
        )}
      </Window.Content>
    </Window>
  );
};

const ChemMasterContent = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    screen,
    beakerContents = [],
    bufferContents = [],
    beakerCurrentVolume,
    beakerMaxVolume,
    isBeakerLoaded,
    isPillBottleLoaded,
    pillBottleCurrentAmount,
    pillBottleMaxAmount,
  } = data;
  if (screen === 'analyze') {
    return <AnalysisResults />;
  }
  return (
    <>
      <Section
        title="Beaker"
        buttons={!!data.isBeakerLoaded && (
          <>
            <Box inline color="label" mr={2}>
              <AnimatedNumber
                value={beakerCurrentVolume}
                initial={0} />
              {` / ${beakerMaxVolume} units`}
            </Box>
            <Button
              icon="eject"
              content="Eject"
              onClick={() => act('eject')} />
          </>
        )}>
        {!isBeakerLoaded && (
          <Box color="label" mt="3px" mb="5px">
            No beaker loaded.
          </Box>
        )}
        {!!isBeakerLoaded && beakerContents.length === 0 && (
          <Box color="label" mt="3px" mb="5px">
            Beaker is empty.
          </Box>
        )}
        <ChemicalBuffer>
          {beakerContents.map(chemical => (
            <ChemicalBufferEntry
              key={chemical.id}
              chemical={chemical}
              transferTo="buffer" />
          ))}
        </ChemicalBuffer>
      </Section>
      <Section
        title="Buffer"
        buttons={(
          <>
            <Box inline color="label" mr={1}>
              Mode:
            </Box>
            <Button
              color={data.mode ? 'good' : 'bad'}
              icon={data.mode ? 'exchange-alt' : 'times'}
              content={data.mode ? 'Transfer' : 'Destroy'}
              onClick={() => act('toggleMode')} />
          </>
        )}>
        {bufferContents.length === 0 && (
          <Box color="label" mt="3px" mb="5px">
            Buffer is empty.
          </Box>
        )}
        <ChemicalBuffer>
          {bufferContents.map(chemical => (
            <ChemicalBufferEntry
              key={chemical.id}
              chemical={chemical}
              transferTo="beaker" />
          ))}
        </ChemicalBuffer>
      </Section>
      <Section
        title="Packaging">
        <PackagingControls />
      </Section>
      {!!isPillBottleLoaded && (
        <Section
          title="Pill Bottle"
          buttons={(
            <>
              <Box inline color="label" mr={2}>
                {pillBottleCurrentAmount} / {pillBottleMaxAmount} pills
              </Box>
              <Button
                icon="eject"
                content="Eject"
                onClick={() => act('ejectPillBottle')} />
            </>
          )} />
      )}
    </>
  );
};

const ChemicalBuffer = Table;

const ChemicalBufferEntry = (props, context) => {
  const { act } = useBackend(context);
  const { chemical, transferTo } = props;
  return (
    <Table.Row key={chemical.id}>
      <Table.Cell color="label">
        <AnimatedNumber
          value={chemical.volume}
          initial={0} />
        {` units of ${chemical.name}`}
      </Table.Cell>
      <Table.Cell collapsing>
        <Button
          content="1"
          onClick={() => act('transfer', {
            id: chemical.id,
            amount: 1,
            to: transferTo,
          })} />
        <Button
          content="5"
          onClick={() => act('transfer', {
            id: chemical.id,
            amount: 5,
            to: transferTo,
          })} />
        <Button
          content="10"
          onClick={() => act('transfer', {
            id: chemical.id,
            amount: 10,
            to: transferTo,
          })} />
        <Button
          content="All"
          onClick={() => act('transfer', {
            id: chemical.id,
            amount: 1000,
            to: transferTo,
          })} />
        <Button
          icon="ellipsis-h"
          title="Custom amount"
          onClick={() => act('transfer', {
            id: chemical.id,
            amount: -1,
            to: transferTo,
          })} />
        <Button
          icon="question"
          title="Analyze"
          onClick={() => act('analyze', {
            id: chemical.id,
          })} />
      </Table.Cell>
    </Table.Row>
  );
};

const PackagingControlsItem = props => {
  const {
    label,
    amountUnit,
    amount,
    onChangeAmount,
    onCreate,
    sideNote,
  } = props;
  return (
    <LabeledList.Item label={label}>
      <NumberInput
        width="84px"
        unit={amountUnit}
        step={1}
        stepPixelSize={15}
        value={amount}
        minValue={1}
        maxValue={10}
        onChange={onChangeAmount} />
      <Button
        ml={1}
        content="Create"
        onClick={onCreate} />
      <Box inline ml={1} color="label">
        {sideNote}
      </Box>
    </LabeledList.Item>
  );
};

const PackagingControls = (props, context) => {
  const { act, data } = useBackend(context);
  const [
    pillAmount,
    setPillAmount,
  ] = useSharedState(context, 'pillAmount', 1);
  const [
    patchAmount,
    setPatchAmount,
  ] = useSharedState(context, 'patchAmount', 1);
  const [
    bottleAmount,
    setBottleAmount,
  ] = useSharedState(context, 'bottleAmount', 1);
  const [
    packAmount,
    setPackAmount,
  ] = useSharedState(context, 'packAmount', 1);
  const {
    condi,
    chosenPillStyle,
    chosenCondiStyle,
    autoCondiStyle,
    pillStyles = [],
    condiStyles = [],
  } = data;
  const autoCondiStyleChosen = autoCondiStyle === chosenCondiStyle;
  return (
    <LabeledList>
      {!condi && (
        <LabeledList.Item label="Pill type">
          {pillStyles.map(pill => (
            <Button
              key={pill.id}
              width="30px"
              selected={pill.id === chosenPillStyle}
              textAlign="center"
              color="transparent"
              onClick={() => act('pillStyle', { id: pill.id })}>
              <Box mx={-1} className={pill.className} />
            </Button>
          ))}
        </LabeledList.Item>
      )}
      {!condi && (
        <PackagingControlsItem
          label="Pills"
          amount={pillAmount}
          amountUnit="pills"
          sideNote="max 50u"
          onChangeAmount={(e, value) => setPillAmount(value)}
          onCreate={() => act('create', {
            type: 'pill',
            amount: pillAmount,
            volume: 'auto',
          })} />
      )}
      {!condi && (
        <PackagingControlsItem
          label="Patches"
          amount={patchAmount}
          amountUnit="patches"
          sideNote="max 40u"
          onChangeAmount={(e, value) => setPatchAmount(value)}
          onCreate={() => act('create', {
            type: 'patch',
            amount: patchAmount,
            volume: 'auto',
          })} />
      )}
      {!condi && (
        <PackagingControlsItem
          label="Bottles"
          amount={bottleAmount}
          amountUnit="bottles"
          sideNote="max 30u"
          onChangeAmount={(e, value) => setBottleAmount(value)}
          onCreate={() => act('create', {
            type: 'bottle',
            amount: bottleAmount,
            volume: 'auto',
          })} />
      )}
      {!!condi && (
        <LabeledList.Item label="Bottle type">
          <Button.Checkbox
            onClick={() => act('condiStyle', { id: autoCondiStyleChosen ? condiStyles[0].id : autoCondiStyle })}
            checked={autoCondiStyleChosen}
            disabled={!condiStyles.length}>
            Guess from contents
          </Button.Checkbox>
        </LabeledList.Item>
      )}
      {!!condi && !autoCondiStyleChosen && (
        <LabeledList.Item label="">
          {condiStyles.map(style => (
            <Button
              key={style.id}
              width="30px"
              selected={style.id === chosenCondiStyle}
              textAlign="center"
              color="transparent"
              title={style.title}
              onClick={() => act('condiStyle', { id: style.id })}>
              <Box mx={-1} className={style.className} />
            </Button>
          ))}
        </LabeledList.Item>
      )}
      {!!condi && (
        <PackagingControlsItem
          label="Bottles"
          amount={bottleAmount}
          amountUnit="bottles"
          sideNote="max 50u"
          onChangeAmount={(e, value) => setBottleAmount(value)}
          onCreate={() => act('create', {
            type: 'condimentBottle',
            amount: bottleAmount,
            volume: 'auto',
          })} />
      )}
      {!!condi && (
        <PackagingControlsItem
          label="Packs"
          amount={packAmount}
          amountUnit="packs"
          sideNote="max 10u"
          onChangeAmount={(e, value) => setPackAmount(value)}
          onCreate={() => act('create', {
            type: 'condimentPack',
            amount: packAmount,
            volume: 'auto',
          })} />
      )}
    </LabeledList>
  );
};

const AnalysisResults = (props, context) => {
  const { act, data } = useBackend(context);
  const { analyzeVars } = data;
  return (
    <Section
      title="Analysis Results"
      buttons={(
        <Button
          icon="arrow-left"
          content="Back"
          onClick={() => act('goScreen', {
            screen: 'home',
          })} />
      )}>
      <LabeledList>
        <LabeledList.Item label="Name">
          {analyzeVars.name}
        </LabeledList.Item>
        <LabeledList.Item label="State">
          {analyzeVars.state}
        </LabeledList.Item>
        <LabeledList.Item label="pH">
          {analyzeVars.ph}
        </LabeledList.Item>
        <LabeledList.Item label="Color">
          <ColorBox color={analyzeVars.color} mr={1} />
          {analyzeVars.color}
        </LabeledList.Item>
        <LabeledList.Item label="Description">
          {analyzeVars.description}
        </LabeledList.Item>
        <LabeledList.Item label="Metabolization Rate">
          {analyzeVars.metaRate} u/minute
        </LabeledList.Item>
        <LabeledList.Item label="Overdose Threshold">
          {analyzeVars.overD}
        </LabeledList.Item>
        <LabeledList.Item label="Addiction Threshold">
          {analyzeVars.addicD}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
