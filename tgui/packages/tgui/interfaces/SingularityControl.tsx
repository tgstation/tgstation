import { BooleanLike } from 'common/react';
import { InfernoNode } from 'inferno';
import { useBackend } from '../backend';
import { Blink, Box, Button, Icon, Stack } from '../components';
import { Window } from '../layouts';

type SingularityControlData = {
  enabled_field_generators: number;
  disabled_field_generators: number;
  singularity_generator: BooleanLike;
  turrets: number;
  stage: Stage;
};

enum Stage {
  NotStarted = 'not_started',
  Preparing = 'preparing',
}

const ConnectedMachine = (props: {
  icon: string;
  topText?: InfernoNode;
  bottomText?: InfernoNode;
  backgroundColor?: string;
}) => {
  return (
    <Stack.Item grow backgroundColor={props.backgroundColor}>
      <Stack fill vertical align="center" justify="center">
        <Stack.Item height="24px">{props.topText}</Stack.Item>

        <Stack.Item grow>
          <Icon name={props.icon} size={10} lineHeight={1.1} />
        </Stack.Item>

        <Stack.Item height="24px">{props.bottomText}</Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

export const SingularityControl = (props, context) => {
  const { act, data } = useBackend<SingularityControlData>(context);

  const generatorCount =
    data.enabled_field_generators + data.disabled_field_generators;

  return (
    <Window title="Singularity Control Console" width={700} height={300}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item grow>
            <Stack fill>
              <ConnectedMachine
                icon="shield"
                backgroundColor={
                  data.enabled_field_generators < 4 ? 'red' : undefined
                }
                bottomText={
                  <Box fontSize="14px">
                    <b>{generatorCount}</b> field generator
                    {generatorCount === 1 ? '' : 's'}
                  </Box>
                }
                topText={
                  data.enabled_field_generators < 4 && (
                    <Box fontSize="14px" mt={0.5}>
                      <Blink>
                        <Icon name="triangle-exclamation" />
                      </Blink>

                      <span
                        style={{
                          'margin-left': '5px',
                        }}>
                        <b>{data.disabled_field_generators}</b> disabled,{' '}
                        <b>
                          {4 -
                            data.enabled_field_generators -
                            data.disabled_field_generators}
                        </b>{' '}
                        missing
                      </span>
                    </Box>
                  )
                }
              />

              {/* MBTODO: If singulo, replace this entire menu with a power readout */}
              <ConnectedMachine
                icon="circle-plus"
                bottomText={
                  data.singularity_generator ? (
                    <>
                      <b>Singularity generator</b> detected
                    </>
                  ) : (
                    <>
                      <b>No singularity generator</b> detected
                    </>
                  )
                }
              />

              <ConnectedMachine
                bottomText={
                  <Box fontSize="14px">
                    <b>{data.turrets}</b> turret{data.turrets === 1 ? '' : 's'}
                  </Box>
                }
                icon="wand-sparkles"
              />
            </Stack>
          </Stack.Item>

          <Stack.Item height="50px">
            <Stack fill align="center" justify="center">
              {data.stage === Stage.NotStarted && (
                <Stack.Item>
                  {/* MBTOOD: Warning if you aren't ready */}
                  {/* MBTODO: Define flag that determines if you are ALLOWED to click this, or if it's a warning. Useful for very early test merge. */}
                  <Button
                    fontSize="18px"
                    onClick={() => {
                      act('fire_emitters');
                    }}>
                    Fire emitters
                  </Button>
                </Stack.Item>
              )}

              {data.stage === Stage.Preparing && (
                <Stack.Item>
                  <Stack fill align="center" justify="center">
                    <Stack.Item>
                      <Icon name="spinner" spin size={3} />
                    </Stack.Item>

                    <Stack.Item fontSize="18px">
                      Preparing emitters...
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
              )}
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
