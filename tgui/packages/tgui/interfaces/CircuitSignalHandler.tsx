import { Component } from 'inferno';
import { useBackend } from '../backend';
import { Box, Stack, Section, Input, Button, Dropdown } from '../components';
import { Window } from '../layouts';

type Response = {
  name: string;
  bitflag: number;
};

type Parameter = {
  name: string;
  datatype: string;
};

type CircuitSignalHandlerState = {
  signal_id: string;
  responseList: Response[];
  parameterList: Parameter[];
  global: Boolean;
};

type CircuitSignalHandlerData = {
  global_port_types: string[];
};

type BitflagToString = {
  [key: number]: string;
};

export class CircuitSignalHandler extends Component<
  {},
  CircuitSignalHandlerState
> {
  bitflags: BitflagToString;

  constructor(props) {
    super(props);
    this.state = {
      signal_id: 'signal_id',
      responseList: [],
      parameterList: [],
      global: false,
    };

    this.bitflags = {};

    for (let i = 0; i < 24; i++) {
      this.bitflags[1 << i] = `Flag ${i + 1}`;
    }
  }

  render() {
    const { act, data } = useBackend<CircuitSignalHandlerData>(this.context);
    const { responseList, parameterList, signal_id, global } = this
      .state as CircuitSignalHandlerState;
    const { global_port_types } = data;
    return (
      <Window width={600} height={300}>
        <Window.Content>
          <Stack vertical fill>
            <Stack.Item>
              <Stack fill>
                <Stack.Item grow>
                  <Input
                    placeholder="Signal ID"
                    value={signal_id}
                    fluid
                    onChange={(e, value) => this.setState({ signal_id: value })}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button.Checkbox
                    checked={global}
                    content="Global"
                    onClick={(e) => this.setState({ global: !global })}
                  />
                </Stack.Item>
              </Stack>
            </Stack.Item>
            <Stack.Item grow>
              <Stack fill>
                <Stack.Item grow={1} basis={0}>
                  <Section title="Responses" fill scrollable>
                    <Stack vertical>
                      {responseList.map((val, index) => (
                        <Entry
                          key={index}
                          name={val.name}
                          current_option={this.bitflags[val.bitflag]}
                          onRemove={() => {
                            responseList.splice(index, 1);
                            this.setState({ parameterList });
                          }}
                          onEnter={(e, value) => {
                            const param = responseList[index];
                            param.name = value;
                            this.setState({ parameterList });
                          }}
                        />
                      ))}
                      <Stack.Item>
                        <Button
                          fluid
                          content="Add Response"
                          color="good"
                          icon="plus"
                          onClick={() => {
                            // Object.keys returns strings here, even though we
                            // have a number->key assoc array here, so we have
                            // to explicitly cast it to a number[] type.
                            const bitflag_keys = Object.keys(
                              this.bitflags
                            ) as unknown as number[];
                            responseList.push({
                              name: 'Response',
                              bitflag: bitflag_keys[responseList.length],
                            });
                            this.setState({ parameterList });
                          }}
                        />
                      </Stack.Item>
                    </Stack>
                  </Section>
                </Stack.Item>
                <Stack.Item grow={1} basis={0}>
                  <Section title="Parameters" fill scrollable>
                    <Stack vertical>
                      {parameterList.map((val, index) => (
                        <Entry
                          key={index}
                          name={val.name}
                          current_option={val.datatype}
                          options={global_port_types}
                          onRemove={() => {
                            parameterList.splice(index, 1);
                            this.setState({ parameterList });
                          }}
                          onSetOption={(type) => {
                            const param = parameterList[index];
                            param.datatype = type;
                            this.setState({ parameterList });
                          }}
                          onEnter={(e, value) => {
                            const param = parameterList[index];
                            param.name = value;
                            this.setState({ parameterList });
                          }}
                        />
                      ))}
                      <Stack.Item>
                        <Button
                          fluid
                          content="Add Parameter"
                          color="good"
                          icon="plus"
                          onClick={() => {
                            parameterList.push({
                              name: 'Parameter',
                              datatype: global_port_types[0],
                            });
                            this.setState({ parameterList });
                          }}
                        />
                      </Stack.Item>
                    </Stack>
                  </Section>
                </Stack.Item>
              </Stack>
            </Stack.Item>
            <Stack.Item>
              <Button
                content="Submit"
                textAlign="center"
                fluid
                onClick={() =>
                  act('add_new_id', {
                    signal_id: signal_id,
                    responses: responseList,
                    parameters: parameterList,
                    global: global,
                  })
                }
              />
            </Stack.Item>
          </Stack>
        </Window.Content>
      </Window>
    );
  }
}

type EntryProps = {
  onRemove: (e: MouseEvent) => any;
  onEnter: (e: MouseEvent, value: string) => any;
  onSetOption?: (type: string) => any;
  name: string;
  current_option: string;
  options?: string[];
};

const Entry = (props: EntryProps, context) => {
  const {
    onRemove,
    onEnter,
    onSetOption,
    name,
    current_option,
    options = [],
    ...rest
  } = props;

  return (
    <Stack.Item {...rest}>
      <Stack>
        <Stack.Item grow>
          <Input placeholder="Name" value={name} onChange={onEnter} fluid />
        </Stack.Item>
        <Stack.Item>
          {(options.length && (
            <Dropdown
              displayText={current_option}
              options={options}
              onSelected={onSetOption}
            />
          )) || (
            <Box textAlign="center" py="2px" px={2}>
              {current_option}
            </Box>
          )}
        </Stack.Item>
        <Stack.Item>
          <Button icon="times" color="red" onClick={onRemove} />
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};
