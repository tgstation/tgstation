import { BasicInput } from './BasicInput';
import { NumberInput, Button, Stack, Input, Dropdown, Box } from '../../components';

export const FUNDAMENTAL_DATA_TYPES = {
  'string': (props, context) => {
    const { name, value, setValue, color } = props;
    return (
      <BasicInput name={name} setValue={setValue} value={value} defaultValue="">
        <Input
          placeholder={name}
          value={value}
          onChange={(e, val) => setValue(val)}
          width="96px"
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
    const { name, setValue } = props;
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
  'option': (props, context) => {
    const { value, setValue, extraData } = props;
    return (
      <Dropdown
        className="Datatype__Option"
        color={"transparent"}
        options={Array.isArray(extraData)
          ? extraData
          : Object.keys(extraData)}
        onSelected={setValue}
        displayText={value}
        noscroll
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
              width="64px"
            />
          </Stack.Item>
        </Stack>
      </BasicInput>
    );
  },
};

export const DATATYPE_DISPLAY_HANDLERS = {
  'option': (port) => {
    return port.name.toLowerCase();
  },
};
