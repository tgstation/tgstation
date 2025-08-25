import { useAtom } from 'jotai';
import { Box, Button, Divider } from 'tgui-core/components';
import { tabAtom } from '.';
import { Tab } from './types';

export const lineHeightToc = '30.6px';

export function TableOfContents(props) {
  const [_tabIndex, setTabIndex] = useAtom(tabAtom);

  return (
    <Box textAlign="center">
      <Button lineHeight={lineHeightToc} fluid icon="pen" disabled>
        Name Enscription
      </Button>

      <Button lineHeight={lineHeightToc} fluid icon="clipboard" disabled>
        Table of Contents
      </Button>

      <Divider />
      <Button
        lineHeight={lineHeightToc}
        fluid
        icon="fire"
        onClick={() => setTabIndex(Tab.Offensive)}
      >
        Deadly Evocations
      </Button>

      <Button
        lineHeight={lineHeightToc}
        fluid
        icon="shield-alt"
        onClick={() => setTabIndex(Tab.Defensive)}
      >
        Defensive Evocations
      </Button>
      <Divider />
      <Button
        lineHeight={lineHeightToc}
        fluid
        icon="globe-americas"
        onClick={() => setTabIndex(Tab.Mobility)}
      >
        Magical Transportation
      </Button>
      <Button
        lineHeight={lineHeightToc}
        fluid
        icon="users"
        onClick={() => setTabIndex(Tab.Assistance)}
      >
        Assistance and Summoning
      </Button>
      <Divider />
      <Button
        lineHeight={lineHeightToc}
        fluid
        icon="crown"
        onClick={() => setTabIndex(Tab.Challenges)}
      >
        Challenges
      </Button>
      <Button
        lineHeight={lineHeightToc}
        fluid
        icon="magic"
        onClick={() => setTabIndex(Tab.Rituals)}
      >
        Rituals
      </Button>
      <Divider />
      <Button
        lineHeight={lineHeightToc}
        fluid
        icon="thumbs-up"
        onClick={() => setTabIndex(Tab.Loadouts)}
      >
        Wizard Approved Loadouts
      </Button>
      <Button
        lineHeight={lineHeightToc}
        fluid
        icon="dice"
        onClick={() => setTabIndex(Tab.Randomize)}
      >
        Arcane Randomizer
      </Button>
      <Divider />
      <Button
        lineHeight={lineHeightToc}
        fluid
        icon="cog"
        onClick={() => setTabIndex(Tab.Perks)}
      >
        Perks
      </Button>
    </Box>
  );
}
