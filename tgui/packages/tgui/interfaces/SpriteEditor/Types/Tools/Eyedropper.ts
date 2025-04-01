import { parseHexColorString } from '../../colorSpaces';
import { constrainToIconGrid, getDataPixel } from '../../helpers';
import { Tool } from '../Tool';
import { SpriteData, SpriteEditorContextType } from '../types';

export class Eyedropper extends Tool {
  icon = 'eye-dropper';
  name = 'Eyedropper';

  onMouseDown(
    context: SpriteEditorContextType,
    data: SpriteData,
    x: number,
    y: number,
    isRightClick?: boolean,
  ) {
    if (isRightClick) return;
    const { selectedDir, selectedLayer, setCurrentColor } = context;
    const { width, height } = data;
    const [px, py, inBounds] = constrainToIconGrid(x, y, width, height);
    if (!inBounds) return;
    setCurrentColor(
      parseHexColorString(
        getDataPixel(data, selectedLayer, selectedDir, px, py),
      ),
    );
  }
}
