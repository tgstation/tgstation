import { Component } from 'react';

import { resolveAsset } from '../../assets';
import { useBackend } from '../../backend';
import { Box, Button, InfinitePlane, Input, Stack } from '../../components';
import { Window } from '../../layouts';
import { Connections } from '../common/Connections';
import { CircuitInfo } from './CircuitInfo';
import { ComponentMenu } from './ComponentMenu';
import {
  ABSOLUTE_Y_OFFSET,
  MOUSE_BUTTON_LEFT,
  TIME_UNTIL_PORT_RELEASE_WORKS,
  VARIABLE_ASSOC_LIST,
  VARIABLE_LIST,
} from './constants';
import { DisplayComponent } from './DisplayComponent';
import { ObjectComponent } from './ObjectComponent';
import { VariableMenu } from './VariableMenu';

export class IntegratedCircuit extends Component {
  constructor(props) {
    super(props);
    this.state = {
      locations: {},
      selectedPort: null,
      mouseX: null,
      mouseY: null,
      zoom: 1,
      backgroundX: 0,
      backgroundY: 0,
      variableMenuOpen: false,
      componentMenuOpen: false,
    };
    this.handlePortLocation = this.handlePortLocation.bind(this);
    this.handleMouseDown = this.handleMouseDown.bind(this);
    this.handleMouseUp = this.handleMouseUp.bind(this);
    this.handlePortClick = this.handlePortClick.bind(this);
    this.handlePortRightClick = this.handlePortRightClick.bind(this);
    this.handlePortUp = this.handlePortUp.bind(this);

    this.handleDragging = this.handleDragging.bind(this);
    this.handlePortRelease = this.handlePortRelease.bind(this);
    this.handleZoomChange = this.handleZoomChange.bind(this);
    this.handleBackgroundMoved = this.handleBackgroundMoved.bind(this);

    this.onVarClickedSetter = this.onVarClickedSetter.bind(this);
    this.onVarClickedGetter = this.onVarClickedGetter.bind(this);
    this.handleVarDropped = this.handleVarDropped.bind(this);

    this.handleMouseDownComponent = this.handleMouseDownComponent.bind(this);
    this.handleComponentDropped = this.handleComponentDropped.bind(this);
    this.handleDisplayLocation = this.handleDisplayLocation.bind(this);
  }

  // Helper function to get an element's exact position
  getPosition(el) {
    let xPos = 0;
    let yPos = 0;

    while (el) {
      xPos += el.offsetLeft;
      yPos += el.offsetTop;
      el = el.offsetParent;
    }
    return {
      x: xPos,
      y: yPos + ABSOLUTE_Y_OFFSET,
    };
  }

  handleDisplayLocation(dom) {
    if (!dom) {
      return;
    }

    const position = this.getPosition(dom);
    this.setState({
      draggingComponentPos: position,
      draggingOffsetX: dom.offsetWidth / 2,
      draggingOffsetY: dom.offsetHeight / 2,
    });
  }

  handlePortLocation(port, dom) {
    const { locations } = this.state;

    if (!dom) {
      return;
    }

    const lastPosition = locations[port.ref];
    const position = this.getPosition(dom);
    position.color = port.color;

    if (
      isNaN(position.x) ||
      isNaN(position.y) ||
      (lastPosition &&
        lastPosition.x === position.x &&
        lastPosition.y === position.y)
    ) {
      return;
    }
    locations[port.ref] = position;
    this.setState({ locations: locations });
  }

  handlePortClick(portIndex, componentId, port, isOutput, event) {
    if (this.state.selectedPort) {
      this.handlePortUp(portIndex, componentId, port, isOutput, event);
      return;
    }

    if (event.button !== MOUSE_BUTTON_LEFT) {
      return;
    }

    event.stopPropagation();
    this.setState({
      selectedPort: {
        index: portIndex,
        component_id: componentId,
        is_output: isOutput,
        ref: port.ref,
      },
    });

    this.handleDragging(event);

    this.timeUntilPortReleaseTimesOut =
      Date.now() + TIME_UNTIL_PORT_RELEASE_WORKS;

    window.addEventListener('mousemove', this.handleDragging);
    window.addEventListener('mouseup', this.handlePortRelease);
  }

