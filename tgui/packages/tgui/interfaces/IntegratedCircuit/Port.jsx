import { Component, createRef } from 'react';
import { Box, Stack } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { noop } from './constants';
import { DisplayName } from './DisplayName';

export class Port extends Component {
  constructor(props) {
    super(props);
    this.iconRef = createRef();
    this.componentDidUpdate = this.componentDidUpdate.bind(this);
    this.componentDidMount = this.componentDidMount.bind(this);
    this.handlePortMouseDown = this.handlePortMouseDown.bind(this);
    this.handlePortRightClick = this.handlePortRightClick.bind(this);
    this.handlePortMouseUp = this.handlePortMouseUp.bind(this);
  }

  handlePortMouseDown(e) {
    const {
      port,
      portIndex,
      componentId,
      isOutput,
      onPortMouseDown = noop,
    } = this.props;
    onPortMouseDown(portIndex, componentId, port, isOutput, e);
  }

  handlePortMouseUp(e) {
    const {
      port,
      portIndex,
      componentId,
      isOutput,
      onPortMouseUp = noop,
    } = this.props;
    onPortMouseUp(portIndex, componentId, port, isOutput, e);
  }

  handlePortRightClick(e) {
    const {
      port,
      portIndex,
      componentId,
      isOutput,
      onPortRightClick = noop,
    } = this.props;
    onPortRightClick(portIndex, componentId, port, isOutput, e);
  }

  componentDidUpdate() {
    const { port, onPortUpdated } = this.props;
    if (onPortUpdated) {
      onPortUpdated(port, this.iconRef.current);
    }
  }

  componentDidMount() {
    const { port, onPortLoaded } = this.props;
    if (onPortLoaded) {
      onPortLoaded(port, this.iconRef.current);
    }
  }

  renderDisplayName() {
    const { port, portIndex, componentId, isOutput, act } = this.props;

    return (
      <Stack.Item>
        <DisplayName
          act={act}
          port={port}
          isOutput={isOutput}
          componentId={componentId}
          portIndex={portIndex}
        />
      </Stack.Item>
    );
  }

  render() {
    const { port, isOutput, ...rest } = this.props;

    let composite_types = [];
    if (port.datatype_data?.composite_types) {
      composite_types = port.datatype_data.composite_types;
    }

    return (
      <Stack {...rest} justify={isOutput ? 'flex-end' : 'flex-start'}>
        {!!isOutput && this.renderDisplayName()}
        <Stack.Item>
          <Box
            className={classes(['ObjectComponent__Port'])}
            onMouseDown={this.handlePortMouseDown}
            onContextMenu={this.handlePortRightClick}
            onMouseUp={this.handlePortMouseUp}
            textAlign="center"
          >
            <svg
              style={{
                width: '100%',
                height: '100%',
                position: 'absolute',
              }}
              viewBox="0, 0, 100, 100"
            >
              {composite_types.map((compositeColor, index) => {
                const radians = (2 * Math.PI) / composite_types.length;
                const arcLength = radians * 50;
                return (
                  <circle
                    key={index}
                    stroke={compositeColor}
                    strokeDasharray={`${arcLength}, ${100 * Math.PI}`}
                    strokeDashoffset={
                      -index * (100 * (Math.PI / composite_types.length))
                    }
                    className={`color-stroke-${compositeColor}`}
                    strokeWidth="50px"
                    cx="50"
                    cy="50"
                    r="50"
                    fillOpacity="0"
                    transform="rotate(90, 50, 50)"
                  />
                );
              })}
              <circle
                ref={this.iconRef}
                cx="50"
                cy="50"
                r="50"
                className={`color-fill-${port.color}`}
              />
            </svg>
            <span ref={this.iconRef} className="ObjectComponent__PortPos" />
          </Box>
        </Stack.Item>
        {!isOutput && this.renderDisplayName()}
      </Stack>
    );
  }
}
