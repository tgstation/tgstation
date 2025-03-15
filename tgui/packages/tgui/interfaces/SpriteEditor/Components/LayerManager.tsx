import { Box, Button, Icon, Input, Section, Stack } from 'tgui-core/components';
import { BooleanStyleMap, StringStyleMap } from 'tgui-core/ui';

import {
  AddLayerTransaction,
  DeleteLayerTransaction,
  FlattenLayerTransaction,
  MoveLayerDownTransaction,
  MoveLayerUpTransaction,
  RenameLayerTransaction,
} from '../Types/LayerModTransactions';
import { Dir, InlineStyle } from '../Types/types';
import { Workspace } from '../Types/Workspace';
import { AdvancedCanvas } from './AdvancedCanvas';

type LayerManagerProps = {
  workspace: Workspace;
} & Partial<BooleanStyleMap & StringStyleMap & InlineStyle>;

const dirs = [Dir.SOUTH, Dir.NORTH, Dir.EAST, Dir.WEST];
const dirCellPrefixes = ['south', 'north', 'east', 'west'];
const dirIcons = ['arrow-down', 'arrow-up', 'arrow-right', 'arrow-left'];

export const LayerManager = (props: LayerManagerProps) => {
  const { workspace, ...rest } = props;
  const { icon, selectedDir, selectedLayer } = workspace;
  const { width, height, inner } = icon;
  const { dirs: iconDirs } = inner;
  const layers = workspace.metadata.length;
  const cells = [
    `". ${dirCellPrefixes.slice(0, iconDirs).join(' ')} add"`,
    ...Array.from(
      { length: layers },
      (_, i) =>
        `"leftControls${i} ${dirCellPrefixes
          .slice(0, iconDirs)
          .map((dir) => `${dir}${i}`)
          .join(' ')} rightControls${i}"`,
    ).toReversed(),
  ].join(' ');
  const metadata = workspace.useMetadata();
  return (
    <Box {...rest}>
      <Section fill title="Layers">
        <Box
          width="100%"
          height="100%"
          align="center"
          overflowY="scroll"
          style={{
            alignItems: 'center',
            display: 'grid',
            gridTemplateAreas: cells,
            gridTemplateColumns: `max-content repeat(${iconDirs}, max-content) max-content`,
            gridAutoRows: 'max-content',
            gridAutoColumns: 'max-content',
          }}
        >
          {iconDirs > 1 &&
            Array.from({ length: iconDirs }, (_, i) => (
              <Icon
                pb="0.5rem"
                key={i}
                size={2}
                name={dirIcons[i]}
                style={{
                  gridArea: dirCellPrefixes[i],
                }}
              />
            ))}
          <Box style={{ gridArea: 'add' }}>
            <Button
              icon="plus"
              tooltip="Add Layer"
              onClick={() =>
                workspace.commitTransaction(new AddLayerTransaction())
              }
            />
          </Box>
          {metadata.map((metadata, i) => {
            const { name, visible } = metadata;
            return (
              <>
                <Box
                  mr="0.5rem"
                  key={i}
                  style={{ gridArea: `leftControls${i}` }}
                >
                  <Input
                    inline
                    width="10rem"
                    value={name}
                    updateOnPropsChange
                    onChange={(_, value) => {
                      if (name === value) return;
                      workspace.commitTransaction(
                        new RenameLayerTransaction(workspace, i, value),
                      );
                    }}
                  />
                  <Button
                    inline
                    icon={visible ? 'eye' : 'eye-slash'}
                    onClick={() => {
                      metadata.visible = !metadata.visible;
                      workspace.markMainCanvasDataDirty();
                      workspace.markMetadataChanged();
                    }}
                  />
                </Box>
                {dirs.slice(0, iconDirs).map((dir, j) => (
                  <Box
                    key={j}
                    style={{ gridArea: `${dirCellPrefixes[j]}${i}` }}
                  >
                    <AdvancedCanvas
                      data={icon.getStack(dir)![i]}
                      width={`${width}px`}
                      height={`${height}px`}
                      ml="0.25rem"
                      mr="0.25rem"
                      onClick={() => {
                        workspace.selectedDir = dir;
                        workspace.selectedLayer = i;
                        workspace.markMainCanvasDataDirty();
                        workspace.markMetadataChanged();
                      }}
                      border={
                        selectedDir === dir && selectedLayer === i
                          ? { border: '2px solid #00ff00' }
                          : undefined
                      }
                    />
                  </Box>
                ))}
                <Box ml="0.5rem" style={{ gridArea: `rightControls${i}` }}>
                  <Stack>
                    <Stack.Item>
                      <Button
                        icon="arrow-up"
                        tooltip="Move Up"
                        disabled={i === layers - 1}
                        onClick={() =>
                          workspace.commitTransaction(
                            new MoveLayerUpTransaction(workspace, i),
                          )
                        }
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        icon="arrow-down"
                        tooltip="Move Down"
                        disabled={i === 0}
                        onClick={() =>
                          workspace.commitTransaction(
                            new MoveLayerDownTransaction(workspace, i),
                          )
                        }
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        icon="layer-group"
                        tooltip="Flatten"
                        disabled={i === 0}
                        onClick={() =>
                          workspace.commitTransaction(
                            new FlattenLayerTransaction(workspace, i),
                          )
                        }
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <Button.Confirm
                        icon="xmark"
                        tooltip="Delete"
                        disabled={layers === 1}
                        onClick={() =>
                          workspace.commitTransaction(
                            new DeleteLayerTransaction(workspace, i),
                          )
                        }
                      />
                    </Stack.Item>
                  </Stack>
                </Box>
              </>
            );
          })}
        </Box>
      </Section>
    </Box>
  );
};