  // mouse up called whilst over a port. This means we can check if selectedPort
  // exists and do perform some actions if it does.
  handlePortUp(portIndex, componentId, port, isOutput, event) {
    const { act, data: uiData } = useBackend();
    const { selectedPort } = this.state;
    if (!selectedPort) {
      return;
    }
    if (selectedPort.is_output === isOutput) {
      return;
    }
    this.setState({
      selectedPort: null,
    });
    let data;
    if (isOutput) {
      data = {
        input_port_id: selectedPort.index,
        output_port_id: portIndex,
        input_component_id: selectedPort.component_id,
        output_component_id: componentId,
      };
    } else {
      data = {
        input_port_id: portIndex,
        output_port_id: selectedPort.index,
        input_component_id: componentId,
        output_component_id: selectedPort.component_id,
      };
    }
    act('add_connection', data);

    const { components } = uiData;
    const {
      input_component_id,
      input_port_id,
      output_component_id,
      output_port_id,
    } = data;

    const input_comp = components[input_component_id - 1];
    const input_port = input_comp.input_ports[input_port_id - 1];
    const output_comp = components[output_component_id - 1];
    const output_port = output_comp.output_ports[output_port_id - 1];
    // Do not predict ports that do not match because there is no guarantee
    // that they will properly match.
    // TODO: Implement proper prediction for this
    if (!input_port || input_port.type !== output_port.type) {
      return;
    }
    input_port.connected_to.push(isOutput ? port.ref : selectedPort.ref);
  }

  handleDragging(event) {
    const { data } = useBackend();
    const { screen_x, screen_y } = data;
    this.setState((state) => ({
      mouseX: event.clientX - (state.backgroundX || screen_x),
      mouseY: event.clientY - (state.backgroundY || screen_y),
    }));
  }

  handlePortRelease(event) {
    window.removeEventListener('mouseup', this.handlePortRelease);

    // This will let players release their mouse when dragging
    // to stop connecting the port, whilst letting players
    // click on the port to click and connect.
    if (this.timeUntilPortReleaseTimesOut > Date.now()) {
      return;
    }

    this.setState({
      selectedPort: null,
    });

    window.removeEventListener('mousemove', this.handleDragging);
  }

  handlePortRightClick(portIndex, componentId, port, isOutput, event) {
    const { act } = useBackend();

    event.preventDefault();
    act('remove_connection', {
      component_id: componentId,
      is_input: !isOutput,
      port_id: portIndex,
    });
  }

  handleZoomChange(newZoom) {
    this.setState({
      zoom: newZoom,
    });
  }

  handleBackgroundMoved(newX, newY) {
    this.setState({
      backgroundX: newX,
      backgroundY: newY,
    });
  }

  componentDidMount() {
    window.addEventListener('mousedown', this.handleMouseDown);
    window.addEventListener('mouseup', this.handleMouseUp);
  }

  componentWillUnmount() {
    window.removeEventListener('mousedown', this.handleMouseDown);
    window.removeEventListener('mouseup', this.handleMouseUp);
  }

  handleMouseDown(event) {
    const { act, data } = useBackend();
    const { examined_name } = data;
    if (examined_name) {
      act('remove_examined_component');
    }

    if (this.state.selectedPort) {
      this.handlePortRelease(event);
    }
  }

  handleMouseUp(event) {
    const { act } = useBackend();
    const { backgroundX, backgroundY } = this.state;
    if (backgroundX && backgroundY) {
      act('move_screen', {
        screen_x: backgroundX,
        screen_y: backgroundY,
      });
    }
  }

  onVarClickedSetter(event, variable) {
    this.handleVarClicked(event, variable, true);
  }

  onVarClickedGetter(event, variable) {
    this.handleVarClicked(event, variable, false);
  }

  handleVarClicked(event, variable, is_setter) {
    const component = {
      name: is_setter ? 'Setter' : 'Getter',
      description: 'This is a component',
      color: 'blue',
      input_ports: [],
      output_ports: [],
    };

    if (is_setter) {
      component.input_ports = [
        {
          name: 'Input',
          type: variable.datatype,
          color: variable.color,
        },
      ];
    } else {
      component.output_ports = [
        {
          name: 'Value',
          type: variable.datatype,
          color: variable.color,
        },
      ];
    }

    this.setState({
      draggingComponent: component,
      draggingVariable: variable.name,
      variableIsSetter: is_setter,
    });

    this.handleDragging(event);

    window.addEventListener('mouseup', this.handleVarDropped);
    window.addEventListener('mousemove', this.handleDragging);
  }

