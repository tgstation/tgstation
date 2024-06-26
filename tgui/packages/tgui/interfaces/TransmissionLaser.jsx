/**
 * @file
 * @copyright 2020
 * @author Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import { useBackend } from '../backend';
import {
  Box,
  Button,
  Knob,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
} from '../components';
import { formatMoney, formatSiUnit, formatPower } from '../format';
import { Window } from '../layouts';

export const TransmissionLaser = (props) => {
  const { data } = useBackend();
  const { total_earnings, name = 'Power Transmission Laser' } = data;
  return (
    <Window title="Power Transmission Laser" width="310" height="485">
      <Window.Content>
        <Status />
        <InputControls />
        <OutputControls />
        <NoticeBox success>
          Earned Credits : {total_earnings ? formatMoney(total_earnings) : 0}
        </NoticeBox>
      </Window.Content>
    </Window>
  );
};

const Status = (props) => {
  const { data } = useBackend();
  const { max_capacity, held_power, output_total, max_grid_load } = data;

  return (
    <Section title="Status">
      <LabeledList>
        <LabeledList.Item label="Reserve Power">
          {held_power ? formatSiUnit(held_power, 0, 'W') : '0 J'}
        </LabeledList.Item>
      </LabeledList>
      <ProgressBar
        mt="0.5em"
        mb="0.5em"
        ranges={{
          good: [0.8, Infinity],
          average: [0.5, 0.8],
          bad: [-Infinity, 0.5],
        }}
        value={held_power / max_capacity}
      />
      <LabeledList>
        <LabeledList.Item label="Grid Saturation" />
      </LabeledList>
      <ProgressBar
        mt="0.5em"
        ranges={{
          good: [0.8, Infinity],
          average: [0.5, 0.8],
          bad: [-Infinity, 0.5],
        }}
        value={output_total / max_grid_load}
      />
    </Section>
  );
};

const InputControls = (props) => {
  const { act, data } = useBackend();
  const {
    input_total,
    accepting_power,
    sucking_power,
    input_number,
    power_format,
  } = data;

  return (
    <Section title="Input Controls">
      <LabeledList>
        <LabeledList.Item
          label="Input Circuit"
          buttons={
            <Button
              icon="power-off"
              content={accepting_power ? 'Enabled' : 'Disabled'}
              color={accepting_power ? 'green' : 'red'}
              onClick={() => act('toggle_input')}
            />
          }
        >
          <Box
            color={
              (sucking_power && 'good') ||
              (accepting_power && 'average') ||
              'bad'
            }
          >
            {(sucking_power && 'Online') ||
              (accepting_power && 'Idle') ||
              'Offline'}
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label="Input Level">
          {input_total ? formatPower(input_total) : '0 W'}
        </LabeledList.Item>
      </LabeledList>
      <Box mt="0.5em">
        <Knob
          mr="0.5em"
          animated
          size={1.25}
          inline
          step={5}
          stepPixelSize={2}
          minValue={0}
          maxValue={999}
          value={input_number}
          onDrag={(e, set_input) => act('set_input', { set_input })}
        />
        <Button
          content={'W'}
          selected={power_format === 1}
          onClick={() => act('inputW')}
        />
        <Button
          content={'kW'}
          selected={power_format === 10 ** 3}
          onClick={() => act('inputKW')}
        />
        <Button
          content={'MW'}
          selected={power_format === 10 ** 6}
          onClick={() => act('inputMW')}
        />
        <Button
          content={'GW'}
          selected={power_format === 10 ** 9}
          onClick={() => act('inputGW')}
        />
        <Button
          content={'TW'}
          selected={power_format === 10 ** 12}
          onClick={() => act('inputTW')}
        />
        <Button
          content={'PW'}
          selected={power_format === 10 ** 15}
          onClick={() => act('inputPW')}
        />
        <Button
          content={'EW'}
          selected={power_format === 10 ** 18}
          onClick={() => act('inputEW')}
        />
        <Button
          content={'ZW'}
          selected={power_format === 10 ** 21}
          onClick={() => act('inputZW')}
        />
        <Button
          content={'YW'}
          selected={power_format === 10 ** 24}
          onClick={() => act('inputYW')}
        />
        <Button
          content={'RW'}
          selected={power_format === 10 ** 27}
          onClick={() => act('inputRW')}
        />
        <Button
          content={'QW'}
          selected={power_format === 10 ** 30}
          onClick={() => act('inputQW')}
        />
      </Box>
    </Section>
  );
};

const OutputControls = (props) => {
  const { act, data } = useBackend();
  const {
    output_total,
    firing,
    accepting_power,
    output_number,
    output_multiplier,
  } = data;

  return (
    <Section title="Output Controls">
      <LabeledList>
        <LabeledList.Item
          label="Laser Circuit"
          buttons={
            <Button
              icon="power-off"
              content={firing ? 'Enabled' : 'Disabled'}
              color={firing ? 'green' : 'red'}
              onClick={() => act('toggle_output')}
            />
          }
        >
          <Box
            color={
              (firing && 'good') || (accepting_power && 'average') || 'bad'
            }
          >
            {(firing && 'Online') || (accepting_power && 'Idle') || 'Offline'}
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label="Output Level">
          {output_total
            ? output_total < 0
              ? '-' + formatPower(Math.abs(output_total))
              : formatPower(output_total)
            : '0 W'}
        </LabeledList.Item>
      </LabeledList>
      <Box mt="0.5em">
        <Knob
          mr="0.5em"
          size={1.25}
          animated
          inline
          step={5}
          stepPixelSize={2}
          minValue={0}
          maxValue={999}
          ranges={{ bad: [-Infinity, -1] }}
          value={output_number}
          onDrag={(e, set_output) => act('set_output', { set_output })}
        />
        <Button
          content={'MW'}
          selected={output_multiplier === 10 ** 6}
          onClick={() => act('outputMW')}
        />
        <Button
          content={'GW'}
          selected={output_multiplier === 10 ** 9}
          onClick={() => act('outputGW')}
        />
        <Button
          content={'TW'}
          selected={output_multiplier === 10 ** 12}
          onClick={() => act('outputTW')}
        />
        <Button
          content={'PW'}
          selected={output_multiplier === 10 ** 15}
          onClick={() => act('outputPW')}
        />
        <Button
          content={'EW'}
          selected={output_multiplier === 10 ** 18}
          onClick={() => act('outputEW')}
        />
        <Button
          content={'ZW'}
          selected={output_multiplier === 10 ** 21}
          onClick={() => act('outputZW')}
        />
        <Button
          content={'YW'}
          selected={output_multiplier === 10 ** 24}
          onClick={() => act('outpuYW')}
        />
        <Button
          content={'RW'}
          selected={output_multiplier === 10 ** 27}
          onClick={() => act('outputRW')}
        />
        <Button
          content={'QW'}
          selected={output_multiplier === 10 ** 30}
          onClick={() => act('outputQW')}
        />
      </Box>
    </Section>
  );
};
