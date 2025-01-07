import { useContext } from 'react';
import {
  Box,
  Button,
  ColorBox,
  Dropdown,
  Input,
  LabeledList,
  NumberInput,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { ParticleContext } from '.';
import {
  EntryCoordProps,
  EntryFloatProps,
  EntryGradientProps,
  EntryIconStateProps,
  EntryTransformProps,
  MatrixTypes,
  P_DATA_ICON_ADD,
  P_DATA_ICON_REMOVE,
  P_DATA_ICON_WEIGHT,
  ParticleUIData,
  SpaceToNum,
  SpaceTypes,
} from './data';
import { editKeyOf, editWeightOf, setGradientSpace } from './helpers';

export const EntryFloat = (props: EntryFloatProps) => {
  const { act } = useBackend<ParticleUIData>();
  const { setDesc } = useContext(ParticleContext);
  const { name, var_name, float } = props;
  return (
    <LabeledList.Item label={name}>
      <Button
        icon={'question'}
        onClick={() => setDesc(var_name)}
        tooltip={'View details'}
      />
      <NumberInput
        animated
        value={float}
        minValue={0}
        maxValue={Infinity}
        step={1}
        onDrag={(value) =>
          act('edit', {
            var: var_name,
            new_value: value,
          })
        }
      />
    </LabeledList.Item>
  );
};

export const EntryCoord = (props: EntryCoordProps) => {
  const { act } = useBackend<ParticleUIData>();
  const { setDesc } = useContext(ParticleContext);
  const { name, var_name, coord } = props;
  return (
    <LabeledList.Item label={name}>
      <Button
        icon={'question'}
        onClick={() => setDesc(var_name)}
        tooltip={'View details'}
      />
      <NumberInput
        animated
        minValue={-Infinity}
        maxValue={Infinity}
        step={1}
        value={coord?.[0] || 0}
        onDrag={(value) =>
          act('edit', {
            var: var_name,
            new_value: [value, coord?.[1], coord?.[2]],
          })
        }
      />
      <NumberInput
        animated
        minValue={-Infinity}
        maxValue={Infinity}
        step={1}
        value={coord?.[1] || 0}
        onDrag={(value) =>
          act('edit', {
            var: var_name,
            new_value: [coord?.[0], value, coord?.[2]],
          })
        }
      />
      <NumberInput
        animated
        minValue={-Infinity}
        maxValue={Infinity}
        step={1}
        value={coord?.[2] || 0}
        onDrag={(value) =>
          act('edit', {
            var: var_name,
            new_value: [coord?.[0], coord?.[1], value],
          })
        }
      />
    </LabeledList.Item>
  );
};

export const EntryGradient = (props: EntryGradientProps) => {
  const { act } = useBackend<ParticleUIData>();
  const { setDesc } = useContext(ParticleContext);
  const { name, var_name, gradient } = props;
  const isLooping = gradient?.find((x) => x === 'loop');
  const space_type = gradient?.includes('space')
    ? Object.keys(SpaceToNum).find(
        (space) => SpaceToNum[space] === gradient['space'],
      )
    : 'COLORSPACE_RGB';
  return (
    <LabeledList.Item label={name}>
      <Stack>
        <Stack.Item>
          <Button
            icon={'question'}
            onClick={() => setDesc(var_name)}
            tooltip={'View details'}
          />
        </Stack.Item>
        <Stack.Item>
          <Button
            tooltip={'Loop'}
            icon={'sync'}
            selected={!!isLooping}
            onClick={() =>
              act('edit', {
                var: var_name,
                new_value: isLooping
                  ? gradient!.filter((x, i) => i !== gradient!.indexOf('loop'))
                  : [...(gradient || []), 'loop'],
              })
            }
          />
        </Stack.Item>
        <Stack.Item>
          <Dropdown
            options={SpaceTypes}
            selected={space_type}
            onSelected={(e) =>
              act('edit', {
                var: var_name,
                new_value: gradient
                  ? setGradientSpace(gradient, SpaceToNum[e])
                  : { space: SpaceToNum[e] },
              })
            }
            width="145px"
          />
        </Stack.Item>
        <Stack.Item>
          {gradient?.map((entry, index) =>
            entry === 'loop' || entry === 'space' ? null : (
              <>
                {typeof entry === 'string' ? (
                  <ColorBox mr={0.4} color={entry} />
                ) : null}
                <Input
                  key={index}
                  maxWidth={'70px'}
                  value={entry}
                  onChange={(e, value) =>
                    act('edit', {
                      var: var_name,
                      new_value: gradient!.map((x, i) =>
                        i === index ? value : x,
                      ),
                    })
                  }
                />
                <Button
                  icon={'minus'}
                  tooltip={'Remove entry'}
                  onClick={() =>
                    act('edit', {
                      var: var_name,
                      new_value: gradient.filter((x, i) => i !== index),
                    })
                  }
                />
              </>
            ),
          )}
        </Stack.Item>
        <Stack.Item>
          <Button
            icon={'add'}
            tooltip={'Add new entry'}
            onClick={() =>
              act('edit', {
                var: var_name,
                new_value: [...(gradient || []), '#FFFFFF'],
              })
            }
          />
        </Stack.Item>
      </Stack>
    </LabeledList.Item>
  );
};

export const EntryTransform = (props: EntryTransformProps) => {
  const { act } = useBackend<ParticleUIData>();
  const { setDesc } = useContext(ParticleContext);
  const len = props.transform?.length ? props.transform.length : 0;
  const selected =
    len < 7
      ? 'Simple Matrix'
      : len < 13
        ? 'Complex Matrix'
        : 'Projection Matrix';
  const { name, var_name, transform } = props;
  return (
    <LabeledList.Item label={name}>
      <Stack>
        <Stack.Item>
          <Button
            icon={'question'}
            onClick={() => setDesc(var_name)}
            tooltip={'View details'}
          />
        </Stack.Item>
        <Stack.Item>
          <Dropdown
            options={MatrixTypes}
            selected={selected}
            onSelected={(e) => act('transform_size', { new_value: e })}
            width="130px"
          />
        </Stack.Item>
        <Stack.Item>
          {transform?.map((value, index) => (
            <NumberInput
              animated
              key={index}
              value={value}
              minValue={0}
              maxValue={1}
              step={1}
              onDrag={(value) =>
                act('edit', {
                  var: var_name,
                  new_value: transform!.map((x, i) =>
                    i === index ? value : x,
                  ),
                })
              }
            />
          ))}
        </Stack.Item>
      </Stack>
    </LabeledList.Item>
  );
};

export const EntryIcon = (props: EntryIconStateProps) => {
  const { act } = useBackend<ParticleUIData>();
  const { setDesc } = useContext(ParticleContext);
  const { name, var_name, icon_state } = props;
  return (
    <LabeledList.Item label={name}>
      <Stack>
        <Stack.Item>
          <Button
            icon={'question'}
            onClick={() => setDesc(var_name)}
            tooltip={'View details'}
          />
        </Stack.Item>
        {typeof icon_state === 'object' && icon_state !== null ? (
          Object.keys(icon_state).map((icon_name, i) => (
            <>
              <Stack.Item key={i}>{icon_name}</Stack.Item>
              <Stack.Item>
                <Box> = </Box>
              </Stack.Item>
              <Stack.Item>
                <NumberInput
                  animated
                  minValue={0}
                  maxValue={Infinity}
                  step={1}
                  value={icon_state[icon_name]}
                  onDrag={(value) =>
                    act('edit', {
                      var: var_name,
                      var_mod: P_DATA_ICON_WEIGHT,
                      new_value: [icon_name, value],
                    })
                  }
                />
              </Stack.Item>
              <Button
                icon={'minus'}
                onClick={() =>
                  act('edit', {
                    var: var_name,
                    var_mod: P_DATA_ICON_REMOVE,
                    new_value: icon_name,
                  })
                }
              />
            </>
          ))
        ) : (
          <>
            <Stack.Item>{icon_state}</Stack.Item>
            <Stack.Item>
              <Box> = </Box>
            </Stack.Item>
            <Stack.Item>1</Stack.Item>
          </>
        )}
        <Stack.Item>
          <Button
            icon={'add'}
            onClick={() =>
              act('edit', {
                var: var_name,
                var_mod: P_DATA_ICON_ADD,
              })
            }
          />
        </Stack.Item>
      </Stack>
    </LabeledList.Item>
  );
};

export const EntryIconState = (props: EntryIconStateProps) => {
  const { act } = useBackend<ParticleUIData>();
  const { setDesc } = useContext(ParticleContext);
  const { name, var_name, icon_state } = props;
  const newValue =
    typeof icon_state === 'string'
      ? { [icon_state]: 1, None: 0 }
      : { ...icon_state, None: 0 };
  return (
    <LabeledList.Item label={name}>
      <Stack>
        <Stack.Item>
          <Button
            icon={'question'}
            onClick={() => setDesc(var_name)}
            tooltip={'View details'}
          />
        </Stack.Item>
        {typeof icon_state === 'object' && icon_state !== null ? (
          // this can get big enough to go off the edge of the screen and scrollableHorizontal isnt working
          // so if someone inputs like 10 icon states at once its #notmyproblem
          Object.keys(icon_state).map((iconstate, index) => (
            <>
              <Stack.Item>
                <Input
                  width={'70px'}
                  value={iconstate}
                  onChange={(e, value) =>
                    act('edit', {
                      var: var_name,
                      new_value: editKeyOf(icon_state, iconstate, value),
                    })
                  }
                />
              </Stack.Item>
              <Stack.Item>
                <Box> = </Box>
              </Stack.Item>
              <Stack.Item>
                <NumberInput
                  animated
                  minValue={0}
                  maxValue={Infinity}
                  step={1}
                  value={icon_state[iconstate]}
                  onDrag={(value) =>
                    act('edit', {
                      var: var_name,
                      new_value: editWeightOf(icon_state, iconstate, value),
                    })
                  }
                />
              </Stack.Item>
              <Stack.Item>
                <Button
                  icon={'minus'}
                  onClick={() =>
                    act('edit', {
                      var: var_name,
                      new_value: Object.fromEntries(
                        Object.entries(icon_state).filter(
                          ([key]) => key !== iconstate,
                        ),
                      ),
                    })
                  }
                />
              </Stack.Item>
            </>
          ))
        ) : (
          <>
            <Input
              value={icon_state ? icon_state : 'None'}
              onChange={(e, value) =>
                act('edit', {
                  var: var_name,
                  new_value: value,
                })
              }
            />
            = 1
          </>
        )}
        <Button
          icon={'plus'}
          onClick={() =>
            act('edit', {
              var: var_name,
              new_value: newValue,
            })
          }
        />
      </Stack>
    </LabeledList.Item>
  );
};
