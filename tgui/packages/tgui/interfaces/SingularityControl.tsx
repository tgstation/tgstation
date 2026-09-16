import { range, sortBy } from 'es-toolkit';
import type { ReactNode } from 'react';
import { Fragment } from 'react';

import {
  Blink,
  Box,
  Button,
  ByondUi,
  Icon,
  NoticeBox,
  ProgressBar,
  Stack,
  Tooltip,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { useBackend, useSharedState } from '../backend';
import { Window } from '../layouts';

const UNUSED_POWER_BAR_ALPHA = 0.2;
const USED_POWER_BAR_ALPHA = 0.7;

const POWER_BAR_COLOR = [255, 184, 0] as const;
const OVERCLOCKED_BAR_COLOR = [0, 255, 255] as const;

const withAlpha = (color: readonly [number, number, number], alpha: number) =>
  `rgba(${color.join(',')},${alpha})`;

const ICON_EMITTER = 'wand-sparkles';
const ICON_SHIELD = 'shield';

enum PowerBarState {
  WaitingForPoke = 'waiting_for_poke',
  WaitingLifetime = 'waiting_lifetime',
  WaitingRechargeDelay = 'waiting_recharge_delay',
}

type PowerBar = {
  fill: number;
  time_to_fill: number;
  power_bar_gain: number;
  state: PowerBarState;
};

type SingularityControlData = {
  enabled_field_generators: number;
  disabled_field_generators: number;
  enabled_emitters: number;
  disabled_emitters: number;
  emitters_require_shields: BooleanLike;
  has_access: BooleanLike;
  map_name: string;
  overclock_access: OverclockAccess;
  singularity_generator: BooleanLike;
  stage: Stage;

  singularity_data?: {
    containment_percent: number;
    delay_to_overclock: number;
    power_bars: PowerBar[];
    overclocked_power_bars: PowerBar[];
  };
};

enum Stage {
  NotStarted = 'not_started',
  Preparing = 'preparing',
  Finished = 'finished',
  SelfDestructing = 'self_destructing',
  Destroyed = 'destroyed',
}

enum OverclockAccess {
  NotAllowed = 'not_allowed',
  NotAllowedSilicon = 'not_allowed_silicon',
  NotAllowedTooDamaged = 'not_allowed_too_damaged',
  Allowed = 'allowed',
}

function sortPowerBarsByTimeToFill(powerBars: PowerBar[]) {
  return sortBy(powerBars, [(bar) => -bar.time_to_fill]);
}

type CoolerSectionProps = {
  title: ReactNode;
  children: ReactNode;
};

const CoolerSection = (props: CoolerSectionProps) => {
  const { title, children } = props;
  return (
    <fieldset
      style={{
        height: '100%',
      }}
    >
      <legend
        style={{
          fontSize: '16px',
          fontWeight: 'bold',
        }}
      >
        {title}
      </legend>

      <Box height="92%">{children}</Box>
    </fieldset>
  );
};

const NoAccessWarning = () => {
  return (
    <NoticeBox
      danger
      style={{
        position: 'absolute',
        width: '100%',
      }}
    >
      You do not have access.
    </NoticeBox>
  );
};

type ConnectedMachineProps = {
  icon: string;
  topText?: ReactNode;
  bottomText?: ReactNode;
  backgroundColor?: string;
};

const ConnectedMachine = (props: ConnectedMachineProps) => {
  const { topText, bottomText, backgroundColor, icon } = props;
  return (
    <Stack.Item grow backgroundColor={backgroundColor}>
      <Stack fill vertical align="center" justify="center">
        <Stack.Item height="24px">{topText}</Stack.Item>

        <Stack.Item grow>
          <Icon name={icon} size={10} lineHeight={1.1} />
        </Stack.Item>

        <Stack.Item height="24px">{bottomText}</Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

const SetupScreen = () => {
  const { act, data } = useBackend<SingularityControlData>();
  const [showWarning, setShowWarning] = useSharedState('showWarning', false);

  const emitterCount = data.enabled_emitters + data.disabled_emitters;
  const generatorCount =
    data.enabled_field_generators + data.disabled_field_generators;

  const enoughGenerators = data.enabled_field_generators >= 4;

  return (
    <Window title="Singularity Control Console" width={700} height={320}>
      <Window.Content>
        {!data.has_access && <NoAccessWarning />}

        <Stack vertical fill>
          <Stack.Item grow>
            <Stack fill>
              <ConnectedMachine
                icon={ICON_SHIELD}
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
                          marginLeft: '5px',
                        }}
                      >
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
                    <b>{emitterCount}</b> emitter{emitterCount === 1 ? '' : 's'}
                  </Box>
                }
                icon={ICON_EMITTER}
              />
            </Stack>
          </Stack.Item>

          <Stack.Item height="50px">
            <Stack fill align="center" justify="center">
              {data.stage === Stage.NotStarted && (
                <Stack.Item>
                  {data.emitters_require_shields ? (
                    <Button
                      fontSize="18px"
                      onClick={() => {
                        act('fire_emitters');
                      }}
                      disabled={!enoughGenerators}
                      tooltip={
                        enoughGenerators
                          ? ''
                          : 'You must set up all the field generators first.'
                      }
                    >
                      Fire emitters
                    </Button>
                  ) : showWarning ? (
                    <Stack vertical fill>
                      <Stack.Item>
                        Shields aren&apos;t setup, are you sure?
                      </Stack.Item>

                      <Stack.Item grow textAlign="center">
                        <Button
                          fontSize="14px"
                          color="bad"
                          onClick={() => {
                            act('fire_emitters');
                          }}
                        >
                          Fire anyway
                        </Button>{' '}
                        <Button
                          fontSize="14px"
                          onClick={() => {
                            setShowWarning(false);
                          }}
                        >
                          Cancel
                        </Button>
                      </Stack.Item>
                    </Stack>
                  ) : (
                    <Button
                      fontSize="18px"
                      onClick={() => {
                        if (enoughGenerators) {
                          act('fire_emitters');
                        } else {
                          setShowWarning(true);
                        }
                      }}
                    >
                      Fire emitters
                    </Button>
                  )}
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

const PowerBarDisplay = ({
  color,
  powerBar,
  waitForPokeTooltip,
}: {
  color: readonly [number, number, number];
  powerBar: PowerBar;
  waitForPokeTooltip?: string;
}) => {
  const timeLeft = powerBar.time_to_fill / 10;
  const minutes = Math.floor(timeLeft / 60);
  const seconds = Math.floor(timeLeft % 60);
  const timeText = minutes > 0 ? `${minutes}m ${seconds}s` : `${seconds}s`;

  let tooltipContent;
  switch (powerBar.state) {
    case PowerBarState.WaitingForPoke:
      tooltipContent = waitForPokeTooltip || 'Inactive';
      break;
    case PowerBarState.WaitingLifetime:
      tooltipContent = `${timeText} until decay`;
      break;
    case PowerBarState.WaitingRechargeDelay:
      if (timeLeft === 0) {
        tooltipContent = waitForPokeTooltip || 'Inactive';
      } else {
        tooltipContent = `${timeText} until full`;
      }

      break;
  }

  return (
    <Stack.Item height="100%" width="20%" mr={1}>
      <Tooltip content={tooltipContent} position="bottom">
        <Box
          backgroundColor={withAlpha(color, UNUSED_POWER_BAR_ALPHA)}
          height="100%"
          width="100%"
          position="relative"
        >
          <Box
            backgroundColor={withAlpha(color, USED_POWER_BAR_ALPHA)}
            height={`${powerBar.fill * 100}%`}
            width="100%"
            position="absolute"
            bottom={0}
          />
        </Box>
      </Tooltip>
    </Stack.Item>
  );
};

const OutputWindow = () => {
  const { data } = useBackend<SingularityControlData>();
  const singularityData = data.singularity_data!;

  return (
    <Stack fill height="100%">
      {singularityData.power_bars.map((bar) => (
        <Fragment key={`power_bars_${bar}`}>
          {range(0, bar.power_bar_gain).map((index) => (
            <PowerBarDisplay
              key={`power_bar_${index}`}
              powerBar={bar}
              color={POWER_BAR_COLOR}
            />
          ))}
        </Fragment>
      ))}

      {sortPowerBarsByTimeToFill(singularityData.overclocked_power_bars).map(
        (bar) => (
          <Fragment key={`power_bars_${bar}`}>
            {range(0, bar.power_bar_gain).map((index) => (
              <PowerBarDisplay
                key={`overclocked_power_bar_${index}`}
                powerBar={bar}
                waitForPokeTooltip="Overclock necessary to fill"
                color={OVERCLOCKED_BAR_COLOR}
              />
            ))}
          </Fragment>
        ),
      )}
    </Stack>
  );
};

type EquipmentItemProps = {
  icon: string;
  name: string;
  count: number;
  control?: EquipItemControlProps;
  children?: ReactNode;
};

type EquipItemControlProps = {
  enabled: number;
  disabled: number;
  handleEnableAll: () => void;
  handleDisableAll: () => void;
};

const EquipmentItem = (props: EquipmentItemProps) => {
  const { icon, name, count, control, children } = props;
  return (
    <Stack fill align="center" fontSize="16px">
      <Stack.Item>
        <Icon name={icon} />
      </Stack.Item>

      <Stack.Item>
        <b>{count}</b> {name}
        {count === 1 ? '' : 's'}
      </Stack.Item>

      <Stack.Item grow textAlign="right">
        {control !== undefined && control.disabled !== 0 && (
          <Button onClick={control.handleEnableAll} color="good">
            Enable
          </Button>
        )}

        {control !== undefined && control.enabled !== 0 && (
          <Button onClick={control.handleDisableAll} color="bad">
            Disable
          </Button>
        )}

        {children}
      </Stack.Item>
    </Stack>
  );
};

const EquipmentWindow = () => {
  const { act, data } = useBackend<SingularityControlData>();
  const {
    enabled_field_generators,
    disabled_field_generators,
    enabled_emitters,
    disabled_emitters,
  } = data;
  return (
    <Stack vertical fill>
      <Stack.Item>
        <EquipmentItem
          icon={ICON_EMITTER}
          name="emitter"
          count={enabled_emitters + disabled_emitters}
          control={{
            enabled: enabled_emitters,
            disabled: disabled_emitters,
            handleEnableAll: () => act('enable_all_emitters'),
            handleDisableAll: () => act('disable_all_emitters'),
          }}
        />
      </Stack.Item>

      <Stack.Item>
        <EquipmentItem
          icon={ICON_SHIELD}
          name="shield"
          count={enabled_field_generators + disabled_field_generators}
        >
          <Button disabled tooltip="Must be disabled or enabled by hand.">
            Disable
          </Button>
        </EquipmentItem>
      </Stack.Item>
    </Stack>
  );
};

const OVERCLOCK_TOOLTIPS = {
  [OverclockAccess.Allowed]: null,
  [OverclockAccess.NotAllowed]: null,
  [OverclockAccess.NotAllowedSilicon]:
    'Overclocking is too dangerous for silicons to be trusted with it.',
  [OverclockAccess.NotAllowedTooDamaged]:
    'The singularity is too damaged to be overclocked.',
} as const;

type OverclockWindowProps = {
  handleBeginOverclock: () => void;
};

const OverclockWindow = (props: OverclockWindowProps) => {
  const { act, data } = useBackend<SingularityControlData>();
  const { singularity_data, overclock_access } = data;
  const { handleBeginOverclock } = props;
  const overclockDelay = singularity_data!.delay_to_overclock;

  const timeLeft = overclockDelay / 10;
  const minutes = Math.floor(timeLeft / 60);
  const seconds = Math.floor(timeLeft % 60);

  return (
    <Stack vertical fill fontSize="18px" height="95%" pt={1}>
      <Stack.Item grow>
        <Button
          color="bad"
          width="100%"
          height="100%"
          disabled={
            overclock_access.startsWith('not_allowed_') || overclockDelay > 0
          }
          tooltip={OVERCLOCK_TOOLTIPS[overclock_access]}
          onClick={handleBeginOverclock}
        >
          BEGIN OVERCLOCK
        </Button>
      </Stack.Item>

      <Stack.Item grow>
        {overclockDelay ? (
          <>
            Overclock ready in{' '}
            <b>
              {minutes > 0
                ? `${minutes} minute${minutes === 1 ? '' : 's'}`
                : `${seconds} second${seconds === 1 ? '' : 's'}`}
              .
            </b>
          </>
        ) : (
          <>
            Overclock <b>ready.</b>
          </>
        )}
      </Stack.Item>
    </Stack>
  );
};

type OverclockWarningProps = {
  handleClose: () => void;
  handleOverclock: () => void;
};

const OverclockWarning = (props: OverclockWarningProps) => {
  const { handleClose, handleOverclock } = props;
  return (
    <Stack
      position="absolute"
      backgroundColor="rgba(0, 0, 0, 0.7)"
      width="100%"
      vertical
      fill
      top="0"
      align="center"
      justify="center"
      fontSize="24px"
    >
      <Stack.Item maxWidth="100%">
        <Box textAlign="center">
          <b>WARNING: </b> Overclocking is very dangerous, but very profitable.{' '}
          <br />
          After overclocking, you should focus on repairing the singularity with
          the handheld gravity anchor nearby.
        </Box>
      </Stack.Item>

      <Stack.Item>
        <Button
          color="bad"
          onClick={() => {
            handleOverclock();
            handleClose();
          }}
        >
          Overclock
        </Button>{' '}
        <Button onClick={handleClose}>Cancel</Button>
      </Stack.Item>
    </Stack>
  );
};

const ContainmentBar = ({
  containment_percent,
}: {
  containment_percent: number;
}) => {
  return (
    <Tooltip
      content={
        <>
          At 0%, the singularity will release.
          <p>
            Containment can be repaired by disabling the emitters, sacrificing
            power output.
          </p>
          In an emergency, a massive amount of containment can be repaired with
          the handheld gravity anchor, though it needs an anomaly core.
        </>
      }
      position="right"
    >
      <ProgressBar
        ranges={{
          good: [1, 1],
          average: [0.5, 1],
          bad: [-Infinity, 0.5],
        }}
        value={containment_percent}
      >
        <Stack fill align="center">
          <Stack.Item grow>
            <Box width="100%" textAlign="left" fontSize="18px" my={1}>
              <b>{containment_percent * 100}%</b> contained
            </Box>
          </Stack.Item>

          <Stack.Item>
            <Icon
              name="circle-question"
              fontSize="18px"
              color="rgba(255, 255, 255, 0.6)"
              mt={0.6}
            />
          </Stack.Item>
        </Stack>
      </ProgressBar>
    </Tooltip>
  );
};

const ObserveScreen = () => {
  const { act, data } = useBackend<SingularityControlData>();
  const singularityData = data.singularity_data!;

  const [overclocking, setOverclocking] = useSharedState('overclocking', false);

  return (
    <Window title="Singularity Control Console" width={800} height={480}>
      <Window.Content>
        <Stack fill>
          <Stack.Item grow>
            <Stack fill vertical>
              <Stack.Item grow>
                {!overclocking && (
                  <ByondUi
                    params={{
                      id: data.map_name,
                      type: 'map',
                    }}
                    style={{
                      height: '100%',
                    }}
                  />
                )}
              </Stack.Item>

              <Stack.Item height="30px">
                <ContainmentBar
                  containment_percent={singularityData.containment_percent}
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>

          <Stack.Item grow>
            <Stack vertical fill>
              <Stack.Item height="50%">
                {!data.has_access && <NoAccessWarning />}
                <CoolerSection title="OUTPUT">
                  <OutputWindow />
                </CoolerSection>
              </Stack.Item>

              <Stack.Item grow>
                <CoolerSection title="EQUIPMENT">
                  <EquipmentWindow />
                </CoolerSection>
              </Stack.Item>

              <Stack.Item grow>
                <CoolerSection
                  title={
                    <Tooltip
                      content="Massively increase power output at the cost of massively damaging the singularity, when needed urgently."
                      position="top-start"
                    >
                      <span
                        style={{
                          borderBottom: '2px dotted',
                        }}
                      >
                        OVERCLOCK
                      </span>{' '}
                      <Icon
                        name="circle-question"
                        fontSize="18px"
                        color="rgba(255, 255, 255, 0.6)"
                        mt={0.6}
                      />
                    </Tooltip>
                  }
                >
                  <OverclockWindow
                    handleBeginOverclock={() => {
                      setOverclocking(true);
                    }}
                  />
                </CoolerSection>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>

        {overclocking && (
          <OverclockWarning
            handleClose={() => {
              setOverclocking(false);
            }}
            handleOverclock={() => {
              act('overclock');
            }}
          />
        )}
      </Window.Content>
    </Window>
  );
};

const SelfDestructScreen = () => {
  return (
    <Window title="Singularity Control Console" width={800} height={480}>
      <Window.Content backgroundColor="red">
        <Stack fill vertical align="center" justify="center">
          <Stack.Item>
            <Box color="white" fontSize="35px" bold>
              CONTAINMENT BREACH IMMINENT
            </Box>
          </Stack.Item>

          <Stack.Item>
            <Blink time={300} interval={300}>
              <Icon name="exclamation-triangle" size={20} />
            </Blink>
          </Stack.Item>

          <Stack.Item>
            <Box color="white" fontSize="35px" bold>
              EVACUATE IMMEDIATELY
            </Box>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const DestroyedScreen = () => {
  return (
    <Window title="Singularity Control Console" width={800} height={480}>
      <Window.Content backgroundColor="black">
        <Stack
          fill
          vertical
          align="center"
          justify="center"
          color="white"
          fontFamily="monospace"
          fontSize="12px"
        >
          <Stack.Item>singularity breached containment</Stack.Item>

          <Stack.Item>
            <Blink>SOS</Blink>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

export const SingularityControl = (props, context) => {
  const { data } = useBackend<SingularityControlData>();

  // if (data.stage === )
  switch (data.stage) {
    case Stage.NotStarted:
    case Stage.Preparing:
      return <SetupScreen />;
    case Stage.Finished:
      return <ObserveScreen />;
    case Stage.SelfDestructing:
      return <SelfDestructScreen />;
    case Stage.Destroyed:
      return <DestroyedScreen />;
  }
};
