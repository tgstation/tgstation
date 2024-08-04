import { Component } from 'react';

import { Box, Stack } from '../../components';

type PinProps = {
  onMouseDownPin: Function;
  onMouseUpPin: Function;
};

export class Pin extends Component<PinProps, {}> {
  constructor(props) {
    super(props);

    this.handleMouseDown = this.handleMouseDown.bind(this);
    this.handleMouseUp = this.handleMouseUp.bind(this);
  }

  handleMouseDown(args) {
    this.props.onMouseDownPin(args);
  }

  handleMouseUp(args) {
    this.props.onMouseUpPin(args);
  }

  render() {
    return (
      <Stack>
        <Stack.Item>
          <Box
            className="Evidence__Pin"
            onMouseDown={this.handleMouseDown}
            onMouseUp={this.handleMouseUp}
            textAlign="center"
          />
        </Stack.Item>
      </Stack>
    );
  }
}
