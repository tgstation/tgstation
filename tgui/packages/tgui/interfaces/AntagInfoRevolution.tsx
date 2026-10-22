import { useEffect, useState } from 'react';
import { Input, Section, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { useBackend } from '../backend';
import { Window } from '../layouts';
import type { Objective } from './common/Objectives';

type Head = {
  name: string;
  role: string;
};

type Info = {
  antag_name: string;
  objectives: Objective[];
  leader: BooleanLike;
  code_phrases?: string[];
  code_responses?: string[];
  heads: Head[];
  lone_wolf: BooleanLike;
  conversion_objective?: string | null;
  conversion_objective_max_length: number;
};

// Takes [a, b, c] and returns "a, b, and c"
function formatCodes(text: string[]) {
  if (text.length === 0) return '';
  if (text.length === 1) return text[0];
  if (text.length === 2) return `${text[0]} and ${text[1]}`;
  return `${text.slice(0, -1).join(', ')}, and ${text[text.length - 1]}`;
}

// These are just placeholders they don't actually get passed to the player
function randomObjectivePlaceholderText() {
  if (Math.random() <= 0.01) {
    const joke_objectives = [
      'Annoy the heads of staff as much as possible without harming them.',
      'Disguise as the heads of staff and confuse the crew.',
      'Make revolutionary artwork and vandalize the station with it.',
      'Mass produce picket signs and wave them around the station.',
      'Start a cult worshipping the proletariat.',
    ];
    return joke_objectives[Math.floor(Math.random() * joke_objectives.length)];
  }

  const objectives = [
    "Sabotage the station's power grid.",
    "Steal the Head of Personnel's pet dog.",
    "Turn the Head of Security's team against them.",
    "Waste the station's funds and resources.",
    'Blow up the Research Director with a bomb.',
    'Bribe the Quartermaster to self-exile.',
    'Capture anyone with a mindshield and have it surgically removed.',
    'Create an army of mechs to march on the bridge.',
    'Cut off the air supply to the brig.',
    'Equip your leaders with the best gear you can find.',
    'Find the remaining heads of staff and eliminate them.',
    'Follow your leaders as closely as possible.',
    'Gather weapons and armor.',
    'Go out in a blaze of glory.',
    'Lie low until we have enough numbers to strike.',
    'Occupy the bridge and hold it until the heads of staff surrender.',
    'Protect your leaders at all costs, even if it means sacrifice.',
    'Protest in front of the bridge.',
    'Rescue other revolutionaries from the brig.',
    'Rush the Captain and take his hat.',
    'Subvert the AI to betray the heads of staff.',
    'Take the Chief Medical Officer hostage.',
    'Throw the Chief Engineer into the Supermatter.',
    'Trick the heads of staff into exiling themselves.',
    'Wait for the emergency shuttle, then strike in the chaos.',
  ];
  return objectives[Math.floor(Math.random() * objectives.length)];
}

export const AntagInfoRevolution = () => {
  const { act, data } = useBackend<Info>();
  const {
    leader,
    code_phrases,
    code_responses,
    heads,
    lone_wolf,
    conversion_objective,
    conversion_objective_max_length,
  } = data;

  const [objectivePlaceholder, setObjectivePlaceholder] = useState(
    randomObjectivePlaceholderText(),
  );

  useEffect(() => {
    if (!leader) return;
    const interval = setInterval(() => {
      setObjectivePlaceholder(randomObjectivePlaceholderText());
    }, 30000);
    return () => clearInterval(interval);
  }, []);

  return (
    <Window width={400} height={leader ? 500 : 400}>
      <Window.Content>
        <Section scrollable fill>
          <Stack vertical>
            <Stack.Item textColor="red" fontSize="24px" textAlign="center">
              Viva la Revolution!
            </Stack.Item>
            <Stack.Item>
              {leader ? (
                <Stack vertical>
                  {lone_wolf ? (
                    <Stack.Item>
                      - You are a lone leader of the revolution. It is
                      recommended to act swiftly and decisively - when the
                      revolution is sufficiently large, more leaders will be
                      promoted.
                    </Stack.Item>
                  ) : (
                    <Stack.Item>
                      - There are multiple leaders of the revolution. It is
                      recommended to work together and establish a plan BEFORE
                      you start converting the crew - being outed early can
                      prove extremely detrimental.
                    </Stack.Item>
                  )}
                  <Stack.Item>
                    - Convert the crew to your cause with a flash - any flash
                    will work.
                  </Stack.Item>
                  <Stack.Item>
                    - Mindshields will prevent conversion. You can identify them
                    via the flashing blue border around their job icon.
                  </Stack.Item>
                  <Stack.Item>
                    - The revolution is lost if you and your fellow leaders are
                    all killed or exiled. Do not let that happen!
                  </Stack.Item>
                </Stack>
              ) : (
                <Stack vertical>
                  <Stack.Item>
                    - Help your cause. Do not harm your fellow freedom fighters.
                  </Stack.Item>
                  <Stack.Item>
                    - You can identify your comrades by the red "R" icons, and
                    your leaders by the blue "R" icons.
                  </Stack.Item>
                  <Stack.Item>
                    - The revolution is lost if all of your leaders are killed
                    or exiled. Do not let that happen!
                  </Stack.Item>
                </Stack>
              )}
            </Stack.Item>
            {heads.length > 0 && (
              <>
                <Stack.Divider />
                <Stack.Item>
                  <Stack vertical>
                    <Stack.Item fontSize="16px" textAlign="center">
                      You must kill or exile the heads of staff:
                    </Stack.Item>
                    {heads.map((head, i) => (
                      <Stack.Item key={`head-${i}`}>
                        - {head.name}, the {head.role}
                      </Stack.Item>
                    ))}
                  </Stack>
                </Stack.Item>
              </>
            )}
            {!!leader && (
              <>
                {!!code_phrases?.length && !!code_responses?.length && (
                  <>
                    <Stack.Divider />
                    <Stack.Item>
                      <Stack vertical>
                        <Stack.Item italic>
                          To identify your fellow leaders, use the following
                          code:
                        </Stack.Item>
                        <Stack.Item textColor="blue">
                          Phrases: {formatCodes(code_phrases)}
                        </Stack.Item>
                        <Stack.Item textColor="red">
                          Responses: {formatCodes(code_responses)}
                        </Stack.Item>
                      </Stack>
                    </Stack.Item>
                    <Stack.Divider />
                  </>
                )}
                <Stack.Divider />
                <Stack.Item>
                  <Stack vertical>
                    <Stack.Item italic>
                      Set a conversion guideline: This text is shown only to
                      newly converted revolutionaries.
                    </Stack.Item>
                    <Stack.Item>
                      <Input
                        placeholder={`Ex: ${objectivePlaceholder}`}
                        fluid
                        maxLength={conversion_objective_max_length}
                        value={conversion_objective ?? ''}
                        onEnter={(value) =>
                          act('set_conversion_objective', {
                            conversion_objective: value,
                          })
                        }
                      />
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
              </>
            )}
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
