import { sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { useBackend } from '../backend';
import { Button, Dropdown, Section, LabeledList } from '../components';
import { Window } from '../layouts';

export const CassetteDeck = (props) => {
  const { act, data } = useBackend();
  const { active, track_selected, track_length, track_beat, volume } = data;
  const songs = flow([sortBy((song) => song.name)])(data.songs || []);
  return (
    <Window width={370} height={313}>
      <Window.Content>
        <Section
          title="Song Remover"
          buttons={
            <Button
              icon={'play'}
              content={'Remove Song From Cassette'}
              onClick={() => act('remove')}
            />
          }
        >
          <LabeledList>
            <LabeledList.Item label="Track Selected">
              <Dropdown
                overflow-y="scroll"
                width="240px"
                options={songs.map((song) => song)}
                disabled={active}
                selected={track_selected || 'Select a Track'}
                onSelected={(value) =>
                  act('select_track', {
                    track: value,
                  })
                }
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title="Design Selector"
          buttons={
            <Button
              icon={'play'}
              content={'Add Design to Cassette'}
              onClick={() => act('design')}
            />
          }
        />
        <Section
          title="Eject Cassette"
          buttons={
            <Button
              icon={'play'}
              content={'Eject Cassette'}
              onClick={() => act('eject')}
            />
          }
        />
        <Section
          title="Add Youtube Song"
          buttons={
            <Button
              icon={'play'}
              content={'Add Song'}
              onClick={() => act('url')}
            />
          }
        />
      </Window.Content>
    </Window>
  );
};
