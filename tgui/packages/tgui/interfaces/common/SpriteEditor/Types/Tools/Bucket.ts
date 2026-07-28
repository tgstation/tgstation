import { sendAct as act } from 'tgui/events/act';
import { colorToHexString } from '../../colorSpaces';
import { constrainToIconGrid } from '../../helpers';
import { Tool } from '../Tool';
import type { SpriteData, SpriteEditorToolContext } from '../types';

export class Bucket extends Tool {
  icon = 'fill-drip';
  name = 'Fill';

  onMouseDown(
    context: SpriteEditorToolContext,
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
