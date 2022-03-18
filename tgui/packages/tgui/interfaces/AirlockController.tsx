import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section } from '../components';
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
  secondary: string;
  color: string;
};

const defaultStatus: AirlockStatus = {
  primary: 'Unknown',
  secondary: '',
  color: 'average',
};

export const AirlockController = (_, context) => {
  const { data } = useBackend<AirlockControllerData>(context);
  const { sensorPressure, pumpStatus, interiorStatus, exteriorStatus } = data;

  return (
    <Window width={500} height={190}>
      <Window.Content>
        <Section title="Airlock Status" buttons={<AirLockButtons />}>
          <LabeledList>
            <LabeledList.Item label="Current Status">
              <CurrentStatusDisplay />
            </LabeledList.Item>
            <LabeledList.Item label="Chamber Pressure">
              {sensorPressure} kPa
            </LabeledList.Item>
            <LabeledList.Item label="Control Pump">
              {pumpStatus}
            </LabeledList.Item>
            <LabeledList.Item label="Interior Door">
              {interiorStatus}
            </LabeledList.Item>
            <LabeledList.Item label="Exterior Door">
              {exteriorStatus}
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
      <Button icon="stop-circle" content="Abort" onClick={() => act('abort')} />
    ))
    || (airlockState === 'closed' && (
      <>
        <Button
          icon="lock-open"
          content="Open Interior Airlock"
          onClick={() => act('cycleInterior')}
        />
        <Button
          icon="lock-open"
          content="Open Exterior Airlock"
          onClick={() => act('cycleExterior')}
        />
      </>
    ))
    || (airlockState === 'inopen' && (
      <>
        <Button
          icon="lock"
          content="Close Interior Airlock"
          onClick={() => act('cycleClosed')}
        />
        <Button
          icon="sync"
          content="Cycle to Exterior Airlock"
          onClick={() => act('cycleExterior')}
        />
      </>
    ))
    || (airlockState === 'outopen' && (
      <>
        <Button
          icon="lock"
          content="Close Exterior Airlock"
          onClick={() => act('cycleClosed')}
        />
        <Button
          icon="sync"
          content="Cycle to Interior Airlock"
          onClick={() => act('cycleInterior')}
        />
      </>
    ))
  );
};

/** Displays the current status as two text strings, depending on door state. */
const CurrentStatusDisplay = (_, context) => {
  const { data } = useBackend<AirlockControllerData>(context);
  const { airlockState } = data;
  let currentStatus: AirlockStatus;
  switch (airlockState) {
    case 'inopen':
      currentStatus = {
        primary: 'Interior Airlock Open',
        secondary: 'Chamber Pressurized',
        color: 'good',
      };
      break;
    case 'pressurize':
      currentStatus = {
        ...defaultStatus,
        primary: 'Cycling to Interior Airlock',
        secondary: 'Chamber Pressurizing',
      };
      break;
    case 'closed':
      currentStatus = {
        ...defaultStatus,
        primary: 'Inactive',
      };
      break;
    case 'depressurize':
      currentStatus = {
        ...defaultStatus,
        primary: 'Cycling to Exterior Airlock',
        secondary: 'Chamber Depressurizing',
      };
      break;
    case 'outopen':
      currentStatus = {
        ...defaultStatus,
        primary: 'Exterior Airlock Open',
        secondary: 'Chamber Depressurized',
        color: 'bad',
      };
      break;
    default:
      currentStatus = defaultStatus;
  }

  return (
    <>
      {currentStatus.primary}{' '}
      {currentStatus.secondary !== '' && (
        <Box as="span" color={currentStatus.color}>
          {currentStatus.secondary}
        </Box>
      )}
    </>
  );
};
