import { round } from 'common/math';
import { useBackend } from '../backend';
import { Box, Button, Collapsible, LabeledList, ProgressBar, Section, Slider } from '../components';
import { Window } from '../layouts';

export const MediaJukebox = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    playing,
    loop_mode,
    volume,
    current_track_ref,
    current_track,
    current_genre,
    percent,
    tracks,
  } = data;

  let genre_songs =
    tracks.length &&
    tracks.reduce((acc, obj) => {
      let key = obj.genre || 'Uncategorized';
      if (!acc[key]) {
        acc[key] = [];
      }
      acc[key].push(obj);
      return acc;
    }, {});

  let true_genre = playing && (current_genre || 'Uncategorized');

  return (
    <Window width={450} height={600} resizable>
      <Window.Content scrollable>
        <Section title="Currently Playing">
          <LabeledList>
            <LabeledList.Item label="Title">
              {(playing && current_track && (
                <Box>
                  {current_track.title} by {current_track.artist || 'Unkown'}
                </Box>
              )) || <Box>Stopped</Box>}
            </LabeledList.Item>
            <LabeledList.Item label="Controls">
              <Button
                icon="play"
                disabled={playing}
                onClick={() => act('play')}>
                Play
              </Button>
              <Button
                icon="stop"
                disabled={!playing}
                onClick={() => act('stop')}>
                Stop
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Loop Mode">
              <Button
                icon="play"
                onClick={() => act('loopmode', { loopmode: 1 })}
                selected={loop_mode === 1}>
                Next
              </Button>
              <Button
                icon="random"
                onClick={() => act('loopmode', { loopmode: 2 })}
                selected={loop_mode === 2}>
                Shuffle
              </Button>
              <Button
                icon="redo"
                onClick={() => act('loopmode', { loopmode: 3 })}
                selected={loop_mode === 3}>
                Repeat
              </Button>
              <Button
                icon="step-forward"
                onClick={() => act('loopmode', { loopmode: 4 })}
                selected={loop_mode === 4}>
                Once
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Progress">
              <ProgressBar value={percent} maxValue={1} color="good" />
            </LabeledList.Item>
            <LabeledList.Item label="Volume">
              <Slider
                minValue={0}
                step={1}
                value={volume * 100}
                maxValue={100}
                ranges={{
                  good: [75, Infinity],
                  average: [25, 75],
                  bad: [0, 25],
                }}
                format={(val) => round(val, 1) + '%'}
                onChange={(e, val) =>
                  act('volume', { val: round(val / 100, 2) })
                }
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Available Tracks">
          {(tracks.length &&
            Object.keys(genre_songs)
              .sort()
              .map((genre) => (
                <Collapsible
                  title={genre}
                  key={genre}
                  color={true_genre === genre ? 'green' : 'default'}
                  child_mt={0}>
                  <div style={{ 'margin-left': '1em' }}>
                    {genre_songs[genre].map((track) => (
                      <Button
                        fluid
                        icon="play"
                        key={track.ref}
                        selected={current_track_ref === track.ref}
                        onClick={() =>
                          act('change_track', { change_track: track.ref })
                        }>
                        {track.title}
                      </Button>
                    ))}
                  </div>
                </Collapsible>
              ))) || <Box color="bad">Error: No songs loaded.</Box>}
        </Section>
      </Window.Content>
    </Window>
  );
};
