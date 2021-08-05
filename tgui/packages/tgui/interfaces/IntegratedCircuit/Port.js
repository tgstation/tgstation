import {
  Stack,
  Icon,
} from '../../components';
import { Component, createRef } from 'inferno';
import { DisplayName } from "./DisplayName";


export class Port extends Component {
  constructor() {
    super();
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
      onPortMouseDown,
    } = this.props;
    onPortMouseDown(portIndex, componentId, port, isOutput, e);
  }

  handlePortMouseUp(e) {
    const {
      port,
      portIndex,
      componentId,
      isOutput,
      onPortMouseUp,
    } = this.props;
    onPortMouseUp(portIndex, componentId, port, isOutput, e);
  }

  handlePortRightClick(e) {
    const {
      port,
      portIndex,
      componentId,
      isOutput,
      onPortRightClick,
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

  render() {
    const {
      port,
      portIndex,
      componentId,
      isOutput,
      ...rest
    } = this.props;

    return (
      <Stack {...rest} justify={isOutput ? 'flex-end' : 'flex-start'}>
        {!!isOutput && (
          <Stack.Item>
            <DisplayName
              port={port}
              isOutput={isOutput}
              componentId={componentId}
              portIndex={portIndex} />
          </Stack.Item>
        )}
        <Stack.Item>
          <Icon
            color={port.color || 'blue'}
            name={'circle'}
            position="relative"
            onMouseDown={this.handlePortMouseDown}
            onContextMenu={this.handlePortRightClick}
            onMouseUp={this.handlePortMouseUp}
          >
            <span ref={this.iconRef} className="ObjectComponent__PortPos" />
          </Icon>
        </Stack.Item>
        {!isOutput && (
          <Stack.Item>
            <DisplayName
              port={port}
              isOutput={isOutput}
              componentId={componentId}
              portIndex={portIndex} />
          </Stack.Item>
        )}
      </Stack>
    );
  }
}
