import { useAtom } from 'jotai';
import { Box, NoticeBox, Stack } from 'tgui-core/components';
import { useBackend } from '../../backend';
import { spellSearchAtom } from '.';
import { SpellTabDisplay } from './SpellTabDisplay';
import type { SpellbookData, SpellEntry } from './types';

export function SearchSpells(props) {
  const { data } = useBackend<SpellbookData>();
  const [spellSearch] = useAtom(spellSearchAtom);
  const { entries } = data;

  const searchStatement = spellSearch.toLowerCase();

  let filteredEntries: SpellEntry[] = [];

  if (searchStatement === 'robeless') {
    // Lets you just search for robeless spells, you're welcome mindswap-bros
    filteredEntries = entries.filter((entry) => !entry.requires_wizard_garb);
  } else {
    filteredEntries = entries.filter(
      (entry) =>
        entry.name.toLowerCase().includes(searchStatement) ||
        // Unsure about including description. Wizard spell descriptions
        // are painfully original and use the same verbiage often,
        // which may both be a benefit and a curse
        entry.desc
          .toLowerCase()
          .includes(searchStatement) ||
        // Also opting to include category
        // so you can search "rituals" to see them all at once
        entry.cat
          .toLowerCase()
          .includes(searchStatement),
    );
  }

  if (filteredEntries.length === 0) {
    return (
      <Stack width="100%" vertical>
        <Stack.Item>
          <NoticeBox>No spells found!</NoticeBox>
        </Stack.Item>
        <Stack.Item>
          <Box italic align="center" color="lightgrey">
            Search tip: Searching "Robeless" will only show you spells that
            don't require wizard garb!
          </Box>
        </Stack.Item>
      </Stack>
    );
  }
  return (
    <SpellTabDisplay
      tabSpells={filteredEntries}
      cooldownOffset={32}
      pointOffset={84}
    />
  );
}
