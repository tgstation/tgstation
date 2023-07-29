import { useBackend, useSharedState } from '../backend';
import { Window } from '../layouts';
import { Button, Section, Stack } from '../components';
import { SearchBar } from './Fabrication/SearchBar';
import { BooleanLike } from '../../common/react';

type Emote = {
  key: string;
  emote_path: string;
  hands: BooleanLike;
  visible: BooleanLike;
  audible: BooleanLike;
  sound: BooleanLike;
};

type EmotePanelData = {
  emotes: Emote[];
};

export const EmotePanelContent = (props, context) => {
  const { act, data } = useBackend<EmotePanelData>(context);
  const { emotes } = data;

  const [searchText, setSearchText] = useSharedState(
    context,
    'search_text',
    ''
  );

  return (
    <Section
      title={
        searchText.length > 0
          ? `Результаты поиска "${searchText}"`
          : `Все эмоции`
      }
      fill>
      <Stack vertical fill>
        <Stack.Item>
          <Section>
            <SearchBar
              searchText={searchText}
              onSearchTextChanged={setSearchText}
              hint={'Искать эмоцию...'}
            />
          </Section>
        </Stack.Item>
        <Stack.Item>
          {emotes.map((emote) =>
            emote.key ? (
              searchText.length > 0 ? (
                emote.key.toLowerCase().includes(searchText.toLowerCase()) ? (
                  <Button
                    key={emote.key}
                    onClick={() =>
                      act('play_emote', {
                        emote_path: emote.emote_path,
                      })
                    }>
                    {emote.key.toUpperCase()}
                  </Button>
                ) : (
                  ''
                )
              ) : (
                <Button
                  key={emote.key}
                  onClick={() =>
                    act('play_emote', {
                      emote_path: emote.emote_path,
                    })
                  }>
                  {emote.key.toUpperCase()}
                </Button>
              )
            ) : (
              ''
            )
          )}
        </Stack.Item>
      </Stack>
    </Section>
  );
};

export const EmotePanel = (props, context) => {
  return (
    <Window width={500} height={450}>
      <Window.Content scrollable>
        <EmotePanelContent />
      </Window.Content>
    </Window>
  );
};
