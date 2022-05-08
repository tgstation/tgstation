import { useBackend } from '../backend';
import { Box, Button, Icon, LabeledList, Section } from '../components';
import { Window } from '../layouts';

type AirlockControllerData = {
  airlockState: string;
  sensorPressure: number;
  pumpStatus: string;
  interiorStatus: string;
  exteriorStatus: string;
};

type AirlockStatus = {
  primary: string;
  icon?: string;
  color?: string;
};

const defaultStatus: AirlockStatus = {
  primary: 'Unknown',
  icon: '',
  color: 'average',
};

export const AirlockController = (_, context) => {
  const { data } = useBackend<AirlockControllerData>(context);
  const { airlockState, pumpStatus, interiorStatus, exteriorStatus } = data;
  let currentStatus: AirlockStatus = getAirlockStatus(airlockState);

  return (
    <Window width={500} height={190}>
      <Window.Content>
        <Section title="Airlock Status" buttons={<AirLockButtons />}>
          <LabeledList>
            <LabeledList.Item label="Current Status">
              {currentStatus.primary}
            </LabeledList.Item>
            <LabeledList.Item label="Chamber Pressure">
              <PressureIndicator currentStatus={currentStatus} />
            </LabeledList.Item>
            <LabeledList.Item label="Control Pump">
              {pumpStatus.replace(/^\w/, (c) => c.toUpperCase())}
            </LabeledList.Item>
            <LabeledList.Item label="Interior Door">
              <Box color={interiorStatus === 'open' && 'good'}>
                {interiorStatus.replace(/^\w/, (c) => c.toUpperCase())}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Exterior Door">
              <Box color={exteriorStatus === 'open' && 'good'}>
                {exteriorStatus.replace(/^\w/, (c) => c.toUpperCase())}
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};

/** Displays the buttons atop the window to cycle the airlock */
const AirLockButtons = (_, context) => {
  const { act, data } = useBackend<AirlockControllerData>(context);
  const { airlockState } = data;

  return (
    ((airlockState === 'pressurize' || airlockState === 'depressurize') && (
      <Button icon="stop-circle" onClick={() => act('abort')}>
        Abort
      </Button>
    ))
    || (airlockState === 'closed' && (
      <>
        <Button icon="lock-open" onClick={() => act('cycleInterior')}>
          Open Interior Airlock
        </Button>
        <Button icon="lock-open" onClick={() => act('cycleExterior')}>
          Open Exterior Airlock
        </Button>
      </>
    ))
    || (airlockState === 'inopen' && (
      <>
        <Button icon="lock" onClick={() => act('cycleClosed')}>
          Close Interior Airlock
        </Button>
        <Button icon="sync" onClick={() => act('cycleExterior')}>
          Cycle to Exterior Airlock
        </Button>
      </>
    ))
    || (airlockState === 'outopen' && (
      <>
        <Button icon="lock" onClick={() => act('cycleClosed')}>
          Close Exterior Airlock
        </Button>
        <Button icon="sync" onClick={() => act('cycleInterior')}>
          Cycle to Interior Airlock
        </Button>
      </>
    ))
  );
};

/** Displays the current status as two text strings, depending on door state. */
const getAirlockStatus = (airlockState) => {
  let currentStatus: AirlockStatus;

  switch (airlockState) {
    case 'inopen':
      currentStatus = {
        primary: 'Interior Airlock Open',
        color: 'good',
      };
      break;
    case 'pressurize':
      currentStatus = {
        ...defaultStatus,
        primary: 'Cycling to Interior Airlock',
        icon: 'fan',
        color: 'average',
      };
      break;
    case 'closed':
      currentStatus = {
        ...defaultStatus,
        primary: 'Inactive',
        color: 'white',
      };
      break;
    case 'depressurize':
      currentStatus = {
        ...defaultStatus,
        primary: 'Cycling to Exterior Airlock',
        icon: 'fan',
        color: 'average',
      };
      break;
    case 'outopen':
      currentStatus = {
        ...defaultStatus,
        primary: 'Exterior Airlock Open',
        icon: 'exclamation-triangle',
        color: 'bad',
      };
      break;
    default:
      currentStatus = defaultStatus;
  }

  return currentStatus;
};

/** Displays the numeric pressure alongside an icon for the user */
const PressureIndicator = (props, context) => {
  const { data } = useBackend<AirlockControllerData>(context);
  const { sensorPressure } = data;
  const { currentStatus } = props;
  const { icon, color } = currentStatus;
  let spin = icon === 'fan' ? 1 : 0;

  return (
    <Box color={color}>
      {sensorPressure} kPa{' '}
      {currentStatus.icon && <Icon name={icon} spin={spin} />}
    </Box>
  );
};
