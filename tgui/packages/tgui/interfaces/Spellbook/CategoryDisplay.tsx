import { Box, Dimmer, Icon, Stack } from 'tgui-core/components';
import { useBackend } from '../../backend';
import { SpellTabDisplay } from './SpellTabDisplay';
import type { SpellbookData, TabType } from './types';

type Props = {
  activeCat: TabType;
};

export function CategoryDisplay(props: Props) {
  const { data } = useBackend<SpellbookData>();
  const { entries } = data;
  const { activeCat } = props;

  const tabSpells = entries.filter((entry) => entry.cat === activeCat.title);

  return (
    <>
      {!!activeCat.locked && <LockedPage />}
      <Stack vertical>
        {activeCat.blurb && (
          <Stack.Item>
            <Box textAlign="center" bold height="30px">
              {activeCat.blurb}
            </Box>
          </Stack.Item>
        )}
        <Stack.Item>
          {activeCat.component?.() || (
            <SpellTabDisplay tabSpells={tabSpells} pointOffset={38} />
          )}
        </Stack.Item>
      </Stack>
    </>
  );
}

function LockedPage(props) {
  return (
    <Dimmer>
      <Stack vertical>
        <Stack.Item>
          <Icon color="purple" name="lock" size={10} />
        </Stack.Item>
        <Stack.Item fontSize="18px" color="purple">
          The Wizard Federation has locked this page.
        </Stack.Item>
      </Stack>
    </Dimmer>
  );
}
