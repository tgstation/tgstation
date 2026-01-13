import { useBackend } from 'tgui/backend';
import { colorToHexString } from '../../colorSpaces';
import { constrainToIconGrid } from '../../helpers';
import { Tool } from '../Tool';
import type { SpriteData, SpriteEditorContextType } from '../types';

export class Bucket extends Tool {
  icon = 'fill-drip';
  name = 'Fill';

  onMouseDown(
    context: SpriteEditorContextType,
    data: SpriteData,
    x: number,
    y: number,
    isRightClick?: boolean,
  ) {
    if (isRightClick) return undefined;
    const { selectedDir, selectedLayer, currentColor } = context;
    const { width, height } = data;
    const [px, py, inBounds] = constrainToIconGrid(x, y, width, height);
    if (!inBounds) return undefined;
    const { act } = useBackend();
    act('spriteEditorCommand', {
      command: 'transaction',
      transaction: {
        type: 'bucket',
        name: 'Flood Fill',
        layer: selectedLayer + 1,
        dir: `${selectedDir}`,
        color: colorToHexString(currentColor),
        point: [px, py],
      },
    });
  }
}
