import { BasicInput } from './BasicInput';
import { NumberInput, Button, Stack, Input } from '../../components';

export const FUNDAMENTAL_DATA_TYPES = {
  'string': (props, context) => {
    const { name, value, setValue, color } = props;
    return (
      <BasicInput name={name} setValue={setValue} value={value} defaultValue="">
        <Input
          placeholder={name}
          value={value}
          onChange={(e, val) => setValue(val)}
        />
      </BasicInput>
    );
  },
  'number': (props, context) => {
    const { name, value, setValue, color } = props;
    return (
      <BasicInput
        name={name}
        setValue={setValue}
        value={value}
        defaultValue={0}>
        <NumberInput
          value={value}
          color={color}
          onChange={(e, val) => setValue(val)}
          unit={name}
        />
      </BasicInput>
    );
  },
  'entity': (props, context) => {
    const { name, setValue, color } = props;
    return (
      <Button
        content={name}
        color="transparent"
        icon="upload"
        compact
        onClick={() => setValue(null, { marked_atom: true })}
      />
    );
  },
  'signal': (props, context) => {
    const { name, setValue } = props;
    return (
      <Button
        content={name}
        color="transparent"
        compact
        onClick={() => setValue()}
      />
    );
  },
  'any': (props, context) => {
    const { name, value, setValue, color } = props;
    return (
      <BasicInput
        name={name}
        setValue={setValue}
        value={value}
        defaultValue={''}>
        <Stack>
          <Stack.Item>
            <Button
              color={color}
              icon="upload"
              onClick={() => setValue(null, { marked_atom: true })}
            />
          </Stack.Item>
          <Stack.Item>
            <Input
              placeholder={name}
              value={value}
              onChange={(e, val) => setValue(val)}
            />
          </Stack.Item>
        </Stack>
      </BasicInput>
    );
  },
};
