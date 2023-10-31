import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';
import { Button, Section, Flex, Icon } from '../components';
import { BooleanLike } from '../../common/react';
import { SearchBar } from './Fabrication/SearchBar';

type Emote = {
  key: string;
  name: string;
  emote_path: string;
  hands: BooleanLike;
  visible: BooleanLike;
  audible: BooleanLike;
  sound: BooleanLike;
  use_params: BooleanLike;
};

type EmotePanelData = {
  emotes: Emote[];
};

export const EmotePanelContent = (props, context) => {
  const { act, data } = useBackend<EmotePanelData>(context);
  const { emotes } = data;

  const [filterVisible, toggleVisualFilter] = useLocalState<boolean>(
    context,
    'filterVisible',
    false
  );

  const [filterAudible, toggleAudibleFilter] = useLocalState<boolean>(
    context,
    'filterAudible',
    false
  );

  const [filterSound, toggleSoundFilter] = useLocalState<boolean>(
    context,
    'filterSound',
    false
  );

  const [filterHands, toggleHandsFilter] = useLocalState<boolean>(
    context,
    'filterHands',
    false
  );

  const [filterUseParams, toggleUseParams] = useLocalState<boolean>(
    context,
    'filterUseParams',
    false
  );

  const [useParams, toggleuseParams] = useLocalState<boolean>(
    context,
    'useParams',
    false
  );

  const [searchText, setSearchText] = useLocalState<string>(
    context,
    'search_text',
    ''
  );

  const [showNames, toggleShowNames] = useLocalState<boolean>(
    context,
    'showNames',
    true
  );

  return (
    <Section>
      <Section
        title="Filters"
        buttons={
          <Flex>
            <Button
              icon="eye"
              width="100%"
              height="100%"
              align="center"
              tooltip="Visible"
              selected={filterVisible}
              onClick={() => toggleVisualFilter(!filterVisible)}
            />
            <Button
              icon="comment"
              width="100%"
              height="100%"
              align="center"
              tooltip="Audible"
              selected={filterAudible}
              onClick={() => toggleAudibleFilter(!filterAudible)}
            />
            <Button
              icon="volume-up"
              width="100%"
              height="100%"
              align="center"
              tooltip="Sound"
              selected={filterSound}
              onClick={() => toggleSoundFilter(!filterSound)}
            />
            <Button
              icon="hand-paper"
              width="100%"
              height="100%"
              align="center"
              tooltip="Hands"
              selected={filterHands}
              onClick={() => toggleHandsFilter(!filterHands)}
            />
            <Button
              icon="crosshairs"
              width="100%"
              height="100%"
              align="center"
              tooltip="Params"
              selected={filterUseParams}
              onClick={() => toggleUseParams(!filterUseParams)}
            />
          </Flex>
        }>
        <SearchBar
          searchText={searchText}
          onSearchTextChanged={setSearchText}
          hint={'Search all emotes...'}
        />
      </Section>
      <Section
        title={
          searchText.length > 0
            ? `Search results of "${searchText}"`
            : `All Emotes`
        }
        buttons={
          <Flex>
            <Flex.Item>
              <Button
                width="100%"
                height="100%"
                align="center"
                onClick={() => toggleShowNames(!showNames)}>
                {showNames ? 'Show Names' : 'Show Keys'}
              </Button>
            </Flex.Item>
            <Flex.Item>
              <Button
                icon="crosshairs"
                width="100%"
                height="100%"
                align="center"
                selected={useParams}
                onClick={() => toggleuseParams(!useParams)}>
                Use Params
              </Button>
            </Flex.Item>
          </Flex>
        }>
        <Flex>
          <Flex.Item>
            {emotes
              .filter(
                (emote) =>
                  emote.key &&
                  (searchText.length > 0
                    ? emote.key
                      .toLowerCase()
                      .includes(searchText.toLowerCase()) ||
                    emote.name.toLowerCase().includes(searchText.toLowerCase())
                    : true) &&
                  (filterVisible ? emote.visible : true) &&
                  (filterAudible ? emote.audible : true) &&
                  (filterSound ? emote.sound : true) &&
                  (filterHands ? emote.hands : true) &&
                  (filterUseParams ? emote.use_params : true)
              )
              .map((emote) => (
                <Button
                  key={emote.name}
                  onClick={() =>
                    act('play_emote', {
                      emote_path: emote.emote_path,
                      use_params: useParams,
                    })
                  }>
                  {emote.visible ? <Icon name="eye" /> : ''}
                  {emote.audible ? <Icon name="comment" /> : ''}
                  {emote.sound ? <Icon name="volume-up" /> : ''}
                  {emote.hands ? <Icon name="hand-paper" /> : ''}
                  {emote.use_params ? <Icon name="crosshairs" /> : ''}
                  {showNames
                    ? emote.name.toUpperCase()
                    : emote.key.toUpperCase()}
                </Button>
              ))}
          </Flex.Item>
        </Flex>
      </Section>
    </Section>
  );
};

export const EmotePanel = (props, context) => {
  return (
    <Window width={700} height={450}>
      <Window.Content scrollable>
        <EmotePanelContent />
      </Window.Content>
    </Window>
  );
};
