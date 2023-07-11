import { BlockQuote, Stack } from '../components';
import { Window } from '../layouts';

const goodstyle = {
  color: 'lightgreen',
};

const badstyle = {
  color: 'red',
};

const noticestyle = {
  color: 'lightblue',
};

export const AntagInfoMorph = (props, context) => {
  return (
    <Window width={620} height={170} theme="abductor">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item fontSize="25px">You are a morph...</Stack.Item>
          <Stack.Item>
            <BlockQuote>
              ...a shapeshifting abomination that can eat almost anything. You
              may take the form of anything you can see by{' '}
              <span style={noticestyle}>shift-clicking</span> it.
              <span style={badstyle}>
                &ensp;This process will alert any nearby observers.
              </span>{' '}
              While morphed, you move faster, but are unable to attack creatures
              or eat anything. In addition,
              <span style={badstyle}>
                &ensp;anyone within three tiles will note an uncanny wrongness
                if examining you.
              </span>{' '}
              You can attack any item or dead creature to consume it -
              <span style={goodstyle}>
                &ensp;creatures will restore your health.
              </span>{' '}
              Finally, you can restore yourself to your original form while
              morphed by <span style={noticestyle}>shift-clicking</span>{' '}
              yourself.
            </BlockQuote>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
