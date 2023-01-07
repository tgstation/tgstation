import { range } from 'common/collections';
import { BooleanLike } from 'common/react';
import { Fragment, InfernoNode, SFC } from 'inferno';
import { useBackend } from '../backend';
import { Blink, Box, Button, ByondUi, Icon, ProgressBar, Stack, Tooltip } from '../components';
import { Window } from '../layouts';

const UNUSED_POWER_BAR_COLOR = 'rgba(255, 184, 0, 0.2)';
const USED_POWER_BAR_COLOR = 'rgba(255, 184, 0, 0.7)';

type PowerBar = {
  fill: number;
  time_to_fill: number;
  power_bar_gain: number;
};

type SingularityControlData = {
  enabled_field_generators: number;
  disabled_field_generators: number;
  map_name: string;
  singularity_generator: BooleanLike;
  stage: Stage;
  turrets: number;

  singularity_data?: {
    containment_percent: number;
    delay_to_overclock: number;
    power_bars: PowerBar[];
  };
};

enum Stage {
  NotStarted = 'not_started',
  Preparing = 'preparing',
  Finished = 'finished',
}

const CoolerSection: SFC<{
  title: string;
}> = (props) => {
  return (
    <fieldset
      style={{
        height: '100%',
      }}>
      <legend
        style={{
          'font-size': '16px',
          'font-weight': 'bold',
        }}>
        {props.title}
      </legend>

      <Box height="95%">{props.children}</Box>
    </fieldset>
  );
};

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

const SetupScreen = (props, context) => {
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

const PowerBarDisplay = ({ powerBar }: { powerBar: PowerBar }) => {
  const timeText = `${(powerBar.time_to_fill / 10).toFixed()}s`;

  return (
    <Tooltip
      content={
        powerBar.fill === 1
          ? `${timeText} until decay`
          : `${timeText} until full`
      }
      position="bottom">
      <Box
        backgroundColor={UNUSED_POWER_BAR_COLOR}
        height="100%"
        width="100%"
        position="relative">
        <Box
          backgroundColor={USED_POWER_BAR_COLOR}
          height={`${powerBar.fill * 100}%`}
          width="100%"
          position="absolute"
          bottom={0}
        />
      </Box>
    </Tooltip>
  );
};

const OutputWindow = (props, context) => {
  const { act, data } = useBackend<SingularityControlData>(context);
  const singularityData = data.singularity_data!;

  return (
    <Stack fill height="100%">
      {singularityData.power_bars.map((bar) => (
        <Fragment key={`power_bars_${bar}`}>
          {range(0, bar.power_bar_gain).map((index) => (
            <Stack.Item
              key={`power_bar_${bar}_${index}`}
              height="100%"
              width="20%"
              mr={1}>
              <PowerBarDisplay powerBar={bar} />
            </Stack.Item>
          ))}
        </Fragment>
      ))}
    </Stack>
  );
};

const ObserveScreen = (props, context) => {
  const { act, data } = useBackend<SingularityControlData>(context);
  const singularityData = data.singularity_data!;

  return (
    <Window title="Singularity Control Console" width={800} height={540}>
      <Window.Content>
        <Stack fill>
          <Stack.Item grow>
            <Stack fill vertical>
              <Stack.Item grow>
                <ByondUi
                  params={{
                    id: data.map_name,
                    type: 'map',
                  }}
                  style={{
                    height: '100%',
                  }}
                />
              </Stack.Item>

              <Stack.Item height="30px">
                <ProgressBar
                  ranges={{
                    good: [1, 1],
                    average: [0.5, 1],
                    bad: [-Infinity, 0.5],
                  }}
                  value={singularityData.containment_percent}>
                  <Box width="100%" textAlign="left" fontSize="18px" my={1}>
                    <b>{singularityData.containment_percent * 100}%</b>{' '}
                    contained
                  </Box>
                </ProgressBar>
              </Stack.Item>
            </Stack>
          </Stack.Item>

          <Stack.Item grow>
            <Stack vertical fill>
              <Stack.Item height="50%">
                <CoolerSection title="OUTPUT">
                  <OutputWindow />
                </CoolerSection>
              </Stack.Item>

              <Stack.Item grow>
                <CoolerSection title="EQUIPMENT" />
              </Stack.Item>

              <Stack.Item grow>
                <CoolerSection title="OVERCLOCK" />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

export const SingularityControl = (props, context) => {
  const { data } = useBackend<SingularityControlData>(context);

  // if (data.stage === )
  switch (data.stage) {
    case Stage.NotStarted:
    case Stage.Preparing:
      return <SetupScreen />;
    case Stage.Finished:
      return <ObserveScreen />;
  }
};
