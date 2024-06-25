import { useBackend } from '../backend';
import { Image, LabeledList, ProgressBar, Section, Stack } from '../components';
import { Window } from '../layouts';

type Data = {
  bounty_name: String;
  bounty_icon: String;
  bounty_reward: String;
  bounty_gps: String;
};

export const bountypaper = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    raptor_attack,
    raptor_health,
    raptor_speed,
    raptor_image,
    raptor_gender,
    inherited_attack,
    inherited_attack_max,
    inherited_health,
    inherited_health_max,
    raptor_happiness,
    inherited_traits,
    raptor_description,
    raptor_color,
  } = data;
  return (
    <Window title="Raptor Data" width={300} height={600} theme="bountypaper">
      <Window.Content>
        <Stack>
          <Stack.Item>
            <Box                   style={{
                    borderRight: '1px solid white',
                  }}>
              WANTED
            </Box>
          </Stack.Item>
          <Stack.Item width="33%" textAlign="center">
            <Section title="Stats">
              <LabeledList>
                <LabeledList.Item label="Health">
                  {raptor_health}
                </LabeledList.Item>
                <LabeledList.Item label="Attack">
                  {raptor_attack}
                </LabeledList.Item>
                <LabeledList.Item label="Speed">
                  {10 - raptor_speed}
                </LabeledList.Item>
                <LabeledList.Item label="Gender">
                  {raptor_gender}
                </LabeledList.Item>
              </LabeledList>
            </Section>
            <Section title="Inherit Modifiers">
              <LabeledList>
                <LabeledList.Item label="Health">
                  <ProgressBar
                    value={inherited_health}
                    maxValue={inherited_health_max}
                    ranges={{
                      good: [0.7 * inherited_health_max, inherited_health_max],
                      average: [
                        0.4 * inherited_health_max,
                        inherited_health_max,
                      ],
                      bad: [-Infinity, inherited_health_max],
                    }}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Attack">
                  <ProgressBar
                    value={inherited_attack}
                    maxValue={inherited_attack_max}
                    ranges={{
                      good: [0.7 * inherited_attack_max, inherited_attack_max],
                      average: [
                        0.4 * inherited_attack_max,
                        inherited_attack_max,
                      ],
                      bad: [-Infinity, inherited_attack_max],
                    }}
                  />
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
          <Stack.Item width="33%">
            <Section textAlign="center" title="Friendship bond">
              <Image
                mt={-7}
                src={`data:image/jpeg;base64,${raptor_happiness}`}
                height="72px"
                width="72px"
              />
            </Section>
            <Section textAlign="center" title="Inherited Traits">
              <Stack vertical>
                {inherited_traits.map((trait, index) => (
                  <Stack.Item key={index}>{trait}</Stack.Item>
                ))}
              </Stack>
            </Section>
          </Stack.Item>
        </Stack>
        <Section fill title="Desc">
          {raptor_description}
        </Section>
      </Window.Content>
    </Window>
  );
};
