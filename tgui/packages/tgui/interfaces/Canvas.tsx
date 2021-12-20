import { Color } from 'common/color';
import { decodeHtmlEntities } from 'common/string';
import { Component, createRef, RefObject } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, Flex } from '../components';
import { Window } from '../layouts';

const PX_PER_UNIT = 24;

type PaintCanvasProps = Partial<{
  onCanvasModifiedHandler: (data : PointData[]) => void,
  value: string[][],
  width: number,
  height: number,
  imageWidth: number,
  imageHeight: number,
  editable: boolean,
  drawing_color: string | null,
}>;

type PointData = {
  x: number,
  y: number,
  color: Color
}

const fromDM = (data: string[][]) => {
  return data.map(inner => inner.map(v => Color.fromHex(v)));
};

const toMassPaintFormat = (data: PointData[]) => {
  return data.map(p => ({ x: p.x+1, y: p.y+1 })); // 1-based index dm side
};

class PaintCanvas extends Component<PaintCanvasProps> {
  canvasRef: RefObject<HTMLCanvasElement>;
  baseImageData: Color[][]
  modifiedElements: PointData[];
  onCanvasModified: (data: PointData[]) => void;
  drawing: boolean;
  drawing_color: string;

  constructor(props) {
    super(props);
    this.canvasRef = createRef<HTMLCanvasElement>();
    this.modifiedElements = [];
    this.drawing = false;
    this.onCanvasModified = props.onCanvasModifiedHandler;

    this.handleStartDrawing = this.handleStartDrawing.bind(this);
    this.handleDrawing = this.handleDrawing.bind(this);
    this.handleEndDrawing = this.handleEndDrawing.bind(this);
  }

  componentDidMount() {
    this.prepareCanvas();
    this.syncCanvas();
  }

  componentDidUpdate() {
    // eslint-disable-next-line max-len
    if (this.props.value !== undefined && JSON.stringify(this.baseImageData) !== JSON.stringify(fromDM(this.props.value))) {
      this.syncCanvas();
    }
  }

  prepareCanvas() {
    const canvas = this.canvasRef.current!;
    const ctx = canvas.getContext("2d");
    const width = this.props.width || canvas.width || 360;
    const height = this.props.height || canvas.height || 360;
    const x_resolution = this.props.imageWidth || 36;
    const y_resolution = this.props.imageHeight || 36;
    const x_scale = Math.round(width / x_resolution);
    const y_scale = Math.round(height / y_resolution);
    ctx?.setTransform(1, 0, 0, 1, 0, 0);
    ctx?.scale(x_scale, y_scale); // This clears the canvas.
  }

  syncCanvas() {
    if (this.props.value === undefined) {
      return;
    }
    this.baseImageData = fromDM(this.props.value);
    this.modifiedElements = [];

    const canvas = this.canvasRef.current!;
    const ctx = canvas.getContext("2d")!;
    for (let x = 0; x < this.baseImageData.length; x++) {
      const element = this.baseImageData[x];
      for (let y = 0; y < element.length; y++) {
        const color = element[y];
        ctx.fillStyle = color.toString();
        ctx.fillRect(x, y, 1, 1);
      }
    }
  }

  eventToCoords(event : MouseEvent) {
    const canvas = this.canvasRef.current!;
    const width = this.props.width || canvas.width || 360;
    const height = this.props.height || canvas.height || 360;
    const x_resolution = this.props.imageWidth || 36;
    const y_resolution = this.props.imageHeight || 36;
    const x_scale = Math.round(width / x_resolution);
    const y_scale = Math.round(height / y_resolution);
    const x = Math.floor(event.offsetX / x_scale);
    const y = Math.floor(event.offsetY / y_scale);
    return { x, y };
  }

  handleStartDrawing(event : MouseEvent) {
    if (!this.props.editable
       || this.props.drawing_color === undefined
       || this.props.drawing_color === null) {
      return;
    }
    this.modifiedElements = [];
    this.drawing = true;
    this.drawing_color = this.props.drawing_color;
    const coords = this.eventToCoords(event);
    this.drawPoint(coords.x, coords.y, this.drawing_color);
  }

  drawPoint(x: number, y: number, color: any) {
    let p: PointData = { x, y, color: Color.fromHex(color) };
    this.modifiedElements.push(p);
    const canvas = this.canvasRef.current!;
    const ctx = canvas.getContext("2d")!;
    ctx.fillStyle = color;
    ctx.fillRect(x, y, 1, 1);
  }

  handleDrawing(event: MouseEvent) {
    if (!this.drawing) {
      return;
    }
    const coords = this.eventToCoords(event);
    this.drawPoint(coords.x, coords.y, this.drawing_color);
  }

  handleEndDrawing(event: MouseEvent) {
    if (!this.drawing) {
      return;
    }
    this.drawing = false;
    const canvas = this.canvasRef.current!;
    const ctx = canvas.getContext("2d")!;
    if (this.onCanvasModified !== undefined) {
      this.onCanvasModified(this.modifiedElements);
    }
  }

  render() {
    const {
      value,
      width = 300,
      height = 300,
      imageWidth = 36,
      imageHeight = 36,
      ...rest
    } = this.props;
    return (
      <canvas
        ref={this.canvasRef}
        width={width}
        height={height}
        {...rest}
        onMouseDown={this.handleStartDrawing}
        onMouseMove={this.handleDrawing}
        onMouseUp={this.handleEndDrawing}
        onMouseOut={this.handleEndDrawing}>
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

type CanvasData = {
  grid: string[][],
  finalized: boolean,
  name: string,
  editable: boolean,
  paint_tool_color: string | null,
  author: string | null,
  medium: string | null,
  patron: string | null,
  date: string | null,
  show_plaque: boolean
}

export const Canvas = (props, context) => {
  const { act, data } = useBackend<CanvasData>(context);
  const [width, height] = getImageSize(data.grid);
  const scaled_width = width * PX_PER_UNIT;
  const scaled_height = height * PX_PER_UNIT;
  const average_plaque_height = 90;
  return (
    <Window
      width={scaled_width + 72}
      height={scaled_height + 70
        + (data.show_plaque ? average_plaque_height : 0)}>
      <Window.Content>
        <Box textAlign="center">
          <PaintCanvas
            value={data.grid}
            imageWidth={width}
            imageHeight={height}
            width={scaled_width}
            height={scaled_height}
            drawing_color={data.paint_tool_color}
            onCanvasModifiedHandler={(changed) => act("paint", { data: toMassPaintFormat(changed) })}
            editable={data.editable}
          />
          <Flex align="center" justify="center">
            {!data.finalized && (
              <Flex.Item>
                <Button.Confirm
                  onClick={() => act("finalize")}
                  content="Finalize" />
              </Flex.Item>
            )}
            {!!data.finalized && !!data.show_plaque && (
              <Flex.Item
                p={2}
                width="60%"
                textColor="black"
                textAlign="left"
                backgroundColor="white"
                style={{ "border-style": "inset" }}>
                <Box mb={1} fontSize="18px" bold>{decodeHtmlEntities(data.name)}</Box>
                <Box bold>
                  {data.author}
                  {!!data.date && `- ${new Date(data.date).getFullYear()+540}`}
                </Box>
                <Box italic>{data.medium}</Box>
                <Box italic>
                  {!!data.patron && `Sponsored by ${data.patron} `}
                  <Button icon="hand-holding-usd" color="transparent" iconColor="black" onClick={() => act("patronage")} />
                </Box>
              </Flex.Item>
            )}
          </Flex>
        </Box>
      </Window.Content>
    </Window>
  );
};
