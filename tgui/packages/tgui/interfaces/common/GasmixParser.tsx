import { Box, Button, LabeledList, Stack } from 'tgui-core/components';

type GasEntry = [string, string, number]; // ID, name, and amount.

type ReactionEntry = [string, string, number]; // ID, name, and amount.

export type Gasmix = {
  name?: string;
  gases: GasEntry[]; // ID, name, and amount.
  temperature: number;
  volume: number;
  pressure: number;
  total_moles: number;
  reactions: ReactionEntry[]; // ID, name, and amount.
  reference: string;
};

type GasmixParserProps = {
  gasmix: Gasmix;
  gasesOnClick?: (gas_id: string) => void;
  temperatureOnClick?: () => void;
  volumeOnClick?: () => void;
  pressureOnClick?: () => void;
  reactionOnClick?: (reaction_id: string) => void;
  // Whether we need to show the number of the reaction or not
  detailedReactions?: boolean;
};

export const GasmixParser = (props: GasmixParserProps) => {
  const {
    gasmix,
    gasesOnClick,
    temperatureOnClick,
    volumeOnClick,
    pressureOnClick,
    reactionOnClick,
    detailedReactions,
    ...rest
  } = props;

  const { gases, temperature, volume, pressure, total_moles, reactions } =
    gasmix;

  if (total_moles <= 0) {
    return (
      <Box nowrap italic mb="10px">
        No Gas Detected!
      </Box>
    );
  }

  return (
    <Stack vertical>
      <Stack.Item>
        <Stack>
          <Stack.Item width="60%">
            {gases.map((gas) => (
              <LabeledList.Item
                label={
                  gasesOnClick ? (
                    <Button fluid onClick={() => gasesOnClick(gas[0])}>
                      {gas[1]}
                    </Button>
                  ) : (
                    gas[1]
                  )
                }
                key={gas[1]}
              >
                {gas[2].toFixed(2) +
                  ' mol (' +
                  ((gas[2] / total_moles) * 100).toFixed(2) +
                  ' %)'}
              </LabeledList.Item>
            ))}
          </Stack.Item>
          <Stack.Item grow>
            <LabeledList>
              <LabeledList.Item
                label={
                  temperatureOnClick ? (
                    <Button
                      content={'Temperature'}
                      onClick={() => temperatureOnClick()}
                    />
                  ) : (
                    'Temperature'
                  )
                }
              >
                {`${total_moles ? temperature.toFixed(2) : '-'} K`}
              </LabeledList.Item>
              <LabeledList.Item
                label={
                  volumeOnClick ? (
                    <Button
                      content={'Volume'}
                      onClick={() => volumeOnClick()}
                    />
                  ) : (
                    'Volume'
                  )
                }
              >
                {`${total_moles ? volume.toFixed(2) : '-'} L`}
              </LabeledList.Item>
              <LabeledList.Item
                label={
                  pressureOnClick ? (
                    <Button
                      content={'Pressure'}
                      onClick={() => pressureOnClick()}
                    />
                  ) : (
                    'Pressure'
                  )
                }
              >
                {`${total_moles ? pressure.toFixed(2) : '-'} kPa`}
              </LabeledList.Item>
            </LabeledList>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      {!!reactions.length && (
        <Stack.Item>
          <Stack vertical>
            <Stack.Item align="center" fontSize="1.2rem" color="label">
              Active Reactions
            </Stack.Item>
            {detailedReactions ? (
              <Stack.Item>
                {reactions.map((reaction) => (
                  <Stack.Item key={`${gasmix.reference}-${reaction[0]}`}>
                    {reactionOnClick ? (
                      <Button
                        onClick={() => reactionOnClick(reaction[0])}
                        mr={1}
                      >
                        {reaction[1]}
                      </Button>
                    ) : (
                      reaction[1]
                    )}
                    - {reaction[2]}
                  </Stack.Item>
                ))}
              </Stack.Item>
            ) : (
              <Stack.Item>
                <Stack>
                  {reactions.map((reaction) => (
                    <Stack.Item key={`${gasmix.reference}-${reaction[0]}`}>
                      {reactionOnClick ? (
                        <Button
                          onClick={() => reactionOnClick(reaction[0])}
                          mr={1}
                        >
                          {reaction[1]}
                        </Button>
                      ) : (
                        reaction[1]
                      )}
                    </Stack.Item>
                  ))}
                </Stack>
              </Stack.Item>
            )}
          </Stack>
        </Stack.Item>
      )}
    </Stack>
  );
};
