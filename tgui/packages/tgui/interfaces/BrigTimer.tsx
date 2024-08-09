import { Button, Section } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  timing: BooleanLike;
  minutes: number;
  seconds: number;
  flash_charging: BooleanLike;
};

export const BrigTimer = (props) => {
  const { act, data } = useBackend<Data>();
  const { timing, minutes, seconds, flash_charging } = data;
  return (
    <Window width={350} height={138}>
      <Window.Content scrollable>
        <Section
          title="Cell Timer"
          buttons={
            <>
              <Button
                icon="clock-o"
                content={timing ? 'Stop' : 'Start'}
                selected={timing}
                onClick={() => act(timing ? 'stop' : 'start')}
              />
              <Button
                icon="lightbulb-o"
                content={flash_charging ? 'Recharging' : 'Flash'}
                disabled={flash_charging}
                onClick={() => act('flash')}
              />
            </>
          }
        >
          <Button
            icon="fast-backward"
            onClick={() => act('time', { adjust: -600 })}
          />
          <Button
            icon="backward"
            onClick={() => act('time', { adjust: -100 })}
          />{' '}
          {String(minutes).padStart(2, '0')}:{String(seconds).padStart(2, '0')}{' '}
          <Button icon="forward" onClick={() => act('time', { adjust: 100 })} />
          <Button
            icon="fast-forward"
            onClick={() => act('time', { adjust: 600 })}
          />
          <br />
          <Button
            icon="hourglass-end"
            content="Mischief"
            onClick={() => act('preset', { preset: 'mischief' })}
          />
          <Button
            icon="hourglass-half"
            content="Misdemeanor"
            onClick={() => act('preset', { preset: 'misdemeanor' })}
          />
          <Button
            icon="hourglass-start"
            content="Felony"
            onClick={() => act('preset', { preset: 'felony' })}
          />
        </Section>
      </Window.Content>
    </Window>
  );
};
