import { useContext } from 'react';
import {
  Button,
  ColorBox,
  Input,
  LabeledList,
  NumberInput,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { ParticleContext } from '.';
import {
  type EntryGeneratorNumbersListProps,
  type FloatGeneratorColorProps,
  type FloatGeneratorProps,
  P_DATA_GENERATOR,
  type ParticleUIData,
  RandToNumber,
} from './data';
import { GeneratorListEntry } from './Generators';
import { isStringArray } from './helpers';

export const FloatGenerator = (props: FloatGeneratorProps) => {
  const { act } = useBackend<ParticleUIData>();
  const { setDesc } = useContext(ParticleContext);
  const { name, var_name, float } = props;
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
            content="Generator"
            selected={Array.isArray(float)}
            onClick={() =>
              act('edit', {
                var: var_name,
                var_mod: !Array.isArray(float) ? P_DATA_GENERATOR : null,
                new_value: !Array.isArray(float)
                  ? ['num', 0, 1, RandToNumber.UNIFORM_RAND]
                  : 0,
              })
            }
          />
        </Stack.Item>
        {!Array.isArray(float) ? (
          <Stack.Item>
            <NumberInput
              animated
              minValue={-Infinity}
              maxValue={Infinity}
              step={1}
              value={float || 0}
              onDrag={(value) =>
                act('edit', {
                  var: var_name,
                  new_value: value,
                })
              }
            />
          </Stack.Item>
        ) : (
          <GeneratorListEntry var_name={var_name} generator={float} />
        )}
      </Stack>
    </LabeledList.Item>
  );
};

export const FloatGeneratorColor = (props: FloatGeneratorColorProps) => {
  const { act } = useBackend<ParticleUIData>();
  const { setDesc } = useContext(ParticleContext);
  const { name, var_name, float } = props;
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
            content="Generator"
            selected={Array.isArray(float)}
            onClick={() =>
              act('edit', {
                var: var_name,
                var_mod: !Array.isArray(float) ? P_DATA_GENERATOR : null,
                new_value: !Array.isArray(float)
                  ? ['num', 0, 1, RandToNumber.UNIFORM_RAND]
                  : '#FFFFFF',
              })
            }
          />
        </Stack.Item>
        {typeof float === 'string' ? (
          <Stack.Item>
            <ColorBox mt={0.6} mr={0.1} color={float} />
          </Stack.Item>
        ) : null}
        {!Array.isArray(float) ? (
          <Stack.Item>
            <Input
              value={float?.toString()}
              onBlur={(value) =>
                act('edit', {
                  var: var_name,
                  new_value: value,
                })
              }
            />
          </Stack.Item>
        ) : (
          <GeneratorListEntry var_name={var_name} generator={float} />
        )}
      </Stack>
    </LabeledList.Item>
  );
};

export const EntryGeneratorNumbersList = (
  props: EntryGeneratorNumbersListProps,
) => {
  const { act } = useBackend<ParticleUIData>();
  const { setDesc } = useContext(ParticleContext);
  const { name, var_name, allow_z, input } = props;
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
            content="Generator"
            selected={isStringArray(input)}
            onClick={() =>
              act('edit', {
                var: var_name,
                var_mod: !isStringArray(input) ? P_DATA_GENERATOR : null,
                new_value: !isStringArray(input)
                  ? ['sphere', [0, 0, 0], [1, 1, 1], RandToNumber.UNIFORM_RAND]
                  : [1, 1, 1],
              })
            }
          />
        </Stack.Item>
        <Stack.Item>
          <Button
            icon="sync"
            tooltip={'Toggle Array'}
            selected={Array.isArray(input)}
            onClick={() =>
              act('edit', {
                var: var_name,
                new_value: Array.isArray(input) ? 1 : [1, 1, 1],
              })
            }
          />
        </Stack.Item>

        {!Array.isArray(input) ? (
          <Stack.Item>
            <NumberInput
              animated
              minValue={-Infinity}
              maxValue={Infinity}
              step={1}
              value={input || 0}
              onDrag={(value) =>
                act('edit', {
                  var: var_name,
                  new_value: value,
                })
              }
            />
          </Stack.Item>
        ) : isStringArray(input) ? (
          <GeneratorListEntry
            var_name={var_name}
            generator={input}
            allow_vectors
          />
        ) : (
          <Stack.Item>
            <NumberInput
              animated
              minValue={-Infinity}
              maxValue={Infinity}
              step={1}
              value={input[0]}
              onDrag={(value) =>
                act('edit', {
                  var: var_name,
                  new_value: [value, input![1], input![2]],
                })
              }
            />
            <NumberInput
              animated
              minValue={-Infinity}
              maxValue={Infinity}
              step={1}
              value={input[1]}
              onDrag={(value) =>
                act('edit', {
                  var: var_name,
                  new_value: [input![0], value, input![2]],
                })
              }
            />
            {allow_z ? (
              <NumberInput
                animated
                minValue={-Infinity}
                maxValue={Infinity}
                step={1}
                value={input[2]}
                onDrag={(value) =>
                  act('edit', {
                    var: var_name,
                    new_value: [input![0], input![1], value],
                  })
                }
              />
            ) : null}
          </Stack.Item>
        )}
      </Stack>
    </LabeledList.Item>
  );
};