  handleVarDropped(event) {
    const { data, act } = useBackend();
    const {
      draggingVariable,
      variableIsSetter,
      mouseX,
      mouseY,
      zoom,
      draggingComponentPos,
    } = this.state;

    this.setState({
      draggingVariable: null,
      variableIsSetter: null,
      draggingComponent: null,
    });

    window.removeEventListener('mousemove', this.handleDragging);
    window.removeEventListener('mouseup', this.handleVarDropped);

    if (event.defaultPrevented) {
      return;
    }

    const xPos = mouseX - (mouseX - draggingComponentPos.x);
    const yPos = mouseY - (mouseY - draggingComponentPos.y);

    act('add_setter_or_getter', {
      variable: draggingVariable,
      is_setter: variableIsSetter,
      rel_x: xPos * Math.pow(zoom, -1),
      rel_y: (yPos + ABSOLUTE_Y_OFFSET) * Math.pow(zoom, -1),
    });
  }

  handleMouseDownComponent(event, component) {
    this.setState({
      draggingComponent: component,
    });

    this.handleDragging(event);

    window.addEventListener('mousemove', this.handleDragging);
    window.addEventListener('mouseup', this.handleComponentDropped);
  }

  handleComponentDropped(event) {
    const { act } = useBackend();
    const { draggingComponent, zoom, draggingComponentPos, mouseX, mouseY } =
      this.state;

    this.setState({
      draggingComponent: null,
    });

    window.removeEventListener('mouseup', this.handleComponentDropped);
    window.removeEventListener('mousemove', this.handleDragging);

    if (event.defaultPrevented) {
      return;
    }
    const xPos = mouseX - (mouseX - draggingComponentPos.x);
    const yPos = mouseY - (mouseY - draggingComponentPos.y);

    act('print_component', {
      component_to_print: draggingComponent.type,
      rel_x: xPos * Math.pow(zoom, -1),
      rel_y: (yPos + ABSOLUTE_Y_OFFSET) * Math.pow(zoom, -1),
    });
  }

