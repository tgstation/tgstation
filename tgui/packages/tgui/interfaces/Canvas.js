import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button } from '../components';
import { Component, createRef } from 'inferno';
import { pureComponentHooks } from 'common/react';


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
    if (!x_size)
    {
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
      px_per_unit = 28,
      ...rest
    } = this.props;
    const x_size = value.length * px_per_unit;
    const y_size = x_size !== 0 ? value[0].length * px_per_unit : 0;
    return (
      <canvas
        ref={this.canvasRef}
        width={x_size || 300}
        height={y_size || 300}
        {...rest}
        onClick={e => this.clickwrapper(e)}>
          Canvas failed to render.
      </canvas>
    );
  }
}
export const Canvas = props => {
  const { act, data } = useBackend(props);
  return (
    <Box textAlign="center">
      <PaintCanvas
        value={data.grid}
        onCanvasClick={(x, y) => act("paint", { x, y })} />
      <Box>
        {!data.finalized
        && <Button.Confirm
          onClick={() => act("finalize")}
          content="Finalize" />}
        {data.name}
      </Box>
    </Box>);
};
