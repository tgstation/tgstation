import { Fragment } from 'inferno';
import { act } from '../byond';
import { AnimatedNumber, LabeledList, Button, Section } from '../components';
import { toFixed } from 'common/math';

export const ThermoMachine = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  return (
    <Fragment>
      <Section title="Status">
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
      <Section title="Controls">
        <LabeledList>
          <LabeledList.Item label="Power">
            <Button
              icon={data.on ? 'power-off' : 'times'}
              content={data.on ? 'On' : 'Off'}
              selected={data.on}
              onClick={() => act(ref, 'power')} />
          </LabeledList.Item>
          <LabeledList.Item label="Target Temperature">
            <Button
              icon="fast-backward"
              disabled={data.target === data.min}
              onClick={() => act(ref, 'target', {
                adjust: -50,
              })} />
            <Button
              icon="backward"
              disabled={data.target === data.min}
              onClick={() => act(ref, 'target', {
                adjust: -5,
              })} />
            <Button
              icon="pencil-alt"
              onClick={() => act(ref, 'target', {
                target: 'input',
              })}>
              <AnimatedNumber
                value={data.target}
                format={value => toFixed(value, 2)} />
            </Button>
            <Button
              icon="forward"
              disabled={data.target === data.max}
              onClick={() => act(ref, 'target', {
                adjust: 5,
              })} />
            <Button
              icon="fast-forward"
              disabled={data.target === data.max}
              onClick={() => act(ref, 'target', {
                adjust: 50,
              })} />
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </Fragment>
  );
};
