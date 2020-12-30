import { toArray } from 'common/collections';
import { useBackend } from '../backend';
import { Section } from '../components';
import { resolveAsset } from '../assets';
import { Window } from '../layouts';
import { Box } from '../components';

export const Hacking = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    array = [[]],
  } = data;
  return (
    <Window
      width={1000}
      height={1000}
      resizable>
      <Window.Content>
        <Section title="CYBERNETICS HACKING INTERFACE ">
          {toArray(array).map((arr, i) => (
            <Box key={i}>
              {toArray(arr).map((element, j) => (
                <Box
                  key={i + '_' + j}
                  as="img"
                  className="Safe__dial"
                  src={resolveAsset(element + '.png')}
                />
              ))}
            </Box>
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
