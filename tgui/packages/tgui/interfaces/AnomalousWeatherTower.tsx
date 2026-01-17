import { useState } from 'react';
import { useBackend } from 'tgui/backend';
import {
  Box,
  Button,
  Dropdown,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { Window } from '../layouts';

type Weather = {
  id: string;
  name: string;
  desc: string;
};

type Data = {
  core_charges: number;
  max_core_charges: number;
  weather_charge_cost: number;
  can_summon_weather: BooleanLike;
  can_clear_weather: BooleanLike;
  summonable_weather_types: Weather[];
  active_weather_on_z: Weather[];
};

function formatCharges(charges: number, max_charges: number) {
  return `${(charges / max_charges) * 100}%`;
}

export const AnomalousWeatherTower = () => {
  const { act, data } = useBackend<Data>();
  const {
    core_charges,
    max_core_charges = 8,
    weather_charge_cost,
    can_summon_weather,
    can_clear_weather,
    summonable_weather_types,
    active_weather_on_z,
  } = data;

  const [selectedWeather, setSelectedWeather] = useState(
    summonable_weather_types[0],
  );

  const height = 400 + active_weather_on_z.length * 30;

  return (
    <Window width={250} height={height}>
      <Window.Content>
        <Stack vertical>
          <Stack.Item>
            <Section align="center">
              <Box fontSize="20px">Core charge: </Box>
              <Box
                fontSize="24px"
                color={
                  core_charges > 4
                    ? 'green'
                    : core_charges > 2
                      ? 'yellow'
                      : 'red'
                }
              >
                {formatCharges(core_charges, max_core_charges)}{' '}
              </Box>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section title="Active Weather">
              {active_weather_on_z.length > 0 ? (
                active_weather_on_z.map((weather) => (
                  <Stack.Item key={weather.id}>
                    <Stack align="center">
                      <Stack.Item grow>{weather.name}</Stack.Item>
                      <Stack.Item>
                        <Button
                          onClick={() =>
                            act('clear_weather', { weather_ref: weather.id })
                          }
                          icon="times"
                          color="red"
                          disabled={!can_clear_weather}
                          tooltip={
                            can_clear_weather
                              ? undefined
                              : 'Weather inhibitors are recharging.'
                          }
                        />
                      </Stack.Item>
                    </Stack>
                  </Stack.Item>
                ))
              ) : (
                <Stack.Item>
                  <NoticeBox>None</NoticeBox>
                </Stack.Item>
              )}
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section title="Summon Weather" fill>
              <Stack vertical fill>
                <Stack.Item>
                  <Dropdown
                    options={summonable_weather_types.map(
                      (weather) => weather.name,
                    )}
                    selected={selectedWeather.name}
                    onSelected={(weatherName) => {
                      const weather = summonable_weather_types.find(
                        (w) => w.name === weatherName,
                      );
                      if (weather) setSelectedWeather(weather);
                    }}
                  />
                </Stack.Item>
                <Stack.Item className="AnomalyTower__HazardBg" align="center">
                  <Button
                    color="red"
                    m={1}
                    className="AnomalyTower__HazardButton"
                    align="center"
                    onClick={() =>
                      act('summon_weather', {
                        weather_type: selectedWeather.id,
                      })
                    }
                    disabled={
                      !can_summon_weather || core_charges < weather_charge_cost
                    }
                    tooltip={
                      core_charges < weather_charge_cost
                        ? 'Not enough charges to summon weather.'
                        : can_summon_weather
                          ? undefined
                          : 'Weather coils are recharging.'
                    }
                  />
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
