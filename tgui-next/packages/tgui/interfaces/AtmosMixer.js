import { act } from '../byond';
import { AnimatedNumber, Button, LabeledList, Section } from '../components';

export const AtmosMixer = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  return (
    <Section>
      <LabeledList>
        <LabeledList.Item label="Power">
          <Button
            icon={data.on ? 'power-off' : 'times'}
            content={data.on ? 'On' : 'Off'}
            selected={data.on}
            onClick={() => act(ref, 'power')}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Output Pressure">
          <Button
            icon="pencil-alt"
            content="Set"
            onClick={() => act(ref, 'pressure', { pressure: 'input' })}
          />
          <Button
            icon="plus"
            content="Max"
            disabled={data.set_pressure === data.max_pressure}
            onClick={() => act(ref, 'pressure', { pressure: 'max' })}
          />
          {' '}
          <AnimatedNumber value={data.set_pressure} />
          {' kPa'}
        </LabeledList.Item>
        <LabeledList.Item label="Node 1">
          <Button
            icon="fast-backward"
            disabled={data.node1_concentration === 0}
            onClick={() => act(ref, 'node1', { concentration: -0.1 })}
          />
          <Button
            icon="backward"
            disabled={data.node1_concentration === 0}
            onClick={() => act(ref, 'node1', { concentration: -0.01 })}
          />
          <Button
            icon="forward"
            disabled={data.node1_concentration === 100}
            onClick={() => act(ref, 'node1', { concentration: 0.01 })}
          />
          <Button
            icon="fast-forward"
            disabled={data.node1_concentration === 100}
            onClick={() => act(ref, 'node1', { concentration: 0.1 })}
          />
          {' '}
          <AnimatedNumber value={data.node1_concentration} />
          {'%'}
        </LabeledList.Item>
        <LabeledList.Item label="Node 2">
          <Button
            icon="fast-backward"
            disabled={data.node2_concentration === 0}
            onClick={() => act(ref, 'node2', {
              concentration: -0.1,
            })} />
          <Button
            icon="backward"
            disabled={data.node2_concentration === 0}
            onClick={() => act(ref, 'node2', {
              concentration: -0.01,
            })} />
          <Button
            icon="forward"
            disabled={data.node2_concentration === 100}
            onClick={() => act(ref, 'node2', {
              concentration: 0.01,
            })} />
          <Button
            icon="fast-forward"
            disabled={data.node2_concentration === 100}
            onClick={() => act(ref, 'node2', {
              concentration: 0.1,
            })} />
          {' '}
          <AnimatedNumber value={data.node2_concentration} />
          {'%'}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
