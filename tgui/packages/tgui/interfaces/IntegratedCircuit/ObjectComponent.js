import { useBackend } from '../../backend';
import {
  Box,
  Stack, Button, Dropdown,
} from '../../components';
import { Component } from 'inferno';
import { shallowDiffers } from '../../../common/react';
import { ABSOLUTE_Y_OFFSET } from './constants';
import { Port } from "./Port";


export class ObjectComponent extends Component {
  constructor() {
    super();
    this.state = {
      isDragging: false,
      dragPos: null,
      startPos: null,
      lastMousePos: null,
    };

    this.handleStartDrag = this.handleStartDrag.bind(this);
    this.handleStopDrag = this.handleStopDrag.bind(this);
    this.handleDrag = this.handleDrag.bind(this);
  }

  handleStartDrag(e) {
    const { x, y } = this.props;
    e.stopPropagation();
    this.setState({
      lastMousePos: null,
      isDragging: true,
      dragPos: { x: x, y: y },
      startPos: { x: x, y: y },
    });
    window.addEventListener('mousemove', this.handleDrag);
    window.addEventListener('mouseup', this.handleStopDrag);
  }

  handleStopDrag(e) {
    const { act } = useBackend(this.context);
    const { dragPos } = this.state;
    const { index } = this.props;
    if (dragPos) {
      act('set_component_coordinates', {
        component_id: index,
        rel_x: dragPos.x,
        rel_y: dragPos.y,
      });
    }

    window.removeEventListener('mousemove', this.handleDrag);
    window.removeEventListener('mouseup', this.handleStopDrag);
    this.setState({ isDragging: false });
  }

  handleDrag(e) {
    const { dragPos, isDragging, lastMousePos } = this.state;
    if (dragPos && isDragging) {
      e.preventDefault();
      const { screenZoomX, screenZoomY, screenX, screenY } = e;
      let xPos = screenZoomX || screenX;
      let yPos = screenZoomY || screenY;
      if (lastMousePos) {
        this.setState({
          dragPos: {
            x: dragPos.x - (lastMousePos.x - xPos),
            y: dragPos.y - (lastMousePos.y - yPos),
          },
        });
      }
      this.setState({
        lastMousePos: { x: xPos, y: yPos },
      });
    }
  }

  shouldComponentUpdate(nextProps, nextState) {
    const { input_ports, output_ports } = this.props;

    return (
      shallowDiffers(this.props, nextProps)
      || shallowDiffers(this.state, nextState)
      || shallowDiffers(input_ports, nextProps.input_ports)
      || shallowDiffers(output_ports, nextProps.output_ports)
    );
  }

  render() {
    const {
      input_ports,
      output_ports,
      name,
      x,
      y,
      index,
      color = 'blue',
      removable,
      locations,
      onPortUpdated,
      onPortLoaded,
      onPortMouseDown,
      onPortRightClick,
      onPortMouseUp,
      ...rest
    } = this.props;
    const { act } = useBackend(this.context);
    const { startPos, dragPos } = this.state;

    let [x_pos, y_pos] = [x, y];
    if (dragPos && startPos && startPos.x === x_pos && startPos.y === y_pos) {
      x_pos = dragPos.x;
      y_pos = dragPos.y;
    }

    // Assigned onto the ports
    const PortOptions = {
      onPortLoaded: onPortLoaded,
      onPortUpdated: onPortUpdated,
      onPortMouseDown: onPortMouseDown,
      onPortRightClick: onPortRightClick,
      onPortMouseUp: onPortMouseUp,
    };

    return (
      <Box
        {...rest}
        position="absolute"
        left={`${x_pos}px`}
        top={`${y_pos}px`}
        onMouseDown={this.handleStartDrag}
        onMouseUp={this.handleStopDrag}
        onComponentWillUnmount={this.handleDrag}>
        <Box
          backgroundColor={color}
          py={1}
          px={1}
          className="ObjectComponent__Titlebar">
          <Stack>
            <Stack.Item grow={1} unselectable="on">
              {name}
            </Stack.Item>
            <Stack.Item>
              <Button
                color="transparent"
                icon="info"
                compact
                onClick={(e) => act('set_examined_component', {
                  component_id: index,
                  x: e.pageX,
                  y: e.pageY + ABSOLUTE_Y_OFFSET,
                })} />
            </Stack.Item>
            {!!removable && (
              <Stack.Item>
                <Button
                  color="transparent"
                  icon="times"
                  compact
                  onClick={() => act('detach_component', { component_id: index })} />
              </Stack.Item>
            )}
          </Stack>
        </Box>
        <Box
          className="ObjectComponent__Content"
          unselectable="on"
          py={1}
          px={1}>
          <Stack>
            <Stack.Item grow={1}>
              <Stack vertical fill>
                {input_ports.map((port, portIndex) => (
                  <Stack.Item key={portIndex}>
                    <Port
                      port={port}
                      portIndex={portIndex + 1}
                      componentId={index}
                      {...PortOptions}
                    />
                  </Stack.Item>
                ))}
              </Stack>
            </Stack.Item>
            <Stack.Item ml={5}>
              <Stack vertical>
                {output_ports.map((port, portIndex) => (
                  <Stack.Item key={portIndex}>
                    <Port
                      port={port}
                      portIndex={portIndex + 1}
                      componentId={index}
                      {...PortOptions}
                      isOutput />
                  </Stack.Item>
                ))}
              </Stack>
            </Stack.Item>
          </Stack>
        </Box>
      </Box>
    );
  }
}
