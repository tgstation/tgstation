import { computeBoxProps } from "./Box";
import { Stack } from "./Stack";
import { ProgressBar } from "./ProgressBar";
import { Button } from "./Button";
import { Component } from 'inferno';

const ZOOM_MIN_VAL = 0.5;
const ZOOM_MAX_VAL = 1.5;

const ZOOM_INCREMENT = 0.1;

export class InfinitePlane extends Component {
  constructor() {
    super();

    this.state = {
      mouseDown: false,

      left: 0,
      top: 0,

      lastLeft: 0,
      lastTop: 0,

      zoom: 1,
    };

    this.handleMouseDown = this.handleMouseDown.bind(this);
    this.handleMouseMove = this.handleMouseMove.bind(this);
    this.onMouseUp = this.onMouseUp.bind(this);

    this.doOffsetMouse = this.doOffsetMouse.bind(this);
  }

  componentDidMount() {
    window.addEventListener("mouseup", this.onMouseUp);

    window.addEventListener("mousedown", this.doOffsetMouse);
    window.addEventListener("mousemove", this.doOffsetMouse);
    window.addEventListener("mouseup", this.doOffsetMouse);
  }

  componentWillUnmount() {
    window.removeEventListener("mouseup", this.onMouseUp);

    window.removeEventListener("mousedown", this.doOffsetMouse);
    window.removeEventListener("mousemove", this.doOffsetMouse);
    window.removeEventListener("mouseup", this.doOffsetMouse);
  }

  doOffsetMouse(event) {
    const { zoom } = this.state;
    event.screenZoomX = event.screenX * Math.pow(zoom, -1);
    event.screenZoomY = event.screenY * Math.pow(zoom, -1);
  }

  handleMouseDown(event) {
    this.setState((state) => {
      return {
        mouseDown: true,
        lastLeft: event.clientX - state.left,
        lastTop: event.clientY - state.top,
      };
    });
  }

  onMouseUp() {
    this.setState({
      mouseDown: false,
    });
  }

  handleMouseMove(event) {
    if (this.state.mouseDown) {
      this.setState((state) => {
        return {
          left: event.clientX - state.lastLeft,
          top: event.clientY - state.lastTop,
        };
      });
    }
  }

  render() {
    const {
      children,
      backgroundImage,
      imageWidth,
      ...rest
    } = this.props;
    const {
      left,
      top,
      zoom,
    } = this.state;

    return (
      <div
        ref={this.ref}
        {...computeBoxProps({
          ...rest,
          style: {
            ...rest.style,
            overflow: "hidden",
            position: "relative",
          },
        })}
      >
        <div
          onMouseDown={this.handleMouseDown}
          onMouseMove={this.handleMouseMove}
          style={{
            "position": "fixed",
            "height": "100%",
            "width": "100%",
            "background-image": `url("${backgroundImage}")`,
            "background-position": `${left}px ${top}px`,
            "background-repeat": "repeat",
            "background-size": `${zoom*imageWidth}px`,
          }}
        />
        <div
          onMouseDown={this.handleMouseDown}
          onMouseMove={this.handleMouseMove}
          style={{
            "position": "fixed",
            "transform": `translate(${left}px, ${top}px) scale(${zoom})`,
            "transform-origin": "top left",
            "height": "100%",
            "width": "100%",
          }}
        >
          {children}
        </div>

        <Stack
          position="absolute"
          width="100%"
        >
          <Stack.Item>
            <Button
              icon="minus"
              onClick={() => this.setState({
                zoom: Math.max(zoom-ZOOM_INCREMENT, ZOOM_MIN_VAL),
              })}
            />
          </Stack.Item>
          <Stack.Item grow={1}>
            <ProgressBar
              minValue={ZOOM_MIN_VAL}
              value={zoom}
              maxValue={ZOOM_MAX_VAL}
            >
              {zoom}x
            </ProgressBar>
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="plus"
              onClick={() => this.setState({
                zoom: Math.min(zoom+ZOOM_INCREMENT, ZOOM_MAX_VAL),
              })}
            />
          </Stack.Item>
        </Stack>
      </div>
    );
  }
}
