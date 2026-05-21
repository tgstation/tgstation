import {
  Button,
  Dropdown,
  Input,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Port = {
  name: string;
  color: string;
  datatype: string;
};

type ProcCallMenuData = {
  input_ports: Port[];
  possible_types: string[];
  expected_output: string;
  expected_output_color: string;
  resolve_weakref: BooleanLike;
};

export const ProcCallMenu = (props) => {
  const { act, data } = useBackend<ProcCallMenuData>();
  const {
    input_ports,
    possible_types,
    expected_output,
    expected_output_color,
    resolve_weakref,
  } = data;
  return (
    <Window width={500} height={400}>
      <Window.Content scrollable>
        <Stack fill>
          <Stack.Item>
            <Section fill title="Options">
              <Stack vertical width="180px">
                <Stack.Item color="label">Expected Output:</Stack.Item>
                <Stack.Item>
                  <Dropdown
                    width="100%"
                    selected={expected_output}
                    options={possible_types}
                    color={expected_output_color}
                    onSelected={(value) =>
                      act('set_expected_output', { datatype: value })
                    }
                  />
                </Stack.Item>
                <Stack.Divider />
                <Stack.Item>
                  <Button.Checkbox
                    content="Resolve Weakref"
                    textAlign="center"
                    checked={resolve_weakref}
                    onClick={() => act('resolve_weakref')}
                    fluid
                  />
                </Stack.Item>
                <Stack.Item>
                  <NoticeBox info width="100%">
                    This determines whether we automatically resolve any
                    weakrefs in lists.
                  </NoticeBox>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section fill title="Arguments">
              <Stack vertical>
                {input_ports.map((val, index) => (
                  <PortEntry
                    key={index}
                    name={val.name}
                    color={val.color}
                    datatype={val.datatype}
                    datatypeOptions={possible_types}
                    onRemove={() =>
                      act('remove_argument', {
                        index: index + 1,
                      })
                    }
                    onSetType={(type) =>
                      act('set_argument_datatype', {
                        index: index + 1,
                        datatype: type,
                      })
                    }
                    onEnter={(e, value) =>
                      act('rename_argument', {
                        index: index + 1,
                        name: value,
                      })
                    }
                  />
                ))}
                <Stack.Item>
                  <Button
                    fluid
                    content="Add Argument"
                    color="good"
                    icon="plus"
                    onClick={() => act('add_argument')}
                  />
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const PortEntry = (props) => {
  const {
    onRemove,
    onEnter,
    onSetType,
    name,
    datatype,
    datatypeOptions = [],
    color,
    ...rest
  } = props;

  return (
    <Stack.Item {...rest}>
      <Stack>
        <Stack.Item grow>
          <Input placeholder="Name" value={name} onChange={onEnter} fluid />
        </Stack.Item>
        <Stack.Item>
          <Dropdown
            selected={datatype}
            options={datatypeOptions}
            onSelected={onSetType}
            color={color}
          />
        </Stack.Item>
        <Stack.Item>
          <Button icon="times" color="red" onClick={onRemove} />
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};
