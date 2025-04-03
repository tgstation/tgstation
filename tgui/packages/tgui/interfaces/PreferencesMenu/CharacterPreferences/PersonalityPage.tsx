import { useState } from 'react';
import {
  BlockQuote,
  Box,
  Button,
  Flex,
  Input,
  Section,
  Stack,
} from 'tgui-core/components';
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
    <Button onClick={onClick} p={1} selected={selected}>
      <Stack vertical>
        <Stack.Item fontSize="16px" textAlign="center">
          <Box backgroundColor="black" inline p={0.25} pl={0.5} pr={0.5}>
            {personality.name}
          </Box>
        </Stack.Item>
        <Stack.Item>
          <BlockQuote>{personality.description}</BlockQuote>
        </Stack.Item>
        <Stack.Item color="green">
          {personality.gameplay_description}
        </Stack.Item>
      </Stack>
    </Button>
  );
}

export function PersonalityPage(props) {
  const { act, data } = useBackend<PreferencesMenuData>();

  const server_data = useServerPrefs();
  if (!server_data) return;

  const [searchQuery, setSearchQuery] = useState('');
  const personalitySearch = createSearch(
    searchQuery,
    (personality: Personality) => personality.name,
  );
  const filteredPersonalities = server_data.personality.personalities
    .filter(personalitySearch)
    .sort((a, b) => a.name > b.name);

  const selectedPersonalities = data.selected_personalities;

  return (
    <Section fill>
      <Stack vertical fill>
        <Stack.Item>
          <Input
            fluid
            placeholder="Search..."
            value={searchQuery}
            onInput={(e) => setSearchQuery(e.currentTarget.value)}
          />
        </Stack.Item>
        <Stack.Item grow>
          <Section fill scrollable>
            <Flex wrap>
              {filteredPersonalities.map((personality) => (
                <Flex.Item key={personality.name} mr={0.5} mb={0.5}>
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
