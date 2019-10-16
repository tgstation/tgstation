import { Fragment } from 'inferno';
import { act } from '../byond';
import { AnimatedNumber, Button, LabeledList, NoticeBox, ProgressBar, Section, Box } from '../components';

export const Canister = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
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
            onClick={() => act(ref, 'relabel')} />
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
                onClick={() => act(ref, 'restricted')} />
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
              onClick={() => act(ref, 'pressure', {
                pressure: 'reset',
              })} />
            <Button
              icon="minus"
              disabled={data.releasePressure <= data.minReleasePressure}
              content="Min"
              onClick={() => act(ref, 'pressure', {
                pressure: 'min',
              })} />
            <Button
              icon="pencil-alt"
              content="Set"
              onClick={() => act(ref, 'pressure', {
                pressure: 'input',
              })} />
            <Button
              icon="plus"
              disabled={data.releasePressure >= data.maxReleasePressure}
              content="Max"
              onClick={() => act(ref, 'pressure', {
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
              onClick={() => act(ref, 'valve')} />
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
            onClick={() => act(ref, 'eject')} />
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