  render() {
    const { act, data } = useBackend();
    const {
      components,
      display_name,
      examined_name,
      examined_desc,
      examined_notices,
      examined_rel_x,
      examined_rel_y,
      screen_x,
      screen_y,
      grid_mode,
      is_admin,
      variables,
      global_basic_types,
      stored_designs,
    } = data;
    const {
      mouseX,
      mouseY,
      locations,
      selectedPort,
      variableMenuOpen,
      componentMenuOpen,
      draggingComponent,
      draggingOffsetX,
      draggingOffsetY,
    } = this.state;
    const connections = [];

    for (const comp of components) {
      if (comp === null) {
        continue;
      }

      for (const input of comp.input_ports) {
        for (const output of input.connected_to) {
          const output_port = locations[output];
          connections.push({
            color: (output_port && output_port.color) || 'blue',
            from: output_port,
            to: locations[input.ref],
          });
        }
      }
    }

    if (selectedPort) {
      const { zoom } = this.state;
      const isOutput = selectedPort.is_output;
      const portLocation = locations[selectedPort.ref];
      const mouseCoords = {
        x: mouseX * Math.pow(zoom, -1),
        y: (mouseY + ABSOLUTE_Y_OFFSET) * Math.pow(zoom, -1),
      };
      connections.push({
        color: (portLocation && portLocation.color) || 'blue',
        from: isOutput ? portLocation : mouseCoords,
        to: isOutput ? mouseCoords : portLocation,
      });
    }

    return (
      <Window
        width={1200}
        height={800}
        buttons={
          <Box width="160px" position="absolute" top="5px" height="22px">
            <Stack>
              <Stack.Item grow>
                <Input
                  fluid
                  placeholder="Name"
                  value={display_name}
                  onChange={(e, value) =>
                    act('set_display_name', { display_name: value })
                  }
                />
              </Stack.Item>
              <Stack.Item basis="24px">
                <Button
                  position="absolute"
                  top={0}
                  color="transparent"
                  tooltip="Show Variables Menu"
                  icon="cog"
                  selected={variableMenuOpen}
                  onClick={() =>
                    this.setState((state) => ({
                      variableMenuOpen: !state.variableMenuOpen,
                    }))
                  }
                />
              </Stack.Item>
              <Stack.Item basis="24px">
                <Button
                  position="absolute"
                  top={0}
                  color="transparent"
                  tooltip="Show Components Menu"
                  icon="plus"
                  selected={componentMenuOpen}
                  onClick={() =>
                    this.setState((state) => ({
                      componentMenuOpen: !state.componentMenuOpen,
                    }))
                  }
                />
              </Stack.Item>
              <Stack.Item basis="24px">
                <Button
                  position="absolute"
                  top={0}
                  color="transparent"
                  tooltip="Enable Grid Aligning"
                  icon="th-large"
                  selected={grid_mode}
                  onClick={() => act('toggle_grid_mode')}
                />
              </Stack.Item>
              {!!is_admin && (
                <Stack.Item>
                  <Button
                    position="absolute"
                    top={0}
                    color="transparent"
                    onClick={() => act('save_circuit')}
                    icon="save"
                  />
                </Stack.Item>
              )}
            </Stack>
          </Box>
        }
      >
        <Window.Content
          style={{
            backgroundImage: 'none',
          }}
        >
          <InfinitePlane
            width="100%"
            height="100%"
            backgroundImage={resolveAsset('grid_background.png')}
            imageWidth={900}
            onZoomChange={this.handleZoomChange}
            onBackgroundMoved={this.handleBackgroundMoved}
            initialLeft={screen_x}
            initialTop={screen_y}
          >
            {components.map(
              (comp, index) =>
                comp && (
                  <ObjectComponent
                    key={index}
                    {...comp}
                    index={index + 1}
                    onPortUpdated={this.handlePortLocation}
                    onPortLoaded={this.handlePortLocation}
                    onPortMouseDown={this.handlePortClick}
                    onPortRightClick={this.handlePortRightClick}
                    onPortMouseUp={this.handlePortUp}
                    act={act}
                    gridMode={grid_mode}
                  />
                ),
            )}
            {!!draggingComponent && (
              <DisplayComponent
                component={draggingComponent}
                position="absolute"
                left={`${mouseX - draggingOffsetX}px`}
                top={`${mouseY - draggingOffsetY}px`}
                onDisplayUpdated={this.handleDisplayLocation}
                onDisplayLoaded={this.handleDisplayLocation}
              />
            )}
            <Connections connections={connections} />
          </InfinitePlane>
          {!!examined_name && (
            <CircuitInfo
              position="absolute"
              className="CircuitInfo__Examined"
              top={`${examined_rel_y}px`}
              left={`${examined_rel_x}px`}
              name={examined_name}
              desc={examined_desc}
              notices={examined_notices}
            />
          )}
          {!!variableMenuOpen && (
            <Box
              position="absolute"
              left={0}
              bottom={0}
              height="20%"
              minHeight="175px"
              minWidth="600px"
              width="50%"
              style={{
                borderRadius: '0px 32px 0px 0px',
                backgroundColor: 'rgba(0, 0, 0, 0.3)',
                '-ms-user-select': 'none',
              }}
              unselectable="on"
            >
              <VariableMenu
                variables={variables}
                types={global_basic_types}
                onClose={(event) => this.setState({ variableMenuOpen: false })}
                onAddVariable={(name, type, listType, event) =>
                  act('add_variable', {
                    variable_name: name,
                    variable_datatype: type,
                    is_list: listType === VARIABLE_LIST,
                    is_assoc_list: listType === VARIABLE_ASSOC_LIST,
                  })
                }
                onRemoveVariable={(name, event) =>
                  act('remove_variable', {
                    variable_name: name,
                  })
                }
                handleMouseDownSetter={this.onVarClickedSetter}
                handleMouseDownGetter={this.onVarClickedGetter}
                style={{
                  borderRadius: '0px 32px 0px 0px',
                }}
              />
            </Box>
          )}
          {!!componentMenuOpen && (
            <Box
              position="absolute"
              right={0}
              top={0}
              height="100%"
              width="300px"
              style={{
                backgroundColor: 'rgba(0, 0, 0, 0.3)',
                '-ms-user-select': 'none',
              }}
              unselectable="on"
            >
              <ComponentMenu
                components={
                  (stored_designs && Object.keys(stored_designs)) || []
                }
                onClose={(event) => this.setState({ componentMenuOpen: false })}
                onMouseDownComponent={this.handleMouseDownComponent}
                showAll={is_admin}
              />
            </Box>
          )}
        </Window.Content>
      </Window>
    );
  }
}
