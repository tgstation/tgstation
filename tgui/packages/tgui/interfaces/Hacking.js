import { toArray } from 'common/collections';
import { useBackend } from '../backend';
import { Section, Box, TimeDisplay } from '../components';
import { resolveAsset } from '../assets';
import { Window } from '../layouts';

export const Hacking = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    timeleft,
    games = [[[]]],
  } = data;
  return (
    <Window
      width={500}
      height={768}
      theme="hackerman"
      resizable>
      <Window.Content scrollable>
        <Section title="CYBERNETICS HACKING INTERFACE ">
          {toArray(games).map((array, i) => (
            <Section
              key={i}
              title={'HACKING IN PROGRESS [ ' + i + ' ]'}
              level={2}>
              {'[TIME LEFT: '}
              <TimeDisplay auto="down" value={timeleft} />
              {']'}
              <Minigame
                key={i}
                array={array}
                minigame_id={i} />
            </Section>
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};

const Minigame = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    array = [[]],
    minigame_id = 0,
  } = props;
  return (
    toArray(array).map((arr, i) => (
      <Box key={i}>
        {toArray(arr).map((element, j) => (
          <Box
            key={i + '_' + j}
            as="img"
            className="pathway"
            width="50px"
            height="50px"
            src={resolveAsset(element + '.png')}
            onClick={() => act('click', {
              xcord: i,
              ycord: j,
              id: minigame_id,
            })}
          />
        ))}
      </Box>
    ))
  );
};
