import { useBackend } from '../../backend';
import { Box, Button, Icon, LabeledList, ProgressBar, Section } from '../../components';
import { SUBJECT_CONCIOUS, SUBJECT_DEAD, SUBJECT_SOFT_CRIT, SUBJECT_TRANSFORMING, SUBJECT_UNCONSCIOUS } from './constants';

const DnaScannerButtons = (props, context) => {
  const { data, act } = useBackend(context);
  const {
    hasDelayedAction,
    isPulsingRads,
    isScannerConnected,
    isScrambleReady,
    isViableSubject,
    scannerLocked,
    scannerOpen,
    scrambleSeconds,
  } = data;
  if (!isScannerConnected) {
    return (
      <Button
        content="Connect Scanner"
        onClick={() => act('connect_scanner')} />
    );
  }
  return (
    <>
      {!!hasDelayedAction && (
        <Button
          content="Cancel Delayed Action"
          onClick={() => act('cancel_delay')} />
      )}
      {!!isViableSubject && (
        <Button
          disabled={!isScrambleReady || isPulsingRads}
          onClick={() => act('scramble_dna')}>
          Scramble DNA
          {!isScrambleReady && ` (${scrambleSeconds}s)`}
        </Button>
      )}
      <Box inline mr={1} />
      <Button
        icon={scannerLocked ? 'lock' : 'lock-open'}
        color={scannerLocked && 'bad'}
        disabled={scannerOpen}
        content={scannerLocked ? 'Locked' : 'Unlocked'}
        onClick={() => act('toggle_lock')} />
      <Button
        disabled={scannerLocked}
        content={scannerOpen ? 'Close' : 'Open'}
        onClick={() => act('toggle_door')} />
    </>
  );
};

/**
 * Displays subject status based on the value of the status prop.
 */
const SubjectStatus = (props, context) => {
  const { status } = props;
  if (status === SUBJECT_CONCIOUS) {
    return (
      <Box inline color="good">Conscious</Box>
    );
  }
  if (status === SUBJECT_UNCONSCIOUS) {
    return (
      <Box inline color="average">Unconscious</Box>
    );
  }
  if (status === SUBJECT_SOFT_CRIT) {
    return (
      <Box inline color="average">Critical</Box>
    );
  }
  if (status === SUBJECT_DEAD) {
    return (
      <Box inline color="bad">Dead</Box>
    );
  }
  if (status === SUBJECT_TRANSFORMING) {
    return (
      <Box inline color="bad">Transforming</Box>
    );
  }
  return (
    <Box inline>Unknown</Box>
  );
};

const DnaScannerContent = (props, context) => {
  const { data, act } = useBackend(context);
  const {
    subjectName,
    isScannerConnected,
    isViableSubject,
    subjectHealth,
    subjectRads,
    subjectStatus,
  } = data;
  if (!isScannerConnected) {
    return (
      <Box color="bad">
        DNA Scanner is not connected.
      </Box>
    );
  }
  if (!isViableSubject) {
    return (
      <Box color="average">
        No viable subject found in DNA Scanner.
      </Box>
    );
  }
  return (
    <LabeledList>
      <LabeledList.Item label="Status">
        {subjectName}
        <Icon
          mx={1}
          color="label"
          name="long-arrow-alt-right" />
        <SubjectStatus status={subjectStatus} />
      </LabeledList.Item>
      <LabeledList.Item label="Health">
        <ProgressBar
          value={subjectHealth}
          minValue={0}
          maxValue={100}
          ranges={{
            olive: [101, Infinity],
            good: [70, 101],
            average: [30, 70],
            bad: [-Infinity, 30],
          }}>
          {subjectHealth}%
        </ProgressBar>
      </LabeledList.Item>
      <LabeledList.Item label="Radiation">
        <ProgressBar
          value={subjectRads}
          minValue={0}
          maxValue={100}
          ranges={{
            bad: [71, Infinity],
            average: [30, 71],
            good: [0, 30],
            olive: [-Infinity, 0],
          }}>
          {subjectRads}%
        </ProgressBar>
      </LabeledList.Item>
    </LabeledList>
  );
};

export const DnaScanner = (props, context) => {
  return (
    <Section
      title="DNA Scanner"
      buttons={(
        <DnaScannerButtons />
      )}>
      <DnaScannerContent />
    </Section>
  );
};
