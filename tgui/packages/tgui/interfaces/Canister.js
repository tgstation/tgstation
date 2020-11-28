import { toFixed } from 'common/math';
import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { AnimatedNumber, Box, Button, Icon, Knob, LabeledControls, LabeledList, Section, Tooltip, RoundGauge } from '../components';
import { formatSiUnit } from '../format';
import { Window } from '../layouts';

const formatPressure = value => {
  if (value < 10000) {
    return toFixed(value) + ' kPa';
  }
  return formatSiUnit(value * 1000, 1, 'Pa');
}

export const Canister = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    portConnected,
    tankPressure,
    releasePressure,
    defaultReleasePressure,
    minReleasePressure,
    maxReleasePressure,
    pressureLimit,
    valveOpen,
    isPrototype,
    hasHoldingTank,
    holdingTank,
    holdingTankLeakPressure,
    holdingTankFragPressure,
    restricted,
  } = data;
  return (
    <Window
      width={300}
      height={250}>
      <Window.Content>
        <Section
          title="Canister"
          buttons={(
            <Fragment>
              {!!isPrototype && (
                <Button
                  mr={1}
                  icon={restricted ? 'lock' : 'unlock'}
                  color="caution"
                  content={restricted
                    ? 'Engineering'
                    : 'Public'}
                  onClick={() => act('restricted')} />
              )}
              <Button
                icon="pencil-alt"
                content="Relabel"
                onClick={() => act('relabel')} />
            </Fragment>
          )}>
          <LabeledControls>
            <LabeledControls.Item
              minWidth="66px"
              label="Pressure">
              <RoundGauge
                size={1.25}
                unit="kPa"
                value={tankPressure}
                minValue={0}
                maxValue={pressureLimit}
                ranges={{
                  "good": [0, pressureLimit * 0.70],
                  "average": [pressureLimit * 0.70, pressureLimit * 0.85],
                  "bad": [pressureLimit * 0.85, pressureLimit],
                }}
                format={formatPressure} />
            </LabeledControls.Item>
            <LabeledControls.Item label="Regulator">
              <Box
                position="relative"
                left="-8px">
                <Knob
                  size={1.25}
                  color={!!valveOpen && 'yellow'}
                  value={releasePressure}
                  unit="kPa"
                  minValue={minReleasePressure}
                  maxValue={maxReleasePressure}
                  step={5}
                  stepPixelSize={1}
                  onDrag={(e, value) => act('pressure', {
                    pressure: value,
                  })} />
                <Button
                  fluid
                  position="absolute"
                  top="-2px"
                  right="-20px"
                  color="transparent"
                  icon="fast-forward"
                  onClick={() => act('pressure', {
                    pressure: maxReleasePressure,
                  })} />
                <Button
                  fluid
                  position="absolute"
                  top="16px"
                  right="-20px"
                  color="transparent"
                  icon="undo"
                  onClick={() => act('pressure', {
                    pressure: defaultReleasePressure,
                  })} />
              </Box>
            </LabeledControls.Item>
            <LabeledControls.Item label="Valve">
              <Button
                my={0.5}
                width="50px"
                lineHeight={2}
                fontSize="11px"
                color={valveOpen
                  ? (hasHoldingTank ? 'caution' : 'danger')
                  : null}
                content={valveOpen ? 'Open' : 'Closed'}
                onClick={() => act('valve')} />
            </LabeledControls.Item>
            <LabeledControls.Item
              mr={1}
              label="Port">
              <Box position="relative">
                <Icon
                  size={1.25}
                  name={portConnected ? 'plug' : 'times'}
                  color={portConnected ? 'good' : 'bad'} />
                <Tooltip
                  content={portConnected
                    ? 'Connected'
                    : 'Disconnected'}
                  position="top" />
              </Box>
            </LabeledControls.Item>
          </LabeledControls>
        </Section>
        <Section
          title="Holding Tank"
          buttons={!!hasHoldingTank && (
            <Button
              icon="eject"
              color={valveOpen && 'danger'}
              content="Eject"
              onClick={() => act('eject')} />
          )}>
          {!!hasHoldingTank && (
            <LabeledList>
              <LabeledList.Item label="Label">
                {holdingTank.name}
              </LabeledList.Item>
              <LabeledList.Item label="Pressure">
                <RoundGauge
                  value={holdingTank.tankPressure}
                  minValue={0}
                  maxValue={holdingTankFragPressure}
                  ranges={{
                    "good": [0, holdingTankLeakPressure],
                    "bad": [holdingTankLeakPressure, holdingTankFragPressure],
                  }}
                  format={formatPressure}
                  size={1} />
              </LabeledList.Item>
            </LabeledList>
          )}
          {!hasHoldingTank && (
            <Box color="average">
              No Holding Tank
            </Box>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
