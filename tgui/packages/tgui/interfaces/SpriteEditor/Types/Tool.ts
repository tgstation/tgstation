import { Workspace } from './Workspace';

export abstract class Tool {
  abstract icon: string;
  abstract name: string;
  abstract onMouseDown(
    workspace: Workspace,
    x: number,
    y: number,
    isRightClick?: boolean,
  ): boolean;
  abstract onMouseMove(workspace: Workspace, x: number, y: number): void;
  abstract onMouseUp(workspace: Workspace, x?: number, y?: number): void;
}
