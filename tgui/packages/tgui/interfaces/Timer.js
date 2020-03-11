import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Button, Section } from '../components';

export const Timer = props => {
  const { act, data } = useBackend(props);
  const {
    minutes,
    seconds,
    timing,
    loop,
  } = data;
  return (
    <Section
      title="Timing Unit"
      buttons={(
        <Fragment>
          <Button
            icon={'sync'}
            content={loop ? 'Repeating' : 'Repeat'}
            selected={loop}
            onClick={() => act('repeat')} />
          <Button
            icon={"clock-o"}
            content={timing ? 'Stop' : 'Start'}
            selected={timing}
            onClick={() => act('time')} />
        </Fragment>
      )}>
      <Button
        icon="fast-backward"
        disabled={timing}
        onClick={() => act('input', { adjust: -30 })} />
      <Button
        icon="backward"
        disabled={timing}
        onClick={() => act('input', { adjust: -1 })} />
      {' '}
      {String(minutes).padStart(2, '0')}:
      {String(seconds).padStart(2, '0')}
      {' '}
      <Button
        icon="forward"
        disabled={timing}
        onClick={() => act('input', { adjust: 1 })} />
      <Button
        icon="fast-forward"
        disabled={timing}
        onClick={() => act('input', { adjust: 30 })} />
    </Section>
  );
};
