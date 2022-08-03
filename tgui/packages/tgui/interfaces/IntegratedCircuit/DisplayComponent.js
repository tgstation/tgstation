import { Button, Stack, Box } from '../../components';
import { Component, createRef } from 'inferno';
import { Port } from './Port';
import { noop } from './constants';

export class DisplayComponent extends Component {
  constructor() {
    super();
    this.ref = createRef();
  }

  componentDidUpdate() {
    const { onDisplayUpdated } = this.props;
    if (onDisplayUpdated) {
      onDisplayUpdated(this.ref.current);
    }
  }

  componentDidMount() {
    const { onDisplayLoaded } = this.props;
    if (onDisplayLoaded) {
      onDisplayLoaded(this.ref.current);
    }
  }

  shouldComponentUpdate(nextProps, nextState) {
    if (nextProps.component !== this.props.component) {
      return true;
    }
    if (nextProps.top !== this.props.top) {
      return true;
    }
    if (nextProps.left !== this.props.left) {
      return true;
    }
    return false;
  }

  render(props, context) {
    const { component, fixedSize, ...rest } = props;
    return (
      <Box {...rest}>
        <div ref={this.ref}>
          <Box
            backgroundColor={component.color || 'blue'}
            py={1}
            px={1}
            className="ObjectComponent__Titlebar">
            <Stack>
              <Stack.Item grow={1} unselectable="on">
                {component.name}
              </Stack.Item>
              <Stack.Item>
                <Button
                  color="transparent"
                  icon="info"
                  compact
                  tooltip={component.description}
                  tooltipPosition="top"
                />
              </Stack.Item>
            </Stack>
          </Box>
          <Box
            className="ObjectComponent__Content"
            unselectable="on"
            py={1}
            px={1}>
            <Stack>
              <Stack.Item grow={fixedSize}>
                <Stack vertical fill>
                  {component.input_ports.map((port, portIndex) => (
                    <Stack.Item key={portIndex}>
                      <Port port={port} act={noop} />
                    </Stack.Item>
                  ))}
                </Stack>
              </Stack.Item>
              <Stack.Item>
                <Stack vertical>
                  {component.output_ports.map((port, portIndex) => (
                    <Stack.Item key={portIndex}>
                      <Port port={port} act={noop} isOutput />
                    </Stack.Item>
                  ))}
                </Stack>
              </Stack.Item>
            </Stack>
          </Box>
        </div>
      </Box>
    );
  }
}
