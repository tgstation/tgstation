import { useState } from 'react';
import { Box, Button, Flex, Input, Section, Stack } from 'tgui-core/components';
import { createSearch } from 'tgui-core/string';

import { useBackend } from '../../../backend';
import { Personality, PreferencesMenuData } from '../types';
import { useServerPrefs } from '../useServerPrefs';

function PersonalityButton(props: {
  personality: Personality;
  selected?: boolean;
  onClick: () => void;
}) {
  const { personality, selected, onClick } = props;

  return (
    <Button
      onClick={onClick}
      p={1}
      style={{
        cursor: 'pointer',
        borderColor: selected ? 'green' : '#444444',
        borderStyle: 'solid',
        borderWidth: '0.2em',
        borderRadius: '0.33em',
      }}
      fluid
      height="180px"
      backgroundColor={
        selected ? 'rgba(34, 64, 34, 0.5)' : 'rgba(34, 34, 34, 0.5)'
      }
    >
      <Stack vertical wrap justify="center">
        <Stack.Item
          textAlign="center"
          bold
          fontSize="16px"
          inline
          p={0.25}
          pl={0.5}
          pr={0.5}
          mb={-0.2}
        >
          {personality.name}
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item
          mt={0.2}
          mb={0.2}
          color="#999999"
          style={{
            whiteSpace: 'normal',
            wordBreak: 'break-word',
            borderLeft: '0.15em solid #444444',
            paddingLeft: '0.5em',
          }}
        >
          {personality.description}
        </Stack.Item>
        {personality.pos_gameplay_description && (
          <Stack.Item
            mt={-0.1}
            color="green"
            style={{ whiteSpace: 'normal', wordBreak: 'break-word' }}
          >
            + {personality.pos_gameplay_description}
          </Stack.Item>
        )}
        {personality.neg_gameplay_description && (
          <Stack.Item
            mt={-0.1}
            color="red"
            style={{
              whiteSpace: 'normal',
              wordBreak: 'break-word',
            }}
          >
            - {personality.neg_gameplay_description}
          </Stack.Item>
        )}
        {personality.neut_gameplay_description && (
          <Stack.Item
            mt={-0.1}
            color="yellow"
            style={{
              whiteSpace: 'normal',
              wordBreak: 'break-word',
            }}
          >
            ± {personality.neut_gameplay_description}
          </Stack.Item>
        )}
      </Stack>
    </Button>
  );
}

// Sort by selected first, then by name
function sortPersonalities(
  a: Personality,
  b: Personality,
  selectedPersonalities: string[] | null,
) {
  /*
  const aSelected = selectedPersonalities?.includes(a.path);
  const bSelected = selectedPersonalities?.includes(b.path);

  if (aSelected && !bSelected) return -1;
  if (!aSelected && bSelected) return 1;
  */
  return a.name < b.name ? -1 : 1;
}

function getAllSelectedPersonalitiesString(
  allPersonalities: Personality[],
  selectedPersonalities: string[] | null,
) {
  let personalityNames: string[] = [];
  for (const personality of allPersonalities) {
    if (selectedPersonalities?.includes(personality.path)) {
      personalityNames.push(personality.name);
    }
  }
  if (personalityNames.length === 0) {
    return 'You have no personality.';
  }
  personalityNames.sort((a, b) => (a < b ? -1 : 1));
  let finalString = '';
  for (let i = 0; i < personalityNames.length; i++) {
    finalString += personalityNames[i];
    if (i < personalityNames.length - 1) {
      if (personalityNames.length > 2) {
        finalString += ', ';
      }
    }
    if (i === personalityNames.length - 2) {
      if (personalityNames.length <= 2) {
        finalString += ' ';
      }
      finalString += 'and ';
    }
  }
  return `You are ${finalString}.`;
}

export function PersonalityPage(props) {
  const { act, data } = useBackend<PreferencesMenuData>();

  const server_data = useServerPrefs();
  if (!server_data) return;

  const [searchQuery, setSearchQuery] = useState('');
  const personalitySearch = createSearch(
    searchQuery,
    (personality: Personality) =>
      personality.name +
      personality.description +
      personality.pos_gameplay_description +
      personality.neg_gameplay_description +
      personality.neut_gameplay_description,
  );
  const selectedPersonalities = data.selected_personalities;
  const filteredPersonalities = server_data.personality.personalities
    .filter(personalitySearch)
    .sort((a, b) => sortPersonalities(a, b, selectedPersonalities));

  return (
    <Section fill>
      <Stack vertical fill>
        <Stack.Item align="center" fontSize="20px" bold>
          {getAllSelectedPersonalitiesString(
            server_data.personality.personalities,
            selectedPersonalities,
          )}
        </Stack.Item>
        <Stack.Item mb={1}>
          <Flex grow align="center">
            <Flex.Item>
              <Box
                bold
                fontSize="16px"
                mr={1}
                backgroundColor="white"
                color="black"
                p={0.25}
                pl={0.5}
                pr={0.5}
              >
                {selectedPersonalities?.length || 0} / {data.max_personalities}
              </Box>
            </Flex.Item>
            <Flex.Item grow>
              <Input
                fluid
                placeholder="Search..."
                value={searchQuery}
                onInput={(e) => setSearchQuery(e.currentTarget.value)}
              />
            </Flex.Item>
          </Flex>
        </Stack.Item>
        <Stack.Item grow>
          <Section fill scrollable>
            <Flex wrap width="100%">
              {filteredPersonalities.map((personality) => (
                <Flex.Item
                  key={personality.name}
                  mr={0.5}
                  mb={0.5}
                  width="32.5%"
                >
                  <PersonalityButton
                    personality={personality}
                    selected={selectedPersonalities?.includes(personality.path)}
                    onClick={() => {
                      act('handle_personality', {
                        personality_type: personality.path,
                      });
                    }}
                  />
                </Flex.Item>
              ))}
            </Flex>
          </Section>
        </Stack.Item>
      </Stack>
    </Section>
  );
}
