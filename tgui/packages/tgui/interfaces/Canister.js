import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { AnimatedNumber, Box, Button, LabeledList, NoticeBox, ProgressBar, Section } from '../components';

export const Canister = props => {
  const { act, data } = useBackend(props);
  return (
    <Fragment>
      <NoticeBox>
        The regulator {data.hasHoldingTank ? 'is' : 'is not'} connected
        to a tank.
      </NoticeBox>
      <Section
        title="Canister"
        buttons={(
          <Button
            icon="pencil-alt"
            content="Relabel"
            onClick={() => act('relabel')} />
        )}>
        <LabeledList>
          <LabeledList.Item label="Pressure">
            <AnimatedNumber value={data.tankPressure} /> kPa
          </LabeledList.Item>
          <LabeledList.Item
            label="Port"
            color={data.portConnected ? 'good' : 'average'}
            content={data.portConnected ? 'Connected' : 'Not Connected'} />
          {!!data.isPrototype && (
            <LabeledList.Item label="Access">
              <Button
                icon={data.restricted ? 'lock' : 'unlock'}
                color="caution"
                content={data.restricted
                  ? 'Restricted to Engineering'
                  : 'Public'}
                onClick={() => act('restricted')} />
            </LabeledList.Item>
          )}
        </LabeledList>
      </Section>

      <Section title="Valve">
        <LabeledList>
          <LabeledList.Item label="Release Pressure">
            <ProgressBar
              value={data.releasePressure
                / (data.maxReleasePressure - data.minReleasePressure)}>
              <AnimatedNumber value={data.releasePressure} /> kPa
            </ProgressBar>
          </LabeledList.Item>
          <LabeledList.Item label="Pressure Regulator">
            <Button
              icon="undo"
              disabled={data.releasePressure === data.defaultReleasePressure}
              content="Reset"
              onClick={() => act('pressure', {
                pressure: 'reset',
              })} />
            <Button
              icon="minus"
              disabled={data.releasePressure <= data.minReleasePressure}
              content="Min"
              onClick={() => act('pressure', {
                pressure: 'min',
              })} />
            <Button
              icon="pencil-alt"
              content="Set"
              onClick={() => act('pressure', {
                pressure: 'input',
              })} />
            <Button
              icon="plus"
              disabled={data.releasePressure >= data.maxReleasePressure}
              content="Max"
              onClick={() => act('pressure', {
                pressure: 'max',
              })} />
          </LabeledList.Item>

          <LabeledList.Item label="Valve">
            <Button
              icon={data.valveOpen ? 'unlock' : 'lock'}
              color={data.valveOpen
                ? (data.hasHoldingTank ? 'caution' : 'danger')
                : null}
              content={data.valveOpen ? 'Open' : 'Closed'}
              onClick={() => act('valve')} />
          </LabeledList.Item>
        </LabeledList>
      </Section>

      <Section
        title="Holding Tank"
        buttons={!!data.hasHoldingTank && (
          <Button
            icon="eject"
            color={data.valveOpen && 'danger'}
            content="Eject"
            onClick={() => act('eject')} />
        )}>
        {!!data.hasHoldingTank && (
          <LabeledList>
            <LabeledList.Item label="Label">
              {data.holdingTank.name}
            </LabeledList.Item>
            <LabeledList.Item label="Pressure">
              <AnimatedNumber value={data.holdingTank.tankPressure} /> kPa
            </LabeledList.Item>
          </LabeledList>
        )}
        {!data.hasHoldingTank && (
          <Box color="average">
            No Holding Tank
          </Box>
        )}
      </Section>
    </Fragment>
  );
};
