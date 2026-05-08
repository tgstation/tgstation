import { Box, Button, Image, Stack, Tooltip } from 'tgui-core/components';
import { classes } from 'tgui-core/react';
import type { Coordinates } from '../common/Connections';
import {
  getReadableLayer,
  getReadablePlane,
  isEmissive,
  isEmissiveBlocker,
} from '.';
import {
  APPEARANCE_FLAGS,
  type Appearance,
  AppearanceType,
  HiddenState,
} from './types';
import { useAppearanceDebugContext } from './useAppearanceDebug';

export type AppearanceProps = {
  appearance: Appearance;
  position: Coordinates;
  onClick: React.MouseEventHandler<HTMLDivElement>;
};

export function AppearanceBox(props: AppearanceProps) {
  const { appearance, position, onClick } = props;
  const { planeToText, layerToText, act } = useAppearanceDebugContext();

  return (
    <>
      {!!(
        appearance.data.flags &
        (APPEARANCE_FLAGS.KEEP_APART | APPEARANCE_FLAGS.KEEP_TOGETHER)
      ) && (
        <Box
          position="absolute"
          left={`${position.x + appearance.boundingBox[0].x}px`}
          top={`${position.y + appearance.boundingBox[0].y}px`}
          width={`${appearance.boundingBox[1].x - appearance.boundingBox[0].x}px`}
          height={`${appearance.boundingBox[1].y - appearance.boundingBox[0].y}px`}
          onMouseOver={() =>
            act('swapMapViewHover', { id: appearance.data.id })
          }
          style={{
            zIndex: -(999 - appearance.depth),
            border: `3px solid ${appearance.data.flags & APPEARANCE_FLAGS.KEEP_APART ? (appearance.data.flags & APPEARANCE_FLAGS.KEEP_TOGETHER ? '#2a7dc6' : '#107e2e') : '#e9cb0c'}`,
            borderRadius: '5px',
            padding: '5px',
            backgroundColor: `${appearance.data.flags & APPEARANCE_FLAGS.KEEP_APART ? (appearance.data.flags & APPEARANCE_FLAGS.KEEP_TOGETHER ? '#223c54' : '#13381c') : '#544b15'}`,
          }}
        >
          {!!(appearance.data.flags & APPEARANCE_FLAGS.KEEP_APART) &&
            'KEEP_APART'}
          {!!(
            appearance.data.flags & APPEARANCE_FLAGS.KEEP_APART &&
            appearance.data.flags & APPEARANCE_FLAGS.KEEP_TOGETHER
          ) && ' | '}
          {!!(appearance.data.flags & APPEARANCE_FLAGS.KEEP_TOGETHER) &&
            'KEEP_TOGETHER'}
        </Box>
      )}
      <Box
        position="absolute"
        left={`${position.x}px`}
        top={`${position.y}px`}
        minWidth="150px"
        onMouseOver={() => act('swapMapViewHover', { id: appearance.data.id })}
        onClick={onClick}
        style={{ zIndex: 1 }}
        opacity={appearance.hidden === HiddenState.VisibleChild ? 0.7 : 1}
      >
        <Box
          backgroundColor={
            appearance.data.type === AppearanceType.Atom
              ? '#ba5614'
              : appearance.data.type === AppearanceType.Image
                ? '#932bad'
                : '#19964d'
          }
          py={1}
          px={1}
          className="ObjectComponent__Titlebar"
        >
          <Stack>
            <Stack.Item grow>
              {appearance.data.name || appearance.data.icon_state}
              {isEmissive(appearance)
                ? ' (Emissive)'
                : isEmissiveBlocker(appearance)
                  ? ' (Emissive Blocker)'
                  : ''}
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="pager"
                compact
                tooltip="View Variables (Mirror)"
                onClick={() => act('vvAppearance', { id: appearance.data.id })}
              />
            </Stack.Item>
          </Stack>
        </Box>

        <Box className={classes(['ObjectComponent__Content'])} py={1} px={1}>
          <Stack vertical>
            {appearance.data.icon && (
              <Stack.Item>icon: {appearance.data.icon}</Stack.Item>
            )}
            {appearance.data.icon_state && (
              <Stack.Item>icon_state: {appearance.data.icon_state}</Stack.Item>
            )}
            <Stack.Item>
              layer:{` ${getReadableLayer(appearance, layerToText)}`}
            </Stack.Item>
            <Stack.Item style={{ borderBottom: '1px dashed hsl(0, 0%, 60%);' }}>
              <Tooltip content={`True plane: ${appearance.data.plane_true}`}>
                plane:{` ${getReadablePlane(appearance, planeToText)}`}
              </Tooltip>
            </Stack.Item>
            {!!appearance.data.embed_icon && (
              <Stack.Item height="64px" width="64px">
                <Image
                  src={`data:image/jpeg;base64,${appearance.data.embed_icon}`}
                  height="64px"
                  width="64px"
                  m="2px"
                />
              </Stack.Item>
            )}
          </Stack>
        </Box>
      </Box>
    </>
  );
}
