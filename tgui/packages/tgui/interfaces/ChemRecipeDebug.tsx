import { useState } from 'react';
import {
  Box,
  Button,
  Dropdown,
  LabeledList,
  NumberInput,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { type ActiveReaction, ReactionDisplay } from './ChemHeater';
import { type Beaker, BeakerSectionDisplay } from './common/BeakerDisplay';

const TEMP_MODES = [
  'Reaction Temp',
  'Forced Temp',
  'Minimum Temp',
  'Optimal Temp',
  'Overheat Temp',
];
const REACTION_MODES = ['Next Reaction', 'Previous Reaction', 'Pick Reaction'];
const REACTION_VARS = [
  'Required Temp',
  'Optimal Temp',
  'Overheat Temp',
  'Optimal Min Ph',
  'Optimal Max Ph',
  'Ph Range',
  'Temp Exp Factor',
  'Ph Exp Factor',
  'Thermic Constant',
  'H Ion Release',
  'Rate Up Limit',
  'Purity Min',
];

type BeakerDebug = Beaker & {
  currentTemp: number;
  purity: number;
};

type Reaction = {
  name: string;
  editVar: string;
  editValue: number;
};

type Data = {
  forced_temp: number;
  temp_mode: number;
  forced_ph: number;
  use_forced_ph: BooleanLike;
  forced_purity: number;
  use_forced_purity: number;
  volume_multiplier: number;
  isReacting: BooleanLike;
  current_reaction_name: string;
  current_reaction_mode: number;
  beaker: BeakerDebug;
  isFlashing: number;
  activeReactions: ActiveReaction[];
  editReaction: Reaction;
};

export const ChemRecipeDebug = (props) => {
  const { act, data } = useBackend<Data>();
  const [controlState, setControlState] = useState('Environment');
  const {
    forced_temp,
    temp_mode,
    forced_ph,
    use_forced_ph,
    forced_purity,
    use_forced_purity,
    volume_multiplier,
    isReacting,
    current_reaction_name,
    current_reaction_mode,
    beaker,
    isFlashing,
    activeReactions,
    editReaction,
  } = data;
  return (
    <Window width={500} height={600}>
      <Window.Content scrollable>
        <Section title="Controls">
          <Tabs>
            <Tabs.Tab
              key={'Environment'}
              selected={controlState === 'Environment'}
              onClick={() => setControlState('Environment')}
            >
              Environment
            </Tabs.Tab>
            <Tabs.Tab
              key={'Reactions'}
              selected={controlState === 'Reactions'}
              onClick={() => setControlState('Reactions')}
            >
              Reactions
            </Tabs.Tab>
            <Tabs.Tab
              key={'Editing'}
              selected={controlState === 'Editing'}
              onClick={() => setControlState('Editing')}
            >
              Edit Reactions
            </Tabs.Tab>
          </Tabs>
          {controlState === 'Environment' && (
            <Section>
              <Stack vertical={false}>
                <Stack.Item>
                  <LabeledList>
                    <LabeledList.Item label="Temperature">
                      <NumberInput
                        width="65px"
                        step={1}
                        stepPixelSize={3}
                        value={forced_temp}
                        minValue={0}
                        maxValue={1000}
                        onDrag={(value) =>
                          act('forced_temp', {
                            target: value,
                          })
                        }
                      />
                    </LabeledList.Item>
                  </LabeledList>
                </Stack.Item>
                <Stack.Item>
                  <LabeledList>
                    <LabeledList.Item
                      label={
                        <Box
                          style={{
                            transform: 'translate(0%, -50%)',
                          }}
                        >
                          Temp Mode:
                        </Box>
                      }
                    >
                      <Dropdown
                        width="100%"
                        selected={TEMP_MODES[temp_mode]}
                        options={TEMP_MODES}
                        onSelected={(value) =>
                          act('temp_mode', {
                            target: value,
                          })
                        }
                      />
                    </LabeledList.Item>
                  </LabeledList>
                </Stack.Item>
              </Stack>
              <Stack vertical={false} mt="10px">
                <Stack.Item>
                  <LabeledList>
                    <LabeledList.Item label={<Box width="82px">PH:</Box>}>
                      <NumberInput
                        width="65px"
                        step={1}
                        stepPixelSize={3}
                        value={forced_ph}
                        minValue={0}
                        maxValue={14}
                        onDrag={(value) =>
                          act('forced_ph', {
                            target: value,
                          })
                        }
                      />
                    </LabeledList.Item>
                  </LabeledList>
                </Stack.Item>
                <Stack.Item ml="0px">
                  <LabeledList>
                    <LabeledList.Item label="Force Ph">
                      <Button.Checkbox
                        checked={use_forced_ph}
                        onClick={() => act('toggle_forced_ph')}
                      >
                        {use_forced_ph ? 'Disable' : 'Enable'}
                      </Button.Checkbox>
                    </LabeledList.Item>
                  </LabeledList>
                </Stack.Item>
              </Stack>
              <Stack vertical={false} mt="10px">
                <Stack.Item>
                  <LabeledList>
                    <LabeledList.Item label={<Box width="82px">Purity:</Box>}>
                      <NumberInput
                        width="65px"
                        step={0.01}
                        stepPixelSize={3}
                        value={forced_purity}
                        minValue={0}
                        maxValue={1}
                        onDrag={(value) =>
                          act('forced_purity', {
                            target: value,
                          })
                        }
                      />
                    </LabeledList.Item>
                  </LabeledList>
                </Stack.Item>
                <Stack.Item ml="10px">
                  <LabeledList>
                    <LabeledList.Item label="Force Purity">
                      <Button.Checkbox
                        checked={use_forced_purity}
                        onClick={() => act('toggle_forced_purity')}
                      >
                        {use_forced_purity ? 'Disable' : 'Enable'}
                      </Button.Checkbox>
                    </LabeledList.Item>
                  </LabeledList>
                </Stack.Item>
              </Stack>
              <Stack vertical={false} mt="10px">
                <Stack.Item>
                  <LabeledList>
                    <LabeledList.Item label="Volume Mulx">
                      <NumberInput
                        width="65px"
                        step={1}
                        stepPixelSize={3}
                        value={volume_multiplier}
                        minValue={1}
                        maxValue={1000}
                        unit="x"
                        onDrag={(value) =>
                          act('volume_multiplier', {
                            target: value,
                          })
                        }
                      />
                    </LabeledList.Item>
                  </LabeledList>
                </Stack.Item>
              </Stack>
            </Section>
          )}
          {controlState === 'Reactions' && (
            <Section>
              <Stack vertical>
                <Stack.Item>
                  <LabeledList>
                    <LabeledList.Item label="Reagent">
                      <Button
                        color="green"
                        onClick={() => act('pick_reaction')}
                      >
                        Select Reaction
                      </Button>
                    </LabeledList.Item>
                  </LabeledList>
                </Stack.Item>
                <Stack.Item mt="20px">
                  <LabeledList>
                    <LabeledList.Item label="Reaction">
                      {current_reaction_name}
                    </LabeledList.Item>
                  </LabeledList>
                </Stack.Item>
                <Stack.Item mt="20px">
                  <LabeledList>
                    <LabeledList.Item
                      label={
                        <Box
                          style={{
                            transform: 'translate(0%, -50%)',
                          }}
                        >
                          Direction:
                        </Box>
                      }
                    >
                      <Dropdown
                        width="35%"
                        selected={REACTION_MODES[current_reaction_mode]}
                        options={REACTION_MODES}
                        disabled={current_reaction_name === 'N/A'}
                        onSelected={(value) =>
                          act('reaction_mode', {
                            target: value,
                          })
                        }
                      />
                    </LabeledList.Item>
                  </LabeledList>
                </Stack.Item>
                <Stack.Item mt="20px">
                  <LabeledList>
                    <LabeledList.Item label={<Box width="60px">Process:</Box>}>
                      <Button
                        color="green"
                        icon="play"
                        disabled={isReacting || current_reaction_name === 'N/A'}
                        onClick={() => act('start_reaction')}
                      >
                        Play
                      </Button>
                    </LabeledList.Item>
                  </LabeledList>
                </Stack.Item>
              </Stack>
            </Section>
          )}
          {controlState === 'Editing' && (
            <Section>
              <Stack vertical>
                <Stack.Item>
                  <LabeledList>
                    <LabeledList.Item label="Reaction">
                      <Button
                        color="green"
                        icon="flask"
                        onClick={() => act('edit_reaction')}
                      >
                        {editReaction?.name || 'Edit Reaction'}
                      </Button>
                    </LabeledList.Item>
                  </LabeledList>
                </Stack.Item>
                <Stack.Item mt="20px">
                  <LabeledList>
                    <LabeledList.Item
                      label={
                        <Box
                          style={{
                            transform: 'translate(0%, -50%)',
                            width: '57px',
                          }}
                        >
                          Param:
                        </Box>
                      }
                    >
                      <Dropdown
                        width="40%"
                        selected={editReaction?.editVar || REACTION_VARS[1]}
                        options={REACTION_VARS}
                        onSelected={(value) =>
                          act('edit_var', { target: value })
                        }
                        disabled={editReaction === null}
                      />
                    </LabeledList.Item>
                  </LabeledList>
                </Stack.Item>
                <Stack.Item mt="20px">
                  <LabeledList>
                    <LabeledList.Item label={<Box width="57px">Value:</Box>}>
                      <NumberInput
                        width="65px"
                        step={0.1}
                        stepPixelSize={3}
                        value={editReaction?.editValue || 0}
                        minValue={-1000}
                        maxValue={1000}
                        disabled={editReaction === null}
                        onDrag={(value) =>
                          act('edit_value', {
                            target: value,
                          })
                        }
                      />
                      <Button
                        color="green"
                        icon="sync"
                        tooltip="Reset Value"
                        disabled={editReaction === null}
                        onClick={() => act('reset_value')}
                      />
                    </LabeledList.Item>
                  </LabeledList>
                </Stack.Item>
                <Stack.Item mt="20px">
                  <LabeledList>
                    <LabeledList.Item label={<Box width="57px">Export:</Box>}>
                      <Button
                        color="green"
                        icon="save"
                        onClick={() => act('export')}
                        disabled={editReaction === null}
                      >
                        Export
                      </Button>
                    </LabeledList.Item>
                  </LabeledList>
                </Stack.Item>
              </Stack>
            </Section>
          )}
        </Section>
        {beaker && (
          <Section title="Variables">
            <LabeledList>
              <LabeledList.Item label="Temperature">
                {beaker.currentTemp}
              </LabeledList.Item>
              <LabeledList.Item label="Purity">
                {beaker.purity}
              </LabeledList.Item>
            </LabeledList>
          </Section>
        )}
        {beaker && (
          <ReactionDisplay
            beaker={beaker}
            isFlashing={isFlashing}
            activeReactions={activeReactions}
            highQualityDisplay
            highDangerDisplay
          />
        )}
        <BeakerSectionDisplay
          title_label="Internal Buffer"
          beaker={beaker}
          showpH={false}
        />
      </Window.Content>
    </Window>
  );
};
