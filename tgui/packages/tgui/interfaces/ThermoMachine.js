import { toFixed } from 'common/math';
import { useBackend } from '../backend';
import { AnimatedNumber, Box, Button, LabeledList, Modal, NumberInput, Section } from '../components';
import { Window } from '../layouts';

export const ThermoMachine = (props, context) => {
  const { act, data } = useBackend(context);
  const pressure_error = !!data.skipping_work && (
    <Modal>
      <Box
        style={{ margin: 'auto' }}
        width="200px"
        textAlign="center"
        minHeight="39px">
        {"No enviromental pressure or ports not connected/with no gas"}
      </Box>
    </Modal>
  );
  return (
    <Window
      width={300}
      height={350}>
      <Window.Content>
        <Section title="Status">
          {pressure_error}
          <LabeledList>
            <LabeledList.Item label="Temperature">
              <AnimatedNumber
                value={data.temperature}
                format={value => toFixed(value, 2)} />
              {' K'}
            </LabeledList.Item>
            <LabeledList.Item label="Pressure">
              <AnimatedNumber
                value={data.pressure}
                format={value => toFixed(value, 2)} />
              {' kPa'}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title="Controls"
          buttons={(
            <Button
              icon={data.on ? 'power-off' : 'times'}
              content={data.on ? 'On' : 'Off'}
              selected={data.on}
              onClick={() => act('power')} />
          )}>
          <LabeledList>
            <LabeledList.Item label="Safeties">
              <Button
                content={data.safeties ? 'Safeties ON' : 'Safeties OFF'}
                color={data.safeties ? "green" : "red"}
                disabled={!data.hacked}
                onClick={() => act('safeties')} />
            </LabeledList.Item>
            <LabeledList.Item label="Use tank gas">
              <Button
                content={data.tank_gas ? 'Push gas' : 'Empty'}
                selected={data.tank_gas}
                disabled={!data.tank_gas}
                onClick={() => act('pumping')} />
            </LabeledList.Item>
            <LabeledList.Item label="Eject tank gas">
              <Button
                content={data.holding ? 'Eject tank' : 'Empty'}
                disabled={!data.holding}
                onClick={() => act('eject')} />
            </LabeledList.Item>
            <LabeledList.Item label="Use enviromental heat">
              <Button
                content={data.use_env_heat ? 'On' : 'Off'}
                selected={data.use_env_heat}
                onClick={() => act('use_env_heat')} />
            </LabeledList.Item>
            <LabeledList.Item label="Thermal setting">
              <Button
                content={data.auto_thermal_regulator ? 'Auto' : 'Off'}
                selected={data.auto_thermal_regulator}
                onClick={() => act('auto_thermal_regulator')} />
              <Button
                content={data.cooling ? 'Cooling' : 'Heating'}
                disabled={data.auto_thermal_regulator}
                selected={data.cooling}
                onClick={() => act('cooling')} />
            </LabeledList.Item>
            <LabeledList.Item label="Target Temperature">
              <NumberInput
                animated
                value={Math.round(data.target)}
                unit="K"
                width="62px"
                minValue={Math.round(data.min)}
                maxValue={Math.round(data.max)}
                step={5}
                stepPixelSize={3}
                onDrag={(e, value) => act('target', {
                  target: value,
                })} />
            </LabeledList.Item>
            <LabeledList.Item label="Presets">
              <Button
                icon="fast-backward"
                disabled={data.target === data.min}
                title="Minimum temperature"
                onClick={() => act('target', {
                  target: data.min,
                })} />
              <Button
                icon="sync"
                disabled={data.target === data.initial}
                title="Room Temperature"
                onClick={() => act('target', {
                  target: data.initial,
                })} />
              <Button
                icon="fast-forward"
                disabled={data.target === data.max}
                title="Maximum Temperature"
                onClick={() => act('target', {
                  target: data.max,
                })} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
