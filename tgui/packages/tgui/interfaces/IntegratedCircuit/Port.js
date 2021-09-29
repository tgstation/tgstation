import {
  Stack,
} from '../../components';
import { Component, createRef } from 'inferno';
import { DisplayName } from "./DisplayName";
import { classes } from 'common/react';
import { CSS_COLORS } from '../../constants';

const isColorClass = (str) => {
  return typeof str === "string" && CSS_COLORS.includes(str);
};

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

  renderDisplayName() {
    const {
      port,
      portIndex,
      componentId,
      isOutput,
    } = this.props;

    return (
      <Stack.Item>
        <DisplayName
          port={port}
          isOutput={isOutput}
          componentId={componentId}
          portIndex={portIndex} />
      </Stack.Item>
    );
  }

  render() {
    const {
      port,
      isOutput,
      ...rest
    } = this.props;

    return (
      <Stack
        {...rest}
        justify={isOutput ? 'flex-end' : 'flex-start'}
      >
        {!!isOutput && this.renderDisplayName()}
        <Stack.Item>
          <div
            className={classes([
              "ObjectComponent__Port",
              isColorClass(port.color) && "color-bg-" + port.color,
            ])}
            onMouseDown={this.handlePortMouseDown}
            onContextMenu={this.handlePortRightClick}
            onMouseUp={this.handlePortMouseUp}
          >
            <span ref={this.iconRef} className="ObjectComponent__PortPos" />
          </div>
        </Stack.Item>
        {!isOutput && this.renderDisplayName()}
      </Stack>
    );
  }
}
