import { Box, Icon, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  help_text: string;
};

const DEFAULT_HELP = `No information available! Ask for assistance if needed.`;

const boxHelp = [
  {
    color: 'purple',
    text: 'Study the area and do what needs to be done to recover the crate. Pay close attention to domain information and context clues.',
    icon: 'search-location',
    title: 'Search',
  },
  {
    color: 'green',
    text: 'Bring the crate to the designated sending location in the safehouse. The area may seem out of place. Examine the safehouse to find it.',
    icon: 'boxes',
    title: 'Recover',
  },
  {
    color: 'blue',
    text: 'The ladder represents the safest way to disconnect before the cache is recovered. Should your connection sever, the netpod offers limited resuscitation potential.',
    icon: 'plug',
    title: 'Disconnect',
  },
  {
    color: 'yellow',
    text: 'While connected, you are somewhat safe from environmental hazards and intrusions, but not completely. Pay close attention to alerts.',
    icon: 'id-badge',
    title: 'Security',
  },
  {
    color: 'gold',
    text: 'Generating avatars costs tremendous bandwidth. Do not waste them.',
    icon: 'coins',
    title: 'Limited Attempts',
  },
  {
    color: 'red',
    text: 'Remember that you are physically linked to this presence. You are a foreign body in a hostile environment. It will attempt to forcefully eject you.',
    icon: 'skull-crossbones',
    title: 'Realized Danger',
  },
] as const;

export const AvatarHelp = (props) => {
  const { data } = useBackend<Data>();
  const { help_text = DEFAULT_HELP } = data;

  return (
    <Window title="Domain Information" width={600} height={600}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item grow>
            <Section
              color="good"
              fill
              scrollable
              title="Welcome to the Virtual Domain."
            >
              {help_text}
            </Section>
          </Stack.Item>
          <Stack.Item grow={4}>
            <Stack fill vertical>
              <Stack.Item grow>
                <Stack fill>
                  {[0, 1].map((i) => (
                    <BoxHelp index={i} key={i} />
                  ))}
                </Stack>
              </Stack.Item>
              <Stack.Item grow>
                <Stack fill>
                  {[2, 3].map((i) => (
                    <BoxHelp index={i} key={i} />
                  ))}
                </Stack>
              </Stack.Item>
              <Stack.Item grow>
                <Stack fill>
                  {[4, 5].map((i) => (
                    <BoxHelp index={i} key={i} />
                  ))}
                </Stack>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

// I wish I had media queries
const BoxHelp = (props: { index: number }) => {
  const { index } = props;

  return (
    <Stack.Item grow>
      <Section
        color="label"
        fill
        minHeight={10}
        title={
          <Stack align="center">
            <Icon
              color={boxHelp[index].color}
              mr={1}
              name={boxHelp[index].icon}
            />
            <Box>{boxHelp[index].title}</Box>
          </Stack>
        }
      >
        {boxHelp[index].text}
      </Section>
    </Stack.Item>
  );
};
