import { BooleanLike } from 'common/react';

import { useBackend } from '../backend';
import { Box, Button, Section } from '../components';
import { Window } from '../layouts';

type Data = {
  scanning: BooleanLike;
  target: BooleanLike;
};

export const Health = (props) => {
  const { act, data } = useBackend<Data>();
  const { scanning, target } = data;

  return (
    <Window width={310} height={115}>
      <Window.Content>
        <Section
          title="Health Sensor"
          buttons={
            <>
              <Button
                icon={scanning ? 'power-off' : 'times'}
                content={scanning ? 'On' : 'Off'}
                selected={scanning}
                onClick={() => act('scanning')}
              />
              <Button
                icon={target ? 'skull' : 'heartbeat'}
                content={target ? 'Checking for Death' : 'Checking for Crit'}
                selected={target}
                onClick={() => act('alarm_health')}
              />
            </>
          }
        >
          <Box />
        </Section>
      </Window.Content>
    </Window>
  );
};
