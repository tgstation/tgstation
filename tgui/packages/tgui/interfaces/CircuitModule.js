import { useBackend } from "../backend";
import { Stack, Section, Input, Button, Dropdown } from "../components";
import { Window } from "../layouts";

export const CircuitModule = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    input_ports,
    output_ports,
    global_port_types,
  } = data;
  return (
    <Window width={600} height={300}>
      <Window.Content scrollable>
        <Stack vertical>
          <Stack.Item>
            <Button
              content="View Internal Circuit"
              textAlign="center"
              fluid
              onClick={() => act("open_internal_circuit")}
            />
          </Stack.Item>
          <Stack.Item>
            <Stack width="100%">
              <Stack.Item basis="50%">
                <Section title="Input Ports">
                  <Stack vertical>
                    {input_ports.map((val, index) => (
                      <PortEntry
                        key={index}
                        name={val.name}
                        datatype={val.type}
                        datatypeOptions={global_port_types}
                        onRemove={() => act("remove_input_port", {
                          port_id: index+1,
                        })}
                        onSetType={type => act("set_port_type", {
                          port_id: index+1,
                          is_input: true,
                          port_type: type,
                        })}
                        onEnter={(e, value) => act("set_port_name", {
                          port_id: index+1,
                          is_input: true,
                          port_name: value,
                        })}
                      />
                    ))}
                    <Stack.Item>
                      <Button
                        fluid
                        content="Add Input Port"
                        color="good"
                        icon="plus"
                        onClick={() => act("add_input_port")}
                      />
                    </Stack.Item>
                  </Stack>
                </Section>
              </Stack.Item>
              <Stack.Item basis="50%">
                <Section title="Output Ports">
                  <Stack vertical>
                    {output_ports.map((val, index) => (
                      <PortEntry
                        key={index}
                        name={val.name}
                        datatype={val.type}
                        datatypeOptions={global_port_types}
                        onRemove={() => act("remove_output_port", {
                          port_id: index+1,
                        })}
                        onSetType={type => act("set_port_type", {
                          port_id: index+1,
                          is_input: false,
                          port_type: type,
                        })}
                        onEnter={(e, value) => act("set_port_name", {
                          port_id: index+1,
                          is_input: false,
                          port_name: value,
                        })}
                      />
                    ))}
                    <Stack.Item>
                      <Button
                        fluid
                        content="Add Output Port"
                        color="good"
                        icon="plus"
                        onClick={() => act("add_output_port")}
                      />
                    </Stack.Item>
                  </Stack>
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const PortEntry = (props, context) => {
  const {
    onRemove,
    onEnter,
    onSetType,
    name,
    datatype,
    datatypeOptions = [],
    ...rest
  } = props;

  return (
    <Stack.Item {...rest}>
      <Stack>
        <Stack.Item grow>
          <Input
            placeholder="Name"
            value={name}
            onChange={onEnter}
            fluid
          />
        </Stack.Item>
        <Stack.Item>
          <Dropdown
            displayText={datatype}
            options={datatypeOptions}
            onSelected={onSetType}
          />
        </Stack.Item>
        <Stack.Item>
          <Button
            icon="times"
            color="red"
            onClick={onRemove}
          />
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};
