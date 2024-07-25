import { useBackend } from '../backend';
import { Section, Button, Icon, Dimmer, Stack } from '../components';
import { Window } from '../layouts';

export const CrackerPuzzle = (props) => {
  const { act, data } = useBackend();
  const {
    grid = [],
    sequence,
    buffer,
    is_vertical,
    horizontal_loc,
    vertical_loc,
    blocking_message,
  } = data;

  // Function to convert buffer coordinates to their positions in the grid
  const bufferPositions = buffer.map(([x, y]) => {
    if (
      y - 1 < 0 ||
      y - 1 >= grid.length ||
      x - 1 < 0 ||
      x - 1 >= grid[0].length
    ) {
      return '?'; // Placeholder for invalid coordinates
    }
    return grid[y - 1][x - 1];
  });

  return (
    <Window width={375} height={480}>
      <Window.Content>
        <Section title="Grid" textAlign="center">
          {blocking_message && (
            <Dimmer fontSize="14px" textAlign="center" fill>
              <Icon mr={1} name="spinner" spin />
              {blocking_message}
            </Dimmer>
          )}
          <Stack>
            <Stack.Item>
              <div
                style={{
                  display: 'flex',
                  flexDirection: 'column',
                  alignItems: 'center',
                }}
              >
                <Stack vertical>
                  <Stack.Item>Sequence</Stack.Item>
                  {sequence.map((item, index) => (
                    <Stack.Item fontSize="20px" key={index}>
                      {item}
                    </Stack.Item>
                  ))}
                </Stack>
              </div>
            </Stack.Item>
            <Stack.Item>
              {grid.map((row, y) => (
                <div key={y} style={{ display: 'flex' }}>
                  {row.map((cell, x) => (
                    <Button
                      key={x}
                      color={
                        is_vertical
                          ? x === horizontal_loc - 1
                            ? 'good'
                            : 'default'
                          : y === vertical_loc - 1
                            ? 'good'
                            : 'default'
                      }
                      onClick={() =>
                        act('press_button', { x: x + 1, y: y + 1 })
                      }
                      style={{
                        width: '40px',
                        height: '40px',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        border: '1px solid black',
                        margin: '2px',
                      }}
                    >
                      {cell}
                    </Button>
                  ))}
                </div>
              ))}
            </Stack.Item>
            <Stack.Item>
              <div
                style={{
                  display: 'flex',
                  flexDirection: 'column',
                  alignItems: 'center',
                }}
              >
                <Stack vertical>
                  <Stack.Item>Buffer</Stack.Item>
                  {bufferPositions.map((item, index) => (
                    <Stack.Item fontSize="20px" key={index}>
                      {item}
                    </Stack.Item>
                  ))}
                </Stack>
              </div>
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
