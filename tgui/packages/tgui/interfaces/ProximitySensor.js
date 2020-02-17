import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Button, LabeledList, Section } from '../components';

export const ProximitySensor = props => {
  const { act, data } = useBackend(props);
  const {
    minutes,
    seconds,
    timing,
    scanning,
    sensitivity,
  } = data;
  return (
    <Fragment>
      <Section>
        <LabeledList>
          <LabeledList.Item label="Status">
            <Button
              icon={scanning ? 'lock' : 'unlock'}
              content={scanning ? 'Armed' : 'Not Armed'}
              selected={scanning}
              onClick={() => act('scanning')} />
          </LabeledList.Item>
          <LabeledList.Item label="Detection Range">
            <Button
              icon="backward"
              disabled={scanning}
              onClick={() => act('sense', { range: -1 })} />
            {' '}
            {String(sensitivity).padStart(1, '1')}
            {' '}
            <Button
              icon="forward"
              disabled={scanning}
              onClick={() => act('sense', { range: 1 })} />
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section
        title="Auto Arm"
        buttons={(
          <Button
            icon={"clock-o"}
            content={timing ? 'Stop' : 'Start'}
            selected={timing}
            disabled={scanning}
            onClick={() => act('time')} />
        )}>
        <Button
          icon="fast-backward"
          disabled={scanning || timing}
          onClick={() => act('input', { adjust: -30 })} />
        <Button
          icon="backward"
          disabled={scanning || timing}
          onClick={() => act('input', { adjust: -1 })} />
        {' '}
        {String(minutes).padStart(2, '0')}:
        {String(seconds).padStart(2, '0')}
        {' '}
        <Button
          icon="forward"
          disabled={scanning || timing}
          onClick={() => act('input', { adjust: 1 })} />
        <Button
          icon="fast-forward"
          disabled={scanning || timing}
          onClick={() => act('input', { adjust: 30 })} />
      </Section>
    </Fragment>
  );
};
