import { Component } from 'react';
import {
  Box,
  Button,
  Dropdown,
  Icon,
  Input,
  Section,
  Stack,
} from 'tgui-core/components';
import { shallowDiffers } from 'tgui-core/react';

import {
  VARIABLE_ASSOC_LIST,
  VARIABLE_LIST,
  VARIABLE_NOT_A_LIST,
} from './constants';

export class VariableMenu extends Component {
  constructor(props) {
    super(props);
    this.state = {
      variable_name: '',
      variable_type: 'any',
    };
  }

  shouldComponentUpdate(nextProps, nextState) {
    if (shallowDiffers(this.state, nextState)) {
      return true;
    }

    const { variables } = this.props;
    if (variables.length !== nextProps.variables.length) {
      return true;
    }
    for (let i = 0; i < variables.length; i++) {
      if (shallowDiffers(variables[i], nextProps.variables[i])) {
        return true;
      }
    }
    return false;
  }

  render() {
    const {
      variables,
      onAddVariable,
      onRemoveVariable,
      onClose,
      handleMouseDownSetter,
      handleMouseDownGetter,
      types,
      ...rest
    } = this.props;
    const { variable_name, variable_type } = this.state;

    return (
      <Section
        title="Variable Options"
        {...rest}
        fill
        buttons={
          <Button icon="times" color="transparent" mr={2} onClick={onClose} />
        }
        onMouseUp={(event) => {
          event.preventDefault();
        }}
      >
        <Stack height="100%">
          <Stack.Item grow={1} mr={2}>
            <Section fill scrollable>
              <Stack vertical fill>
                {variables.map((val) => (
                  <Stack.Item key={val.name}>
                    <Box
                      backgroundColor="transparent"
                      px="1px"
                      py="1px"
                      height="100%"
                    >
                      <Stack>
                        <Stack.Item basis="50%" grow>
                          <Box width="100%" overflow="hidden">
                            {val.name}
                          </Box>
                        </Stack.Item>
                        <Stack.Item>
                          <Button textAlign="center" fluid color={val.color}>
                            {val.datatype}
                          </Button>
                        </Stack.Item>
                        <Stack.Item>
                          <Button
                            fluid
                            onMouseDown={(e) => handleMouseDownSetter(e, val)}
                            color={val.color}
                            disabled={!!val.is_list}
                            tooltip={`
                            Drag me onto the circuit's grid
                            to make a setter for this variable`}
                            icon="pen"
                          />
                        </Stack.Item>
                        <Stack.Item>
                          <Button
                            fluid
                            tooltip={`
                            Drag me onto the circuit's grid
                            to make a getter for this variable`}
                            color={val.color}
                            onMouseDown={(e) => handleMouseDownGetter(e, val)}
                            icon="book-open"
                          />
                        </Stack.Item>
                        <Stack.Item>
                          <Button
                            icon="times"
                            color="bad"
                            onClick={(e) => onRemoveVariable(val.name, e)}
                          />
                        </Stack.Item>
                      </Stack>
                    </Box>
                  </Stack.Item>
                ))}
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item height="100%" width="25%">
            <Box height="100%">
              <Stack vertical fill>
                <Stack.Item>
                  <Input
                    placeholder="Name"
                    fluid
                    onChange={(e, nameVal) =>
                      this.setState({
                        variable_name: nameVal,
                      })
                    }
                  />
                </Stack.Item>
                <Stack.Item>
                  <Dropdown
                    options={types}
                    selected={variable_type}
                    className="IntegratedCircuit__BlueBorder"
                    color="black"
                    width="100%"
                    over
                    onSelected={(selectedVal) =>
                      this.setState({
                        variable_type: selectedVal,
                      })
                    }
                  />
                </Stack.Item>
                <Stack.Item>
                  <Stack fill>
                    <Stack.Item grow>
                      <Button
                        height="100%"
                        color="green"
                        onClick={(e) =>
                          onAddVariable(
                            variable_name,
                            variable_type,
                            VARIABLE_NOT_A_LIST,
                            e,
                          )
                        }
                        fluid
                      >
                        <IconButton icon="plus" />
                      </Button>
                    </Stack.Item>
                    <Stack.Item grow>
                      <Button
                        height="100%"
                        color="green"
                        onClick={(e) =>
                          onAddVariable(
                            variable_name,
                            variable_type,
                            VARIABLE_LIST,
                            e,
                          )
                        }
                        fluid
                      >
                        <IconButton icon="list-ol" />
                      </Button>
                    </Stack.Item>
                    <Stack.Item grow>
                      <Button
                        height="100%"
                        color="green"
                        onClick={(e) =>
                          onAddVariable(
                            variable_name,
                            variable_type,
                            VARIABLE_ASSOC_LIST,
                            e,
                          )
                        }
                        fluid
                      >
                        <IconButton icon="table-list" />
                      </Button>
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
              </Stack>
            </Box>
          </Stack.Item>
        </Stack>
      </Section>
    );
  }
}

const IconButton = (props) => {
  return (
    <Stack fill align="center">
      <Stack.Item grow basis="content">
        <Icon name={props.icon} size={1} width="100%" m="0em" />
      </Stack.Item>
    </Stack>
  );
};
