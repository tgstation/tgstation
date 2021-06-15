import { useBackend } from '../../backend';
import { Box, Button, Collapsible, Dimmer, Divider, Icon, LabeledList, NumberInput, Section, Stack } from '../../components';
import { GeneticMakeupInfo } from './GeneticMakeupInfo';
import { RADIATION_DURATION_MAX, RADIATION_STRENGTH_MAX } from './constants';

const GeneticMakeupBufferInfo = (props, context) => {
  const { index, makeup } = props;
  const { act, data } = useBackend(context);
  const {
    isViableSubject,
    hasDisk,
    diskReadOnly,
    isInjectorReady,
  } = data;
  // Type of the action for applying makeup
  const ACTION_MAKEUP_APPLY = isViableSubject
    ? 'makeup_apply'
    : 'makeup_delay';
  if (!makeup) {
    return (
      <Box color="average">
        No stored subject data.
      </Box>
    );
  }
  return (
    <>
      <GeneticMakeupInfo makeup={makeup} />
      <Divider />
      <Box bold color="label" mb={1}>
        Makeup Actions
      </Box>
      <LabeledList>
        <LabeledList.Item label="Enzymes">
          <Button
            icon="syringe"
            disabled={!isInjectorReady}
            content="Print"
            onClick={() => act('makeup_injector', {
              index,
              type: 'ue',
            })} />
          <Button
            icon="exchange-alt"
            onClick={() => act(ACTION_MAKEUP_APPLY, {
              index,
              type: 'ue',
            })}>
            Transfer
            {!isViableSubject && ' (Delayed)'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Identity">
          <Button
            icon="syringe"
            disabled={!isInjectorReady}
            content="Print"
            onClick={() => act('makeup_injector', {
              index,
              type: 'ui',
            })} />
          <Button
            icon="exchange-alt"
            onClick={() => act(ACTION_MAKEUP_APPLY, {
              index,
              type: 'ui',
            })}>
            Transfer
            {!isViableSubject && ' (Delayed)'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Full Makeup">
          <Button
            icon="syringe"
            disabled={!isInjectorReady}
            content="Print"
            onClick={() => act('makeup_injector', {
              index,
              type: 'mixed',
            })} />
          <Button
            icon="exchange-alt"
            onClick={() => act(ACTION_MAKEUP_APPLY, {
              index,
              type: 'mixed',
            })}>
            Transfer
            {!isViableSubject && ' (Delayed)'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item>
          <Button
            icon="save"
            disabled={!hasDisk || diskReadOnly}
            content="Export To Disk"
            onClick={() => act('save_makeup_disk', {
              index,
            })} />
        </LabeledList.Item>
      </LabeledList>
    </>
  );
};

const GeneticMakeupBuffers = (props, context) => {
  const { data, act } = useBackend(context);
  const {
    diskHasMakeup,
    geneticMakeupCooldown,
    hasDisk,
    isViableSubject,
    makeupCapacity = 3,
    makeupStorage,
  } = data;
  const elements = [];
  for (let i = 1; i <= makeupCapacity; i++) {
    const makeup = makeupStorage[i];
    const element = (
      <Collapsible
        title={makeup
          ? (makeup.label || makeup.name)
          : `Slot ${i}`}
        buttons={
          <>
            {!!(hasDisk && diskHasMakeup) && (
              <Button
                mr={1}
                disabled={!hasDisk || !diskHasMakeup}
                content="Import from disk"
                onClick={() => act('load_makeup_disk', {
                  index: i,
                })} />
            )}
            <Button
              disabled={!isViableSubject}
              content="Save"
              onClick={() => act('save_makeup_console', {
                index: i,
              })} />
            <Button
              ml={1}
              icon="times"
              color="red"
              disabled={!makeup}
              onClick={() => act('del_makeup_console', {
                index: i,
              })} />
          </>
        }>
        <GeneticMakeupBufferInfo
          index={i}
          makeup={makeup} />
      </Collapsible>
    );
    elements.push(element);
  }
  return (
    <Section title="Genetic Makeup Buffers">
      {!!geneticMakeupCooldown && (
        <Dimmer
          fontSize="14px"
          textAlign="center">
          <Icon
            mr={1}
            name="spinner"
            spin />
          Genetic makeup transfer ready in...
          <Box mt={1} />
          {geneticMakeupCooldown}s
        </Dimmer>
      )}
      {elements}
    </Section>
  );
};

const RadiationEmitterProbs = (props, context) => {
  const { data } = useBackend(context);
  const {
    stdDevAcc,
    stdDevStr,
  } = data;
  return (
    <Section
      title="Probabilities"
      minHeight="100%">
      <LabeledList>
        <LabeledList.Item
          label="Accuracy"
          textAlign="right">
          {stdDevAcc}
        </LabeledList.Item>
        <LabeledList.Item
          label={`P(±${stdDevStr})`}
          textAlign="right">
          68 %
        </LabeledList.Item>
        <LabeledList.Item
          label={`P(±${stdDevStr * 2})`}
          textAlign="right">
          95 %
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const RadiationEmitterPulseBoard = (props, context) => {
  const { data, act } = useBackend(context);
  const {
    subjectUNI = [],
  } = data;
  // Build blocks of buttons of unique enzymes
  const blocks = [];
  let buffer = [];
  for (let i = 0; i < subjectUNI.length; i++) {
    const char = subjectUNI.charAt(i);
    // Push a button into the buffer
    const button = (
      <Button
        fluid
        key={i}
        textAlign="center"
        content={char}
        onClick={() => act('makeup_pulse', {
          index: i + 1,
        })} />
    );
    buffer.push(button);
    // Create a block from the current buffer
    if (buffer.length >= 3) {
      const block = (
        <Box inline width="22px" mx="1px">
          {buffer}
        </Box>
      );
      blocks.push(block);
      // Clear the buffer
      buffer = [];
    }
  }
  return (
    <Section
      title="Unique Enzymes"
      minHeight="100%"
      position="relative">
      <Box mx="-1px">
        {blocks}
      </Box>
    </Section>
  );
};

const RadiationEmitterSettings = (props, context) => {
  const { data, act } = useBackend(context);
  const {
    radStrength,
    radDuration,
  } = data;
  return (
    <Section
      title="Radiation Emitter"
      minHeight="100%">
      <LabeledList>
        <LabeledList.Item label="Output level">
          <NumberInput
            animated
            width="32px"
            stepPixelSize={10}
            value={radStrength}
            minValue={1}
            maxValue={RADIATION_STRENGTH_MAX}
            onDrag={(e, value) => act('set_pulse_strength', {
              val: value,
            })} />
        </LabeledList.Item>
        <LabeledList.Item label="Pulse duration">
          <NumberInput
            animated
            width="32px"
            stepPixelSize={10}
            value={radDuration}
            minValue={1}
            maxValue={RADIATION_DURATION_MAX}
            onDrag={(e, value) => act('set_pulse_duration', {
              val: value,
            })} />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

export const DnaConsoleEnzymes = (props, context) => {
  const { data, act } = useBackend(context);
  const {
    isScannerConnected,
  } = data;
  if (!isScannerConnected) {
    return (
      <Section color="bad">
        DNA Scanner is not connected.
      </Section>
    );
  }
  return (
    <>
      <Stack mb={1}>
        <Stack.Item width="155px">
          <RadiationEmitterSettings />
        </Stack.Item>
        <Stack.Item width="140px">
          <RadiationEmitterProbs />
        </Stack.Item>
        <Stack.Item grow={1} basis={0}>
          <RadiationEmitterPulseBoard />
        </Stack.Item>
      </Stack>
      <GeneticMakeupBuffers />
    </>
  );
};
