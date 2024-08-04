import { Component } from 'react';

import { BooleanLike } from '../../../common/react';
import { Box, Button, Flex, Stack } from '../../components';
import { DataEvidence } from './DataTypes';
import { Pin } from './Pin';

type EvidenceProps = {
  evidence: DataEvidence;
  case_ref: string;
  act: Function;
};

type EvidenceState = {
  isDragging: BooleanLike;
  dragPos: Position | null;
  startPos: Position | null;
  lastMousePos: Position | null;
  isMouseOnPin: BooleanLike;
};

type Position = {
  x: number;
  y: number;
};

export class Evidence extends Component<EvidenceProps, EvidenceState> {
  state: EvidenceState;

  constructor(props) {
    super(props);
    this.state = {
      isDragging: false,
      dragPos: null,
      startPos: null,
      lastMousePos: null,
      isMouseOnPin: false,
    };

    this.handleMouseDown = this.handleMouseDown.bind(this);
    this.handleMouseUp = this.handleMouseUp.bind(this);
    this.handleMouseMove = this.handleMouseMove.bind(this);

    this.handleMouseDownPin = this.handleMouseDownPin.bind(this);
    this.handleMouseUpPin = this.handleMouseUpPin.bind(this);
  }
  handleMouseDown(args) {
    const { evidence } = this.props;
    this.setState({
      lastMousePos: null,
      isDragging: true,
      dragPos: { x: evidence.x, y: evidence.y },
      startPos: { x: evidence.x, y: evidence.y },
    });
    window.addEventListener('mousemove', this.handleMouseMove);
    window.addEventListener('mouseup', this.handleMouseUp);
  }

  handleMouseUp(args) {
    const { dragPos } = this.state;
    const { evidence, case_ref, act = () => {} } = this.props;
    if (dragPos) {
      act('set_evidence_cords', {
        evidence_ref: evidence.ref,
        case_ref: case_ref,
        rel_x: dragPos.x,
        rel_y: dragPos.y,
      });
    }

    window.removeEventListener('mousemove', this.handleMouseMove);
    window.removeEventListener('mouseup', this.handleMouseUp);
    this.setState({
      isDragging: false,
    });
  }

  handleMouseMove(args) {
    const { dragPos, isDragging, lastMousePos, isMouseOnPin } = this.state;
    // const { onMoving } = this.props;
    if (dragPos && isDragging && !isMouseOnPin) {
      args.preventDefault();
      const { screenZoomX, screenZoomY, screenX, screenY } = args;
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

  handleMouseDownPin(args) {
    this.setState({
      isMouseOnPin: true,
    });
  }

  handleMouseUpPin(args) {
    this.setState({
      isMouseOnPin: false,
    });
  }

  render() {
    const { evidence, case_ref, act = () => {}, ...rest } = this.props;
    const { startPos, dragPos } = this.state;
    let [x_pos, y_pos] = [evidence.x, evidence.y];
    if (dragPos && startPos && startPos.x === x_pos && startPos.y === y_pos) {
      x_pos = dragPos.x;
      y_pos = dragPos.y;
    }
    return (
      <Box
        position="absolute"
        left={`${x_pos}px`}
        top={`${y_pos}px`}
        onMouseDown={this.handleMouseDown}
        onMouseUp={this.handleMouseUp}
        // onComponentWillUnmount={this.handleMouseMove}
        {...rest}
      >
        <Stack vertical>
          <Stack.Item>
            <Box className="Evidence__Box">
              <Flex justify="space-between" align="center">
                <Flex.Item align="center">
                  <Box className="Evidence__Box__TextBox title">
                    <b>{evidence.name}</b>
                  </Box>
                </Flex.Item>
                <Flex.Item align="center">
                  <Pin
                    onMouseDownPin={this.handleMouseDownPin}
                    onMouseUpPin={this.handleMouseUpPin}
                  />
                </Flex.Item>
                <Flex.Item align="right">
                  <Button
                    iconColor="red"
                    icon="trash"
                    color="white"
                    onClick={() =>
                      act('remove_evidence', {
                        case_ref: case_ref,
                        evidence_ref: evidence.ref,
                      })
                    }
                  />
                </Flex.Item>
              </Flex>
              <Box
                onClick={() =>
                  act('look_evidence', {
                    case_ref: case_ref,
                    evidence_ref: evidence.ref,
                  })
                }
              >
                {evidence.type === 'photo' ? (
                  <img className="Evidence__Icon" src={evidence.photo_url} />
                ) : (
                  // eslint-disable-next-line react/no-danger
                  <div dangerouslySetInnerHTML={{ __html: evidence.text }} />
                )}
              </Box>

              <Box className="Evidence__Box__TextBox">
                {evidence.description}
              </Box>
            </Box>
          </Stack.Item>
        </Stack>
      </Box>
    );
  }
}
