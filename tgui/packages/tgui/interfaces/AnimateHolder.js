import { useBackend } from '../backend';
import { Window } from '../layouts';
import { Button, Input, Section, Collapsible, LabeledList, NumberInput, Dropdown } from '../components';
import { ButtonCheckbox } from '../components/Button';

export const AnimateHolder = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window title="Animate Holder" width={550} height={350}>
      <Window.Content>
        <AnimateSteps />
      </Window.Content>
    </Window>
  );
};

const AnimateSteps = (props, context) => {
  const { act, data } = useBackend(context);
  const { steps, easings } = data;

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
      {steps.map((step) => (
        <Collapsible
          key={step.index}
          title={'Step:' + (steps.indexOf(step) + 1)}>
          <LabeledList>
            {variables.map(({ name, type }) => (
              <LabeledList.Item key={name} label={name.toUpperCase()}>
                {type === 'number' ? (
                  <NumberInput
                    width="45px"
                    minValue={-1000}
                    maxValue={1000}
                    value={step[name] !== undefined ? step[name] : 0}
                    onChange={(_, value) =>
                      act('modify_step', {
                        variable: name,
                        value: value,
                        index: steps.indexOf(step) + 1,
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
                        index: steps.indexOf(step) + 1,
                      })
                    }
                  />
                )}
              </LabeledList.Item>
            ))}
            <LabeledList.Item label={'Easing'}>
              {Object.entries(easings[steps.indexOf(step)]).map(
                ([key, value]) => (
                  <ButtonCheckbox
                    key={key}
                    checked={value}
                    onClick={() =>
                      act('modify_easing', {
                        flag: key,
                        value: !value,
                        index: steps.indexOf(step) + 1,
                      })
                    }>
                    {key}
                  </ButtonCheckbox>
                )
              )}
            </LabeledList.Item>
          </LabeledList>
          <Button
            color="red"
            icon="sync"
            width="100%"
            onClick={() =>
              act('remove_step', { index: steps.indexOf(step) + 1 })
            }>
            Delete Step
          </Button>
        </Collapsible>
      ))}
      <Button
        color="green"
        icon="sync"
        width="100%"
        onClick={() => act('add_blank_step')}>
        Create New Step
      </Button>
    </Section>
  );
};

export const Transform = (props, context) => {
  const { step } = props;
  const { act, data } = useBackend(context);
  const { steps, easings, transforms, transform_types } = data;
  const types = ['rotate', 'scale', 'translate'];

  // Get the transform type and transform values for the current step
  const transformType = transform_types[step - 1]; // Adjust index since steps are 1-indexed
  const transformValues = transforms[step - 1]; // Adjust index since steps are 1-indexed

  // Function to return string representation of transform type
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

  // Function to handle change in transform value
  const handleTransformChange = (index, value) => {
    act('modify_transform_value', {
      value1: value,
      index: index,
    });
  };

  return (
    <Section>
      <Dropdown
        options={['rotate', 'scale', 'translate']}
        displayText={returnString(transformType)}
        color="black"
        width="100%"
        onSelected={(value) =>
          act('modify_transform_value', {
            matrix_type: value,
            index: step,
          })
        }
      />
      <NumberInput
        width="45px"
        minValue={-1000}
        maxValue={1000}
        value={transformValues[0]} // First value of transform
        onChange={(e, value) => handleTransformChange(step, value)}
      />
      {transformType === 6 && ( // Render second input only if transform type is Scale (value 6)
        <NumberInput
          width="45px"
          minValue={-1000}
          maxValue={1000}
          value={transformValues[1]} // Second value of transform (only for Scale)
          onChange={(e, value) =>
            act('modify_transform_value', {
              value2: value,
              index: step,
            })
          }
        />
      )}
      <Button
        color="red"
        icon="sync"
        width="100%"
        onClick={() =>
          act('modify_transform', {
            index: step,
          })
        }>
        Confirm
      </Button>
    </Section>
  );
};
