import { useBackend } from '../../backend';
import {
  Input,
  InfinitePlane,
  Stack,
  Box,
  Button,
} from '../../components';
import { Component } from 'inferno';
import { Window } from '../../layouts';
import { resolveAsset } from '../../assets';
import { CircuitInfo } from './CircuitInfo';
import { NULL_REF, ABSOLUTE_Y_OFFSET, MOUSE_BUTTON_LEFT } from './constants';
import { Connections } from './Connections';
import { ObjectComponent } from './ObjectComponent';

export class IntegratedCircuit extends Component {
  constructor() {
    super();
    this.state = {
      locations: {},
      selectedPort: null,
      mouseX: null,
      mouseY: null,
      zoom: 1,
      backgroundX: 0,
      backgroundY: 0,
    };
    this.handlePortLocation = this.handlePortLocation.bind(this);
    this.handleMouseDown = this.handleMouseDown.bind(this);
    this.handlePortClick = this.handlePortClick.bind(this);
    this.handlePortRightClick = this.handlePortRightClick.bind(this);
    this.handlePortUp = this.handlePortUp.bind(this);

    this.handlePortDrag = this.handlePortDrag.bind(this);
    this.handlePortRelease = this.handlePortRelease.bind(this);
    this.handleZoomChange = this.handleZoomChange.bind(this);
    this.handleBackgroundMoved = this.handleBackgroundMoved.bind(this);
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

  handlePortLocation(port, dom) {
    const { locations } = this.state;

    if (!dom) {
      return;
    }

    const lastPosition = locations[port.ref];
    const position = this.getPosition(dom);
    position.color = port.color;

    if (
      isNaN(position.x)
      || isNaN(position.y)
      || (lastPosition
        && lastPosition.x === position.x
        && lastPosition.y === position.y)
    ) {
      return;
    }
    locations[port.ref] = position;
    this.setState({ locations: locations });
  }

  handlePortClick(portIndex, componentId, port, isOutput, event) {
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

    this.handlePortDrag(event);

    window.addEventListener('mousemove', this.handlePortDrag);
    window.addEventListener('mouseup', this.handlePortRelease);
  }

  // mouse up called whilst over a port. This means we can check if selectedPort
  // exists and do perform some actions if it does.
  handlePortUp(portIndex, componentId, port, isOutput, event) {
    const { act } = useBackend(this.context);
    const {
      selectedPort,
    } = this.state;
    if (!selectedPort) {
      return;
    }
    if (selectedPort.is_output === isOutput) {
      return;
    }
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
    act("add_connection", data);
  }

  handlePortDrag(event) {
    this.setState((state) => ({
      mouseX: event.clientX - state.backgroundX,
      mouseY: event.clientY - state.backgroundY,
    }));
  }

  handlePortRelease(event) {
    this.setState({
      selectedPort: null,
    });

    window.removeEventListener('mousemove', this.handlePortDrag);
    window.removeEventListener('mouseup', this.handlePortRelease);
  }

  handlePortRightClick(portIndex, componentId, port, isOutput, event) {
    const { act } = useBackend(this.context);

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
  }

  componentWillUnmount() {
    window.removeEventListener('mousedown', this.handleMouseDown);
  }

  handleMouseDown(event) {
    const { act, data } = useBackend(this.context);
    const { examined_name } = data;
    if (examined_name) {
      act('remove_examined_component');
    }
  }

  render() {
    const { act, data } = useBackend(this.context);
    const {
      components,
      display_name,
      examined_name,
      examined_desc,
      examined_notices,
      examined_rel_x,
      examined_rel_y,
      is_admin,
    } = data;
    const { locations, selectedPort } = this.state;
    const connections = [];

    for (const comp of components) {
      if (comp === null) {
        continue;
      }

      for (const port of comp.input_ports) {
        if (port.connected_to === NULL_REF
          || selectedPort?.ref === port.ref) continue;
        const output_port = locations[port.connected_to];
        connections.push({
          color: (output_port && output_port.color) || 'blue',
          from: output_port,
          to: locations[port.ref],
        });
      }
    }

    if (selectedPort) {
      const { mouseX, mouseY, zoom } = this.state;
      const isOutput = selectedPort.is_output;
      const portLocation = locations[selectedPort.ref];
      const mouseCoords = {
        x: (mouseX)*Math.pow(zoom, -1),
        y: (mouseY + ABSOLUTE_Y_OFFSET)*Math.pow(zoom, -1),
      };
      connections.push({
        color: (portLocation && portLocation.color) || 'blue',
        from: isOutput? portLocation : mouseCoords,
        to: isOutput? mouseCoords : portLocation,
      });
    }

    return (
      <Window
        width={600}
        height={600}
        buttons={(
          <Box
            width="160px"
            position="absolute"
            top="5px"
            height="22px"
          >
            <Stack>
              <Stack.Item grow>
                <Input
                  fluid
                  placeholder="Circuit Name"
                  value={display_name}
                  onChange={(e, value) => act("set_display_name", { display_name: value })}
                />
              </Stack.Item>
              {!!is_admin && (
                <Stack.Item>
                  <Button
                    position="absolute"
                    top={0}
                    color="transparent"
                    onClick={() => act("save_circuit")}
                    icon="save"
                  />
                </Stack.Item>
              )}
            </Stack>
          </Box>
        )}
      >
        <Window.Content
          style={{
            'background-image': 'none',
          }}>
          <InfinitePlane
            width="100%"
            height="100%"
            backgroundImage={resolveAsset('grid_background.png')}
            imageWidth={900}
            onZoomChange={this.handleZoomChange}
            onBackgroundMoved={this.handleBackgroundMoved}
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
                  />
                )
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
        </Window.Content>
      </Window>
    );
  }
}

