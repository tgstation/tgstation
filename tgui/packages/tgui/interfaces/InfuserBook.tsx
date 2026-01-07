import { chunk, range } from 'es-toolkit';
import { useState } from 'react';
import {
  BlockQuote,
  Box,
  Button,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Entry = {
  name: string;
  infuse_mob_name: string;
  desc: string;
  threshold_desc: string;
  qualities: string[];
  tier: number;
};

type DnaInfuserData = {
  entries: Entry[];
};

type BookPosition = {
  chapter: number;
  pageInChapter: number;
};

type TierData = {
  desc: string;
  icon: string;
  name: string;
};

const PAGE_HEIGHT = 30;

const TIER2TIERDATA: TierData[] = [
  {
    name: 'Lesser Mutant',
    desc: `
      Lesser Mutants usually have a smaller list of potential mutations, and
      do not have bonuses for infusing many organs. Common species, cosmetics,
      and things of that sort are here. Always available!
    `,
    icon: 'circle-o',
  },
  {
    name: 'Regular Mutant',
    desc: `
      Regular Mutants all have bonuses for infusing DNA into yourself, and are
      common enough to find consistently in a shift. Always available!
    `,
    icon: 'circle-half-stroke',
  },
  {
    name: 'Greater Mutant',
    desc: `
      Greater Mutants have stronger upsides and downsides along with their
      bonus, and are harder to find in a shift. Must be unlocked by first
      unlocking a DNA Mutant bonus of a lower tier.
    `,
    icon: 'circle',
  },
  {
    name: 'Abberation',
    desc: `
      We've been able to get stronger mutants out of vatgrown specimen,
      henceforth named "Abberations". Abberations have either strong utility
      purpose, anomalous qualities, or deadly capabilities.
    `,
    icon: 'teeth',
  },
];

export const InfuserBook = (props) => {
  const { data, act } = useBackend<DnaInfuserData>();
  const { entries } = data;

  const [bookPosition, setBookPosition] = useState({
    chapter: 0,
    pageInChapter: 0,
  });
  const { chapter, pageInChapter } = bookPosition;

  const paginatedEntries = paginateEntries(entries);

  const currentEntry = paginatedEntries[chapter][pageInChapter];

  const switchChapter = (newChapter) => {
    if (chapter === newChapter) {
      return;
    }
    setBookPosition({ chapter: newChapter, pageInChapter: 0 });
    act('play_flip_sound'); // just so we can play a sound fx on page turn
  };

  const setPage = (newPage) => {
    const newBookPosition: BookPosition = { ...bookPosition };
    if (newPage < 0) {
      if (newBookPosition.chapter === 0) {
        return;
      }
      newBookPosition.chapter = chapter - 1;
      newBookPosition.pageInChapter = paginatedEntries[chapter - 1].length - 1;
      if (newBookPosition.pageInChapter < 0) {
        newBookPosition.pageInChapter = 0;
      }
    } else if (newPage > paginatedEntries[chapter].length - 1) {
      if (newBookPosition.chapter === 3) {
        return;
      } else {
        newBookPosition.pageInChapter = 0;
        newBookPosition.chapter = chapter + 1;
      }
    } else {
      newBookPosition.pageInChapter = newPage;
    }
    setBookPosition(newBookPosition);
    act('play_flip_sound'); // just so we can play a sound fx on page turn
  };

  const tabs = [
    'Introduction',
    'Tier 0 - Lesser Mutants',
    'Tier 1 - Regular Mutants',
    'Tier 2 - Greater Mutants',
    'Tier 3 - Abberations - RESTRICTED',
  ];

  const paginatedTabs = chunk(tabs, 3);

  const restrictedNext = chapter === 3 && pageInChapter === 0;

  return (
    <Window title="DNA Infusion Manual" width={620} height={500}>
      <Window.Content>
        <Stack vertical>
          <Stack.Item mb={-1}>
            {paginatedTabs.map((tabRow, i) => (
              <Tabs height="30px" mb="0px" fill fluid key={i}>
                {tabRow.map((tab) => {
                  const tabIndex = tabs.indexOf(tab);
                  const tabIcon = TIER2TIERDATA[tabIndex - 1]
                    ? TIER2TIERDATA[tabIndex - 1].icon
                    : 'info';
                  return (
                    <Tabs.Tab
                      icon={tabIcon}
                      key={tabIndex}
                      selected={chapter === tabIndex}
                      onClick={
                        tabIndex === 4
                          ? undefined
                          : () => switchChapter(tabIndex)
                      }
                    >
                      <Box color={tabIndex === 4 && 'red'}>{tab}</Box>
                    </Tabs.Tab>
                  );
                })}
              </Tabs>
            ))}
          </Stack.Item>
          <Stack.Item>
            {chapter === 0 ? (
              <InfuserInstructions />
            ) : (
              <InfuserEntry entry={currentEntry} />
            )}
          </Stack.Item>
          <Stack.Item textAlign="center">
            <Stack fontSize="18px" fill>
              <Stack.Item grow={2}>
                <Button onClick={() => setPage(pageInChapter - 1)} fluid>
                  Last Page
                </Button>
              </Stack.Item>
              <Stack.Item grow={1}>
                <Section fitted fill pt="3px">
                  Page {pageInChapter + 1}/
                  {paginatedEntries[chapter].length + (chapter === 0 ? 1 : 0)}
                </Section>
              </Stack.Item>
              <Stack.Item grow={2}>
                <Button
                  color={restrictedNext && 'black'}
                  onClick={() => setPage(pageInChapter + 1)}
                  fluid
                >
                  {restrictedNext ? 'RESTRICTED' : 'Next Page'}
                </Button>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

export const InfuserInstructions = (props) => {
  return (
    <Section title="DNA Infusion Guide" height={PAGE_HEIGHT}>
      <Stack vertical>
        <Stack.Item fontSize="16px">What does it do?</Stack.Item>
        <Stack.Item color="label">
          DNA Infusion is the practice of integrating dead creature DNA into
          yourself, mutating one of your organs into a genetic slurry that sits
          somewhere between being yours or the creature&apos;s. While this does
          bring you further away from being human, and gives a slew of...
          unfortunate side effects, it also grants new capabilities.{' '}
          <b>
            Above all else, you have to understand that gene-mutants are usually
            very good at specific things, especially with their threshold
            bonuses.
          </b>
        </Stack.Item>
        <Stack.Item fontSize="16px">I&apos;m sold! How do I do it?</Stack.Item>
        <Stack.Item color="label">
          1. Load a dead creature into the machine. This is what you&apos;re
          infusing from.
          <br />
          2. Enter the machine, like you would the DNA scanner.
          <br />
          3. Have someone activate the machine externally.
          <br />
          <Box mt="10px" inline color="white">
            And you&apos;re done! Note that the infusion source will be
            obliterated in the process.
          </Box>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

type InfuserEntryProps = {
  entry: Entry;
};

const InfuserEntry = (props: InfuserEntryProps) => {
  const { entry } = props;

  const tierData = TIER2TIERDATA[entry.tier];

  return (
    <Section
      fill
      title={`${entry.name} Mutant`}
      height={PAGE_HEIGHT}
      buttons={
        <Button tooltip={tierData.desc} icon={tierData.icon}>
          {tierData.name}
        </Button>
      }
    >
      <Stack vertical fill>
        <Stack.Item>
          <BlockQuote>
            {entry.desc}{' '}
            {entry.threshold_desc && (
              <>If a subject infuses with enough DNA, {entry.threshold_desc}</>
            )}
          </BlockQuote>
        </Stack.Item>
        <Stack.Item grow>
          Qualities:
          {entry.qualities.map((quality) => {
            return (
              <Box color="label" key={quality}>
                - {quality}
              </Box>
            );
          })}
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item>
          Created from infusing{' '}
          <Box inline color={entry.name === 'Rejected' ? 'red' : 'green'}>
            {entry.infuse_mob_name}
          </Box>{' '}
          DNA into a subject.
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const paginateEntries = (collection: Entry[]): Entry[][] => {
  const pages: Entry[][] = [];
  let maxTier = -1;
  // find highest tier entry
  collection.forEach((entry) => {
    if (entry.tier > maxTier) {
      maxTier = entry.tier;
    }
  });
  // negative 1 to account for introduction, which has no entries
  let tier = -1;
  for (const _ in range(tier, maxTier + 1)) {
    pages.push(collection.filter((entry) => entry.tier === tier));
    tier++;
  }
  return pages;
};
