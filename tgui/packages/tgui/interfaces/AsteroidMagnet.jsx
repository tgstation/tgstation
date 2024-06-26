// THIS IS A MONKESTATION UI FILE

import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const AsteroidMagnet = (props) => {
  return (
    <Window
      title="Asteroid Magnetic Traction computer"
      width="400"
      height="485"
    >
      <Window.Content>
        <InputX />
        <InputY />
        <PingButton />
        <AsteroidSelector />
      </Window.Content>
    </Window>
  );
};

const InputX = (props) => {
  const { act, data } = useBackend();
  const { coords_x } = data;

  return (
    <Section title="X coordinate control">
      <LabeledList>
        <LabeledList.Item label="X coordinates: ">{coords_x}</LabeledList.Item>
      </LabeledList>
      <Box mt="0.5em">
        <Button
          content={'-100'}
          onClick={() => act('Change X Coordinates', { Position_Change: -100 })}
        />
        <Button
          content={'-10'}
          onClick={() => act('Change X Coordinates', { Position_Change: -10 })}
        />
        <Button
          content={'-1'}
          onClick={() => act('Change X Coordinates', { Position_Change: -1 })}
        />
        <Button
          content={'Reset'}
          onClick={() => act('Change X Coordinates', { Position_Change: 0 })}
        />
        <Button
          content={'+1'}
          onClick={() => act('Change X Coordinates', { Position_Change: 1 })}
        />
        <Button
          content={'+10'}
          onClick={() => act('Change X Coordinates', { Position_Change: 10 })}
        />
        <Button
          content={'+100'}
          onClick={() => act('Change X Coordinates', { Position_Change: 100 })}
        />
      </Box>
    </Section>
  );
};

const InputY = (props) => {
  const { act, data } = useBackend();
  const { coords_y } = data;

  return (
    <Section title="Y coordinate control">
      <LabeledList>
        <LabeledList.Item label="Y coordinates: ">{coords_y}</LabeledList.Item>
      </LabeledList>
      <Box mt="0.5em">
        <Button
          content={'-100'}
          onClick={() => act('Change Y Coordinates', { Position_Change: -100 })}
        />
        <Button
          content={'-10'}
          onClick={() => act('Change Y Coordinates', { Position_Change: -10 })}
        />
        <Button
          content={'-1'}
          onClick={() => act('Change Y Coordinates', { Position_Change: -1 })}
        />
        <Button
          content={'Reset'}
          onClick={() => act('Change Y Coordinates', { Position_Change: 0 })}
        />
        <Button
          content={'+1'}
          onClick={() => act('Change Y Coordinates', { Position_Change: 1 })}
        />
        <Button
          content={'+10'}
          onClick={() => act('Change Y Coordinates', { Position_Change: 10 })}
        />
        <Button
          content={'+100'}
          onClick={() => act('Change Y Coordinates', { Position_Change: 100 })}
        />
      </Box>
    </Section>
  );
};

const PingButton = (props) => {
  const { act, data } = useBackend();
  const { ping_result, Auto_pinging } = data;

  return (
    <Section title="Ping system">
      <LabeledList>
        <LabeledList.Item label="Ping result: ">{ping_result}</LabeledList.Item>
      </LabeledList>
      <Box mt="0.5em">
        <Button
          content={Auto_pinging ? 'Disable Auto-Ping' : 'Enable Auto-Ping'}
          color={Auto_pinging ? 'green' : 'red'}
          onClick={() => act('TogglePinging')}
        />
        <Button content={'Ping the asteroid'} onClick={() => act('ping')} />
      </Box>
    </Section>
  );
};

const AsteroidSelector = (props) => {
  const { act, data } = useBackend();
  const { asteroids } = data;

  return (
    <Section title="Located asteroids">
      {asteroids.length > 0 && (
        <LabeledList>
          {asteroids.map((asteroids) => (
            <LabeledList.Item
              key={asteroids.name}
              label={asteroids.name}
              buttons={
                <Button
                  content={'Summon asteroid'}
                  color={'green'}
                  onClick={() =>
                    act('select', { asteroid_reference: asteroids.ref })
                  }
                />
              }
            />
          ))}
        </LabeledList>
      )}
    </Section>
  );
};
