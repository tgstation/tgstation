import { useBackend } from 'tgui/backend';
import { Button, Section, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { Window } from '../layouts';

type Weather = {
  id: string;
  name: string;
  desc: string;
};

type Data = {
  core_charges: number;
  weather_charge_cost: number;
  can_summon_weather: BooleanLike;
  can_clear_weather: BooleanLike;
  summonable_weather_types: string[];
  active_weather_on_z: Weather[];
};

export const AnomalousWeatherTower = () => {
  const { act, data } = useBackend<Data>();
  const {
    core_charges,
    weather_charge_cost,
    can_summon_weather,
    can_clear_weather,
    summonable_weather_types,
    active_weather_on_z,
  } = data;

  return (
    <Window>
      <Window.Content>
        <Stack vertical>
          <Stack.Item>
            <Section title="Active Weather">
              {active_weather_on_z.length > 0 ? (
                active_weather_on_z.map((weather) => (
                  <Stack.Item key={weather.id}>
                    <Stack>
                      <Stack.Item grow>{weather.name}</Stack.Item>
                      <Stack.Item>
                        <Button.Confirm
                          onClick={() =>
                            act('clear_weather', { weather_id: weather.id })
                          }
                          disabled={!can_clear_weather}
                        >
                          Stop
                        </Button.Confirm>
                      </Stack.Item>
                    </Stack>
                  </Stack.Item>
                ))
              ) : (
                <Stack.Item>None</Stack.Item>
              )}
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section title="Summon Weather">Placeholder</Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
