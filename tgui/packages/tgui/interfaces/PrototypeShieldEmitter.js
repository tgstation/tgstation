import { toFixed } from 'common/math';
import { useBackend } from '../backend';
import { AnimatedNumber, Box, Button, LabeledList, Modal, NumberInput, Section, ProgressBar } from '../components';
import { Window } from '../layouts';

export const PrototypeShieldEmitter = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window
      width={300}
      height={400}>
      <Window.Content>
        <Section title="Controls">
          <LabeledList>
            <LabeledList.Item label="Start Machine">
              <Button
                content={data.on ? 'ON' : 'OFF'}
                color={data.on ? "green" : "red"}
                disabled={data.has_barrier}
                onClick={() => act('on')} />
            </LabeledList.Item>
            <LabeledList.Item label="Emit shields">
              <Button
                content={'Emit shields'}
                disabled={data.has_barrier || !data.on}
                onClick={() => act('emit')} />
            </LabeledList.Item>
            <LabeledList.Item label="Disable shields">
              <Button
                content={'Disable shields'}
                disabled={!data.has_barrier}
                onClick={() => act('disable')} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Dimension selector">
          <LabeledList>
            <LabeledList.Item label="Width">
              {data.width}
            </LabeledList.Item>
            <LabeledList.Item label="Height">
              {data.height}
            </LabeledList.Item>
            <LabeledList.Item label="Increase">
              <Button icon="arrow-left"
                onClick={() => act('increase_left', {
                })} />
              <Button iconRotation={-90} icon="arrow-right"
                onClick={() => act('increase_up', {
                })} />
              <Button icon="arrow-right"
                onClick={() => act('increase_right', {
                })} />
            </LabeledList.Item>
            <LabeledList.Item label="Decrease">
              <Button icon="arrow-right"
                onClick={() => act('decrease_left', {
                })} />
              <Button iconRotation={-90} icon="arrow-left"
                onClick={() => act('decrease_up', {
                })} />
              <Button icon="arrow-left"
                onClick={() => act('decrease_right', {
                })} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
