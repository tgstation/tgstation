import { parseHexColorString } from '../../colorSpaces';
import { constrainToIconGrid, getDataPixel } from '../../helpers';
import { Tool } from '../Tool';
import type { SpriteData, SpriteEditorToolContext } from '../types';

export class Eyedropper extends Tool {
  icon = 'eye-dropper';
  name = 'Eyedropper';

  onMouseDown(
    context: SpriteEditorToolContext,
    data: SpriteData,
    x: number,
    y: number,
    isRightClick?: boolean,
  ) {
    if (isRightClick) return undefined;
    const { selectedDir, selectedLayer, setCurrentColor } = context;
    const { width, height } = data;
    const [px, py, inBounds] = constrainToIconGrid(x, y, width, height);
    if (!inBounds) return undefined;
    setCurrentColor(
      parseHexColorString(
        getDataPixel(data, selectedLayer, selectedDir, px, py),
      ),
    );
  }
}
