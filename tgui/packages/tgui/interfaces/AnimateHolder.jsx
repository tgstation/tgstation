import { useBackend } from '../backend';
import { Window } from '../layouts';
import {
  Button,
  Input,
  Section,
  Collapsible,
  LabeledList,
  NumberInput,
  Dropdown,
} from '../components';
import { ButtonCheckbox } from '../components/Button';

export const AnimateHolder = (props) => {
  const { act, data } = useBackend();
  return (
    <Window title="Animate Holder" width={550} height={350}>
      <Window.Content>
        <AnimateSteps />
      </Window.Content>
    </Window>
  );
};

const AnimateSteps = (props) => {
  const { act, data } = useBackend();
  const { steps, easings, random_vars } = data;

  const variables = [
    { name: 'time', type: 'number' },
    { name: 'loop', type: 'number' },
    { name: 'pixel_y', type: 'number' },
    { name: 'pixel_x', type: 'number' },
    { name: 'color', type: 'text' },
    { name: 'alpha', type: 'number' },
    { name: 'maptext', type: 'text' },
    { name: 'maptext_y', type: 'number' },
    { name: 'maptext_x', type: 'number' },
    { name: 'maptext_width', type: 'number' },
    { name: 'maptext_height', type: 'number' },
    { name: 'layer', type: 'number' },
    { name: 'luminosity', type: 'number' },
    { name: 'dir', type: 'number' },
  ];

  return (
    <Section fill scrollable title="Animation Steps">
      {steps.map((step, index) => (
        <Collapsible key={index} title={'Step:' + (index + 1)}>
          <LabeledList>
            {variables.map(({ name, type }) => {
              const isRandom = step[name] === 'RANDOM';
              const randomRange =
                isRandom && random_vars[index] && random_vars[index][name];
              const [randomMin, randomMax] = randomRange || [0, 0];

              return (
                <LabeledList.Item key={name} label={name.toUpperCase()}>
                  {type === 'number' ? (
                    <ButtonCheckbox
                      checked={isRandom}
                      onClick={() =>
                        act('modify_rand_state', {
                          variable: name,
                          index: index + 1,
                        })
                      }
                    >
                      RANDOM
                    </ButtonCheckbox>
                  ) : null}
                  {isRandom ? (
                    <div>
                      <NumberInput
                        width="45px"
                        minValue={-1000}
                        maxValue={1000}
                        value={randomMin}
                        onChange={(_, value) =>
                          act('set_random_value', {
                            variable: name,
                            rand_lower: value,
                            index: index + 1,
                          })
                        }
                      />
                      <NumberInput
                        width="45px"
                        minValue={-1000}
                        maxValue={1000}
                        value={randomMax}
                        onChange={(_, value) =>
                          act('set_random_value', {
                            variable: name,
                            rand_upper: value,
                            index: index + 1,
                          })
                        }
                      />
                    </div>
                  ) : type === 'number' ? (
                    <NumberInput
                      width="45px"
                      minValue={-1000}
                      maxValue={1000}
                      value={step[name] !== undefined ? step[name] : 0}
                      onChange={(_, value) =>
                        act('modify_step', {
                          variable: name,
                          value: value,
                          index: index + 1,
                        })
                      }
                    />
                  ) : (
                    <Input
                      value={step[name] !== undefined ? step[name] : ''}
                      width="90px"
                      onInput={(e, value) =>
                        act('modify_step', {
                          variable: name,
                          value: value,
                          index: index + 1,
                        })
                      }
                    />
                  )}
                </LabeledList.Item>
              );
            })}
            <LabeledList.Item label={'Easing'}>
              {Object.entries(easings[index]).map(([key, value]) => (
                <ButtonCheckbox
                  key={key}
                  checked={value}
                  onClick={() =>
                    act('modify_easing', {
                      flag: key,
                      value: !value,
                      index: index + 1,
                    })
                  }
                >
                  {key}
                </ButtonCheckbox>
              ))}
            </LabeledList.Item>
            <LabeledList.Item label={'Transform'}>
              <Transform step={index + 1} />
            </LabeledList.Item>
          </LabeledList>
          <Button
            color="red"
            icon="sync"
            width="100%"
            onClick={() => act('remove_step', { index: index + 1 })}
          >
            Delete Step
          </Button>
        </Collapsible>
      ))}
      <Button
        color="green"
        icon="sync"
        width="100%"
        onClick={() => act('add_blank_step')}
      >
        Create New Step
      </Button>
    </Section>
  );
};

export const Transform = (props) => {
  const { step } = props;
  const { act, data } = useBackend();
  const { steps, transforms, transform_types, random_vars } = data;
  const types = ['rotate', 'scale', 'translate'];

  const stepData = steps[step - 1];
  const transformType = transform_types[step - 1];
  const transformValues = transforms[step - 1];
  const randomRange = random_vars[step - 1] && random_vars[step - 1].transform;
  const [randomMin, randomMax] = randomRange || [0, 0];
  const isRandom = stepData.transform === 'RANDOM';

  const returnString = (value) => {
    switch (value) {
      case 5:
        return 'Rotate';
      case 6:
        return 'Scale';
      case 7:
        return 'Translate';
      default:
        return 'None';
    }
  };

  return (
    <Section>
      <ButtonCheckbox
        checked={isRandom}
        onClick={() =>
          act('modify_rand_state', {
            index: step,
            variable: 'transform',
          })
        }
      >
        RANDOM
      </ButtonCheckbox>
      <Dropdown
        options={types}
        displayText={transformType ? returnString(transformType) : 'None'}
        color="black"
        width="100%"
        onSelected={(value) =>
          act('modify_transform_value', {
            matrix_type: value,
            index: step,
          })
        }
      />
      {isRandom ? (
        <div>
          <NumberInput
            width="45px"
            minValue={-1000}
            maxValue={1000}
            value={randomMin}
            onChange={(_, value) =>
              act('set_random_value', {
                variable: 'transform',
                index: step,
                rand_lower: value,
              })
            }
          />
          <NumberInput
            width="45px"
            minValue={-1000}
            maxValue={1000}
            value={randomMax}
            onChange={(_, value) =>
              act('set_random_value', {
                variable: 'transform',
                index: step,
                rand_upper: value,
              })
            }
          />
        </div>
      ) : (
        <div style={{ display: 'flex', alignItems: 'center' }}>
          <NumberInput
            width="45px"
            minValue={-1000}
            maxValue={1000}
            value={transformValues[0]}
            onChange={(e, value) =>
              act('modify_transform_value', {
                value1: value,
                index: step,
              })
            }
          />
          {(transformType === 6 || transformType === 7) && (
            <NumberInput
              width="45px"
              minValue={-1000}
              maxValue={1000}
              value={transformValues[1]}
              onChange={(e, value) =>
                act('modify_transform_value', {
                  value2: value,
                  index: step,
                })
              }
            />
          )}
        </div>
      )}
      <Button
        color="red"
        icon="sync"
        width="100%"
        onClick={() =>
          act('modify_transform', {
            index: step,
          })
        }
      >
        Confirm
      </Button>
    </Section>
  );
};
