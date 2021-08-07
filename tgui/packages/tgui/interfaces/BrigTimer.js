import { useBackend } from '../backend';
import { Button, Section } from '../components';
import { Window } from '../layouts';

export const BrigTimer = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window
      width={300}
      height={138}>
      <Window.Content scrollable>
        <Section
          title="Cell Timer"
          buttons={(
            <>
              <Button
                icon="clock-o"
                content={data.timing ? 'Stop' : 'Start'}
                selected={data.timing}
                onClick={() => act(data.timing ? 'stop' : 'start')} />
              <Button
                icon="lightbulb-o"
                content={data.flash_charging ? 'Recharging' : 'Flash'}
                disabled={data.flash_charging}
                onClick={() => act('flash')} />
            </>
          )}>
          <Button
            icon="fast-backward"
            onClick={() => act('time', { adjust: -600 })} />
          <Button
            icon="backward"
            onClick={() => act('time', { adjust: -100 })} />
          {' '}
          {String(data.minutes).padStart(2, '0')}:
          {String(data.seconds).padStart(2, '0')}
          {' '}
          <Button
            icon="forward"
            onClick={() => act('time', { adjust: 100 })} />
          <Button
            icon="fast-forward"
            onClick={() => act('time', { adjust: 600 })} />
          <br />
          <Button
            icon="hourglass-start"
            content="Short"
            onClick={() => act('preset', { preset: 'short' })} />
          <Button
            icon="hourglass-start"
            content="Medium"
            onClick={() => act('preset', { preset: 'medium' })} />
          <Button
            icon="hourglass-start"
            content="Long"
            onClick={() => act('preset', { preset: 'long' })} />
        </Section>
      </Window.Content>
    </Window>
  );
};
