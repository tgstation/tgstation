import { Component, createRef } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button } from '../components';
import { Window } from '../layouts';

const PX_PER_UNIT = 24;

class PaintCanvas extends Component {
  constructor(props) {
    super(props);
    this.canvasRef = createRef();
    this.onCVClick = props.onCanvasClick;
  }

  componentDidMount() {
    this.drawCanvas(this.props);
  }

  componentDidUpdate() {
    this.drawCanvas(this.props);
  }

  drawCanvas(propSource) {
    const ctx = this.canvasRef.current.getContext("2d");
    const grid = propSource.value;
    const x_size = grid.length;
    if (!x_size) {
      return;
    }
    const y_size = grid[0].length;
    const x_scale = Math.round(this.canvasRef.current.width / x_size);
    const y_scale = Math.round(this.canvasRef.current.height / y_size);
    ctx.save();
    ctx.scale(x_scale, y_scale);
    for (let x = 0; x < grid.length; x++) {
      const element = grid[x];
      for (let y = 0; y < element.length; y++) {
        const color = element[y];
        ctx.fillStyle = color;
        ctx.fillRect(x, y, 1, 1);
      }
    }
    ctx.restore();
  }

  clickwrapper(event) {
    const x_size = this.props.value.length;
    if (!x_size) {
      return;
    }
    const y_size = this.props.value[0].length;
    const x_scale = this.canvasRef.current.width / x_size;
    const y_scale = this.canvasRef.current.height / y_size;
    const x = Math.floor(event.offsetX / x_scale)+1;
    const y = Math.floor(event.offsetY / y_scale)+1;
    this.onCVClick(x, y);
  }

  render() {
    const {
      res = 1,
      value,
      dotsize = PX_PER_UNIT,
      ...rest
    } = this.props;
    const [width, height] = getImageSize(value);
    return (
      <canvas
        ref={this.canvasRef}
        width={(width * dotsize) || 300}
        height={(height * dotsize) || 300}
        {...rest}
        onClick={e => this.clickwrapper(e)}>
        Canvas failed to render.
      </canvas>
    );
  }
}

const getImageSize = value => {
  const width = value.length;
  const height = width !== 0 ? value[0].length : 0;
  return [width, height];
};

export const Canvas = (props, context) => {
  const { act, data } = useBackend(context);
  const dotsize = PX_PER_UNIT;
  const [width, height] = getImageSize(data.grid);
  return (
    <Window
      width={Math.min(700, width * dotsize + 72)}
      height={Math.min(700, height * dotsize + 72)}>
      <Window.Content>
        <Box textAlign="center">
          <PaintCanvas
            value={data.grid}
            dotsize={dotsize}
            onCanvasClick={(x, y) => act("paint", { x, y })} />
          <Box>
            {!data.finalized && (
              <Button.Confirm
                onClick={() => act("finalize")}
                content="Finalize" />
            )}
            {data.name}
          </Box>
        </Box>
      </Window.Content>
    </Window>
  );
};
