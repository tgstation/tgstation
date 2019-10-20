import { act } from '../byond';
import { AnimatedNumber, Button, LabeledList, Section } from '../components';

export const AtmosPump = props => {
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
            onClick={() => act(ref, 'power')} />
        </LabeledList.Item>
        {data.max_rate ? (
          <LabeledList.Item label="Transfer Rate">
            <Button
              icon="pencil-alt"
              content="Set"
              onClick={() => act(ref, 'rate', { rate: 'input' })} />
            <Button
              icon="plus"
              content="Max"
              disabled={data.rate === data.max_rate}
              onClick={() => act(ref, 'rate', { rate: 'max' })} />
            {' '}
            <AnimatedNumber value={parseFloat(data.rate)} />
            {' L/s'}
          </LabeledList.Item>
        ) : (
          <LabeledList.Item label="Output Pressure">
            <Button
              icon="pencil-alt"
              content="Set"
              onClick={() => act(ref, 'pressure', {pressure: 'input'})} />
            <Button
              icon="plus"
              content="Max"
              disabled={data.pressure === data.max_pressure}
              onClick={() => act(ref, 'pressure', { pressure: 'max' })} />
            {' '}
            <AnimatedNumber value={data.pressure} />
            {' kPa'}
          </LabeledList.Item>
        )}
      </LabeledList>
    </Section>
  );
};
