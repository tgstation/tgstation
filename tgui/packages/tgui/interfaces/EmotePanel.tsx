import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';
import { Button, Section, Flex, Icon, Box } from '../components';
import { BooleanLike } from '../../common/react';
import { SearchBar } from './Fabrication/SearchBar';
import { capitalizeFirst } from '../../common/string';

type Emote = {
  key: string;
  name: string;
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

  const [filterUseParams, toggleUseParamsFilter] = useLocalState<boolean>(
    context,
    'filterUseParams',
    false
  );

  const [useParams, toggleUseParams] = useLocalState<boolean>(
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

  const [showIcons, toggleShowIcons] = useLocalState<boolean>(
    context,
    'showIcons',
    false
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
              onClick={() => toggleUseParamsFilter(!filterUseParams)}
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
              <Button onClick={() => toggleShowNames(!showNames)}>
                {showNames ? 'Show Names' : 'Show Keys'}
              </Button>
              <Button
                selected={showIcons}
                onClick={() => toggleShowIcons(!showIcons)}>
                Show Icons
              </Button>
            </Flex.Item>
            <Flex.Item>
              <Button
                icon="crosshairs"
                selected={useParams}
                onClick={() => toggleUseParams(!useParams)}>
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
              .sort((a, b) => (a.name > b.name ? 1 : -1))
              .map((emote) => (
                <Button
                  width={showIcons ? 16 : 8}
                  key={emote.name}
                  tooltip={
                    showIcons ? (
                      ''
                    ) : (
                      <EmoteIcons
                        visible={emote.visible}
                        audible={emote.audible}
                        sound={emote.sound}
                        hands={emote.hands}
                        use_params={emote.use_params}
                        margin={0.5}
                      />
                    )
                  }
                  onClick={() =>
                    act('play_emote', {
                      emote_key: emote.key,
                      use_params: useParams,
                    })
                  }>
                  <Box inline width="50%">
                    {showNames
                      ? capitalizeFirst(emote.name.toLowerCase())
                      : emote.key}
                  </Box>
                  {showIcons ? (
                    <EmoteIcons
                      visible={emote.visible}
                      audible={emote.audible}
                      sound={emote.sound}
                      hands={emote.hands}
                      use_params={emote.use_params}
                      margin={0}
                    />
                  ) : (
                    ''
                  )}
                </Button>
              ))}
          </Flex.Item>
        </Flex>
      </Section>
    </Section>
  );
};

const EmoteIcons = (props, context) => {
  const { visible, audible, sound, hands, use_params, margin } = props;

  return (
    <Box inline align="right">
      <Icon
        name="eye"
        m={margin}
        color={!visible ? 'red' : ''}
        opacity={!visible ? 0.5 : 1}
      />
      <Icon
        name="comment"
        m={margin}
        color={!audible ? 'red' : ''}
        opacity={!audible ? 0.5 : 1}
      />
      <Icon
        name="volume-up"
        m={margin}
        color={!sound ? 'red' : ''}
        opacity={!sound ? 0.5 : 1}
      />
      <Icon
        name="hand-paper"
        m={margin}
        color={!hands ? 'red' : ''}
        opacity={!hands ? 0.5 : 1}
      />
      <Icon
        name="crosshairs"
        m={margin}
        color={!use_params ? 'red' : ''}
        opacity={!use_params ? 0.5 : 1}
      />
    </Box>
  );
};

export const EmotePanel = (props, context) => {
  return (
    <Window width={630} height={500}>
      <Window.Content scrollable>
        <EmotePanelContent />
      </Window.Content>
    </Window>
  );
};
