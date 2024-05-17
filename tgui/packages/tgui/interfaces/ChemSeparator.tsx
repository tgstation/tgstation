import { useBackend } from '../backend';
import { Box, Button, LabeledList, ProgressBar, Stack } from '../components';
import { Window } from '../layouts';

type RegHolderData = {
  total_volume: number;
  maximum_volume: number;
  temp: number;
  color: string;
};

type Data = {
  flask: RegHolderData;
  beaker: RegHolderData;
  fuel: RegHolderData;
  knob: number;
};

const BURNER_SETTINGS = [1, 2, 3, 4, 5];

export const ChemSeparator = (props) => {
  const { act, data } = useBackend<Data>();
  const { flask, beaker, fuel, knob } = data;

  return (
    <Window width={370} height={170}>
      <Window.Content>
        <LabeledList>
          <LabeledList.Item
            label={
              <Box
                style={{
                  transform: 'translate(20%, -50%)',
                  width: '57px',
                }}
              >
                Flask:
              </Box>
            }
          >
            <Stack vertical={false} fill>
              <Stack.Item ml="27px">
                <ProgressBar
                  height={2}
                  minValue={0}
                  maxValue={flask.maximum_volume}
                  value={flask.total_volume}
                  color={flask.color}
                  width="170px"
                >
                  <Box
                    lineHeight={1.9}
                    style={{
                      textShadow: '1px 1px 0 black',
                    }}
                  >
                    {`${Math.ceil(flask.total_volume)} of ${
                      flask.maximum_volume
                    } units at ${Math.ceil(flask.temp)}°C`}
                  </Box>
                </ProgressBar>
              </Stack.Item>
              <Stack.Item>
                <Button
                  mr={2}
                  width={6}
                  lineHeight={2}
                  align="center"
                  icon="arrow-down"
                  disabled={flask.total_volume <= 0 || !beaker}
                  onClick={() => act('drain')}
                >
                  Drain
                </Button>
              </Stack.Item>
            </Stack>
          </LabeledList.Item>
          {beaker && (
            <LabeledList.Item
              label={
                <Box
                  style={{
                    transform: 'translate(20%, -50%)',
                    width: '57px',
                  }}
                >
                  Beaker:
                </Box>
              }
            >
              <Stack vertical={false} fill>
                <Stack.Item ml="27px">
                  <ProgressBar
                    height={2}
                    minValue={0}
                    maxValue={beaker.maximum_volume}
                    value={beaker.total_volume}
                    color={beaker.color}
                    width="170px"
                  >
                    <Box
                      lineHeight={1.9}
                      style={{
                        textShadow: '1px 1px 0 black',
                      }}
                    >
                      {`${Math.ceil(beaker.total_volume)} of ${
                        beaker.maximum_volume
                      } units at ${Math.ceil(beaker.temp)}°C`}
                    </Box>
                  </ProgressBar>
                </Stack.Item>
                <Stack.Item>
                  <Button
                    mr={2}
                    width={6}
                    lineHeight={2}
                    align="center"
                    icon="filter"
                    disabled={beaker.total_volume <= 0}
                    onClick={() => act('filter')}
                  >
                    Filter
                  </Button>
                </Stack.Item>
              </Stack>
            </LabeledList.Item>
          )}
          <LabeledList.Item
            label={
              <Box
                style={{
                  transform: 'translate(20%, -50%)',
                  width: '57px',
                }}
              >
                Burner Knob:
              </Box>
            }
          >
            <Stack ml="27px" vertical={false} fill>
              {BURNER_SETTINGS.map((value, i) => (
                <Stack.Item key={value}>
                  <Button.Checkbox
                    checked={value === knob}
                    onClick={() =>
                      act('knob', {
                        amount: value,
                      })
                    }
                  >
                    {value}
                  </Button.Checkbox>
                </Stack.Item>
              ))}
            </Stack>
          </LabeledList.Item>
          {fuel && (
            <LabeledList.Item
              label={
                <Box
                  style={{
                    transform: 'translate(20%, -20%)',
                    width: '57px',
                  }}
                >
                  Burner Fuel:
                </Box>
              }
            >
              <ProgressBar
                height={2}
                minValue={0}
                maxValue={fuel.maximum_volume}
                value={fuel.total_volume}
                color={fuel.color}
                maxWidth="200px"
                ml="25px"
              >
                <Box
                  lineHeight={1.9}
                  style={{
                    textShadow: '1px 1px 0 black',
                  }}
                >
                  {`${Math.ceil(fuel.total_volume)} of ${
                    fuel.maximum_volume
                  } units at ${Math.ceil(fuel.temp)}°C`}
                </Box>
              </ProgressBar>
            </LabeledList.Item>
          )}
        </LabeledList>
      </Window.Content>
    </Window>
  );
};
