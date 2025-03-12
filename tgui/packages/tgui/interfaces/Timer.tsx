import { Button, Section } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  minutes: number;
  seconds: number;
  timing: BooleanLike;
  loop: BooleanLike;
};

export const Timer = (props) => {
  const { act, data } = useBackend<Data>();
  const { timing, loop } = data;

  return (
    <Window width={275} height={115}>
      <Window.Content>
        <Section
          title="Timing Unit"
          buttons={
            <>
              <Button
                icon={'sync'}
                content={loop ? 'Repeating' : 'Repeat'}
                selected={loop}
                onClick={() => act('repeat')}
              />
              <Button
                icon={'clock-o'}
                content={timing ? 'Stop' : 'Start'}
                selected={timing}
                onClick={() => act('time')}
              />
            </>
          }
        >
          <TimerContent />
        </Section>
      </Window.Content>
    </Window>
  );
};

/** Displays a few more buttons to control the timer. */
const TimerContent = (props) => {
  const { act, data } = useBackend<Data>();
  const { minutes, seconds, timing } = data;

  return (
    <>
      <Button
        icon="fast-backward"
        disabled={timing}
        onClick={() => act('input', { adjust: -30 })}
      />
      <Button
        icon="backward"
        disabled={timing}
        onClick={() => act('input', { adjust: -1 })}
      />
      {String(minutes).padStart(2, '0')}:{String(seconds).padStart(2, '0')}{' '}
      <Button
        icon="forward"
        disabled={timing}
        onClick={() => act('input', { adjust: 1 })}
      />
      <Button
        icon="fast-forward"
        disabled={timing}
        onClick={() => act('input', { adjust: 30 })}
      />
    </>
  );
};
