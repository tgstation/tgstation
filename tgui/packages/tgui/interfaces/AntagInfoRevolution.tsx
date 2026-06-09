import { Section, Stack } from 'tgui-core/components';
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
};

// Takes [a, b, c] and returns "a, b, and c"
function formatCodes(text: string[]) {
  if (text.length === 0) return '';
  if (text.length === 1) return text[0];
  if (text.length === 2) return `${text[0]} and ${text[1]}`;
  return `${text.slice(0, -1).join(', ')}, and ${text[text.length - 1]}`;
}

export const AntagInfoRevolution = () => {
  const { data } = useBackend<Info>();
  const { leader, code_phrases, code_responses, heads, lone_wolf } = data;
  return (
    <Window width={400} height={400}>
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
            {code_phrases?.length && code_responses?.length && (
              <>
                <Stack.Divider />
                <Stack.Item>
                  <Stack vertical>
                    <Stack.Item italic>
                      To identify your fellow leaders, use the following code:
                    </Stack.Item>
                    <Stack.Item textColor="blue">
                      Phrases: {formatCodes(code_phrases)}
                    </Stack.Item>
                    <Stack.Item textColor="red">
                      Responses: {formatCodes(code_responses)}
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
