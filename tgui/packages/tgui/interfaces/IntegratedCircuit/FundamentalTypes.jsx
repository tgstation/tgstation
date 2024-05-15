import { Button, Dropdown, Input, NumberInput, Stack } from '../../components';
import { BasicInput } from './BasicInput';
import { OPTION_DROPDOWN_LARGE_CHAR_AMOUNT } from './constants';

export const FUNDAMENTAL_DATA_TYPES = {
  string: (props) => {
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
  number: (props) => {
    const { name, value, setValue, color } = props;
    return (
      <BasicInput
        name={name}
        setValue={setValue}
        value={value}
        defaultValue={0}
      >
        <NumberInput
          step={1}
          value={value}
          color={color}
          onChange={(val) => setValue(val)}
          unit={name}
        />
      </BasicInput>
    );
  },
  entity: (props) => {
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
  datum: (props) => {
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
  signal: (props) => {
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
  option: (props) => {
    const { value, setValue } = props;
    let large = false;
    const extraData = props.extraData || [];
    const data = Array.isArray(extraData) ? extraData : Object.keys(extraData);

    data.forEach((element) => {
      if (element.length > OPTION_DROPDOWN_LARGE_CHAR_AMOUNT) {
        large = true;
      }
    });

    return (
      <Dropdown
        className="IntegratedCircuit__BlueBorder"
        color={'transparent'}
        options={data}
        onSelected={setValue}
        selected={value}
        menuWidth={large ? '200px' : undefined}
      />
    );
  },
  any: (props) => {
    const { name, value, setValue, color } = props;
    return (
      <BasicInput
        name={name}
        setValue={setValue}
        value={value}
        defaultValue={''}
      >
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
  option: (port) => {
    return port.name.toLowerCase();
  },
};
