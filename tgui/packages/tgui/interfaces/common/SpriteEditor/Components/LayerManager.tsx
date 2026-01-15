import type { Dispatch, SetStateAction } from 'react';
import { useBackend } from 'tgui/backend';
import { Box, Button, Icon, Input, Section, Stack } from 'tgui-core/components';
import type { BooleanStyleMap, StringStyleMap } from 'tgui-core/ui';
import { Dir, type InlineStyle, type SpriteData } from '../Types/types';
import { AdvancedCanvas } from './AdvancedCanvas';

export type LayerManagerProps = {
  data: SpriteData;
  selectedDir: Dir;
  setSelectedDir: Dispatch<SetStateAction<Dir>>;
  selectedLayer: number;
  setSelectedLayer: Dispatch<SetStateAction<number>>;
} & Partial<BooleanStyleMap & StringStyleMap & InlineStyle>;

const dirs = [Dir.SOUTH, Dir.NORTH, Dir.EAST, Dir.WEST];
const dirCellPrefixes = ['south', 'north', 'east', 'west'];
const dirIcons = ['arrow-down', 'arrow-up', 'arrow-right', 'arrow-left'];

export const LayerManager = (props: LayerManagerProps) => {
  const { act } = useBackend();
  const {
    data,
    selectedDir,
    setSelectedDir,
    selectedLayer,
    setSelectedLayer,
    ...rest
  } = props;
  const { width, height, dirs: iconDirs, layers } = data;
  const layerCount = layers.length;
  const cells = [
    `". ${dirCellPrefixes.slice(0, iconDirs).join(' ')} add"`,
    ...Array.from(
      { length: layerCount },
      (_, i) =>
        `"leftControls${i} ${dirCellPrefixes
          .slice(0, iconDirs)
          .map((dir) => `${dir}${i}`)
          .join(' ')} rightControls${i}"`,
    ).toReversed(),
  ].join(' ');
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
                act('spriteEditorCommand', {
                  command: 'transaction',
                  transaction: { type: 'addLayer', name: 'Add Layer' },
                })
              }
            />
          </Box>
          {layers.map((layer, i) => {
            const { name, data, visible } = layer;
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
                    onChange={(value) => {
                      if (name === value) return;
                      act('spriteEditorCommand', {
                        command: 'transaction',
                        transaction: {
                          type: 'renameLayer',
                          name: `Rename ${name} to ${value}`,
                          layer: i + 1,
                          newName: value,
                          oldName: name,
                        },
                      });
                    }}
                  />
                  <Button
                    inline
                    icon={visible ? 'eye' : 'eye-slash'}
                    onClick={() =>
                      act('spriteEditorCommand', {
                        command: 'toggleVisible',
                        layer: i + 1,
                      })
                    }
                  />
                </Box>
                {dirs.slice(0, iconDirs).map((dir, j) => (
                  <Box
                    key={j}
                    style={{ gridArea: `${dirCellPrefixes[j]}${i}` }}
                  >
                    <AdvancedCanvas
                      data={data[dir]!}
                      width={`${width}px`}
                      height={`${height}px`}
                      ml="0.25rem"
                      mr="0.25rem"
                      onClick={() => {
                        setSelectedDir(dir);
                        setSelectedLayer(i);
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
                        disabled={i === layerCount - 1}
                        onClick={() =>
                          act('spriteEditorCommand', {
                            command: 'transaction',
                            transaction: {
                              type: 'moveLayerUp',
                              name: `Move ${name} Up`,
                              layer: i + 1,
                            },
                          })
                        }
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        icon="arrow-down"
                        tooltip="Move Down"
                        disabled={i === 0}
                        onClick={() =>
                          act('spriteEditorCommand', {
                            command: 'transaction',
                            transaction: {
                              type: 'moveLayerDown',
                              name: `Move ${name} Down`,
                              layer: i + 1,
                            },
                          })
                        }
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        icon="layer-group"
                        tooltip="Flatten"
                        disabled={i === 0}
                        onClick={() =>
                          act('spriteEditorCommand', {
                            command: 'transaction',
                            transaction: {
                              type: 'flattenLayer',
                              name: `Flatten ${name} onto ${layers[i - 1].name}`,
                              layer: i + 1,
                            },
                          })
                        }
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <Button.Confirm
                        icon="xmark"
                        tooltip="Delete"
                        disabled={layerCount === 1}
                        onClick={() =>
                          act('spriteEditorCommand', {
                            command: 'transaction',
                            transaction: {
                              type: 'deleteLayer',
                              name: `Delete ${name}`,
                              layer: i + 1,
                            },
                          })
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
