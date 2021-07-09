import { useBackend } from '../backend';
import { Button, Section } from '../components';
import { Window } from '../layouts';

export const Timer = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    minutes,
    seconds,
    timing,
    loop,
  } = data;
  return (
    <Window
      width={275}
      height={115}>
      <Window.Content>
        <Section
          title="Timing Unit"
          buttons={(
            <>
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
            </>
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
      </Window.Content>
    </Window>
  );
};
