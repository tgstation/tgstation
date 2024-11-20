import '../styles/interfaces/NanoMap.scss';

import { Component } from 'react';
import {
  LabeledList,
  Slider,
  Stack,
  Section,
  Button,
  Icon,
  Tooltip,
} from 'tgui-core/components';

import { resolveAsset } from '../assets';
import { useBackend } from '../backend';

const pauseEvent = (e) => {
  if (e.stopPropagation) {
    e.stopPropagation();
  }
  if (e.preventDefault) {
    e.preventDefault();
  }
  e.cancelBubble = true;
  e.returnValue = false;
  return false;
};

export class NanoMap extends Component {
  constructor(props) {
    super(props);

    this.state = {
      offsetX: -32,
      offsetY: 64,
      transform: 'none',
      dragging: false,
      originX: null,
      originY: null,
      zoom: 1,
    };

    // Dragging
    this.handleDragStart = (e) => {
      this.ref = e.target;
      this.setState({
        dragging: false,
        originX: e.screenX,
        originY: e.screenY,
      });
      document.addEventListener('mousemove', this.handleDragMove);
      document.addEventListener('mouseup', this.handleDragEnd);
      pauseEvent(e);
    };

    this.handleDragMove = (e) => {
      this.setState((prevState) => {
        const state = { ...prevState };
        const newOffsetX = e.screenX - state.originX;
        const newOffsetY = e.screenY - state.originY;
        if (prevState.dragging) {
          state.offsetX += newOffsetX;
          state.offsetY += newOffsetY;
          state.originX = e.screenX;
          state.originY = e.screenY;
        } else {
          state.dragging = true;
        }
        return state;
      });
      pauseEvent(e);
    };

    this.handleDragEnd = (e) => {
      this.setState({
        dragging: false,
        originX: null,
        originY: null,
      });
      document.removeEventListener('mousemove', this.handleDragMove);
      document.removeEventListener('mouseup', this.handleDragEnd);
      pauseEvent(e);
    };

    this.handleZoom = (_e, value) => {
      this.setState((state) => {
        const newZoom = Math.min(Math.max(value, 1), 8);
        let zoomDiff = (newZoom - state.zoom) * 1.5;
        state.zoom = newZoom;
        state.offsetX = state.offsetX - 256 * zoomDiff;
        state.offsetY = state.offsetY - 256 * zoomDiff;
        if (props.onZoom) {
          props.onZoom(state.zoom);
        }
        return state;
      });
    };
  }

  render() {
    const { config } = useBackend(this.context);
    const { dragging, offsetX, offsetY, zoom = 1 } = this.state;
    const { children } = this.props;

    const mapUrl = this.props.mapUrl || null;
    const mapSize = 510 * zoom + 'px';
    const newStyle = {
      width: mapSize,
      height: mapSize,
      'margin-top': offsetY + 'px',
      'margin-left': offsetX + 'px',
      overflow: 'hidden',
      position: 'absolute',
      'background-size': 'cover',
      'background-repeat': 'no-repeat',
      'text-align': 'center',
      cursor: dragging ? 'move' : 'auto',
    };
    const mapStyle = {
      width: '100%',
      height: '100%',
      position: 'absolute',
      top: '50%',
      left: '50%',
      transform: 'translate(-50%, -50%)',
      '-ms-interpolation-mode': 'nearest-neighbor', // TODO: Remove with 516
      'image-rendering': 'pixelated',
    };

    return (
      <Stack fill vertical className="NanoMap__container">
        <Stack.Item className="NanoMap__toolbar">
          <Section>
            <Stack>
              <Stack.Item>
                <NanoMapZoomer zoom={zoom} onZoom={this.handleZoom} />
              </Stack.Item>
              <Stack.Item>
                <NanoMapZSelector />
              </Stack.Item>
            </Stack>
          </Section>
        </Stack.Item>
        <Stack.Item style={newStyle} onMouseDown={this.handleDragStart}>
          <img src={resolveAsset(mapUrl)} style={mapStyle} />
          <div>{children}</div>
        </Stack.Item>
      </Stack>
    );
  }
}

const NanoMapMarker = (props, context) => {
  const { x, y, zoom = 1, icon, tooltip, color } = props;
  const rx = x * 2 * zoom - zoom - 3;
  const ry = y * 2 * zoom - zoom - 3;
  return (
    <div>
      <Tooltip content={tooltip}>
        <div
          position="absolute"
          className="NanoMap__marker"
          lineHeight="0"
          bottom={ry + 'px'}
          left={rx + 'px'}
        >
          <Icon name={icon} color={color} fontSize="6px" />
        </div>
      </Tooltip>
    </div>
  );
};

NanoMap.Marker = NanoMapMarker;

const NanoMapZoomer = (props, context) => {
  return (
    <LabeledList>
      <LabeledList.Item label="Zoom">
        <Slider
          width="100%"
          minValue={1}
          maxValue={8}
          step={1}
          stepPixelSize={12.5}
          format={(v) => v + 'x'}
          value={props.zoom}
          onDrag={(e, v) => props.onZoom(e, v)}
        />
      </LabeledList.Item>
    </LabeledList>
  );
};

NanoMap.Zoomer = NanoMapZoomer;

let ActiveButton;
class NanoButton extends Component {
  constructor(props) {
    super(props);
    const { act } = useBackend(this.props.context);
    this.state = {
      color: this.props.color,
    };
    this.handleClick = (e) => {
      if (ActiveButton !== undefined) {
        ActiveButton.setState({
          color: 'blue',
        });
      }
      act('switch_camera', {
        camera: this.props.cam_ref,
      });
      ActiveButton = this;
      this.setState({
        color: 'green',
      });
    };
  }
  render() {
    let rx = this.props.x * 2 * this.props.zoom - this.props.zoom - 3;
    let ry = this.props.y * 2 * this.props.zoom - this.props.zoom - 3;
    return (
      <Button
        key={this.props.key}
        icon={this.props.icon}
        onClick={this.handleClick}
        position="absolute"
        className="NanoMap__button"
        lineHeight="0"
        color={this.props.status ? this.state.color : 'red'}
        bottom={ry + 'px'}
        left={rx + 'px'}
        tooltip={this.props.tooltip}
      />
    );
  }
}
NanoMap.NanoButton = NanoButton;

const NanoMapZSelector = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Stack>
      <Stack.Item>
        <Button
          pr={0.5}
          icon={'chevron-down'}
          tooltip={'Уровнем ниже'}
          tooltipPosition={'bottom-end'}
          onClick={() => act('switch_z_level', { z_dir: -1 })}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          pr={0.5}
          icon={'chevron-up'}
          tooltip={'Уровнем выше'}
          tooltipPosition={'bottom-end'}
          onClick={() => act('switch_z_level', { z_dir: 1 })}
        />
      </Stack.Item>
    </Stack>
  );
};
