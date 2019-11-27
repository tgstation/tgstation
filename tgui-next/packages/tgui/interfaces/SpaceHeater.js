import { Fragment } from 'inferno';
import { act } from '../byond';
import { Section, ProgressBar, LabeledList, Button, NumberInput, Box } from '../components';
import { LabeledListItem, LabeledListDivider } from '../components/LabeledList';

export const SpaceHeater = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  return (
    <Fragment>
      <Section
        title="Power"
        buttons={
          <Fragment>
            <Button
              icon="eject"
              content="Eject Cell"
              disabled={!data.hasPowercell || !data.open}
              onClick={() => act(ref, 'eject')} />
            <Button
              icon={data.on ? 'power-off' : 'times'}
              content={data.on ? 'On' : 'Off'}
              selected={data.on}
              disabled={!data.hasPowercell}
              onClick={() => act(ref, 'power')} />
          </Fragment>
        }>
        <LabeledList>
          <LabeledListItem label="Cell" color={data.hasPowercell ? "" : "bad"}>
            {data.hasPowercell ? (
              <ProgressBar
                value={data.powerLevel / 100}
                content={data.powerLevel + '%'}
                ranges={{
                  good: [0.6, Infinity],
                  average: [0.3, 0.6],
                  bad: [-Infinity, 0.3],
                }} />
            ) : ("None")}
          </LabeledListItem>
        </LabeledList>
      </Section>
      <Section title="Thermostat">
        <LabeledList>
          <LabeledListItem label="Current Temperature">
            <Box
              fontSize="18px"
              color={Math.abs(data.targetTemp - data.currentTemp) > 50
                ? "bad"
                : Math.abs(data.targetTemp - data.currentTemp) > 20 ? "average" : "good"}>
              {data.currentTemp}°C
            </Box>
          </LabeledListItem>
          <LabeledListItem label="Target Temperature">
            {data.open
              ? (
                <NumberInput
                  animated
                  value={parseFloat(data.targetTemp)}
                  width="65px"
                  unit="°C"
                  minValue={data.minTemp}
                  maxValue={data.maxTemp}
                  onChange={(e, value) => act(ref, 'target', {
                    target: value,
                  })} />
              ) : (
                data.targetTemp + "°C"
              )}
          </LabeledListItem>
          <LabeledListItem label="Mode">
            {!data.open
              ? ("Auto"
              ) : (
                <Fragment>
                  <Button
                    icon="thermometer-half"
                    content="Auto"
                    selected={data.mode === "auto"}
                    onClick={() => act(ref, 'mode', {
                      mode: "auto",
                    })} />
                  <Button
                    icon="fire-alt"
                    content="Heat"
                    selected={data.mode === "heat"}
                    onClick={() => act(ref, 'mode', {
                      mode: "heat",
                    })} />
                  <Button
                    icon="fan"
                    content="Cool"
                    selected={data.mode === "cool"}
                    onClick={() => act(ref, 'mode', {
                      mode: "cool",
                    })} />
                </Fragment>
              )}
          </LabeledListItem>
          <LabeledListDivider />
        </LabeledList>
      </Section>
    </Fragment>
  );
};
