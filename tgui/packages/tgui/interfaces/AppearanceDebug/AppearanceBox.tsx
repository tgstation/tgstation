import { Box, Floating, Image, Stack, Tooltip } from 'tgui-core/components';
import { classes } from 'tgui-core/react';
import type { Appearance } from './types';
import { useAppearanceDebugContext } from './useAppearanceDebug';

export type AppearanceProps = {
  appearance: Appearance;
};

export function AppearanceBox(props: AppearanceProps) {
  const { appearance } = props;
  const { planeToText, layerToText, mapRef, act } = useAppearanceDebugContext();

  return (
    <Box
      position="absolute"
      left={`${appearance.position.x}px`}
      top={`${appearance.position.y}px`}
      minWidth="150px"
    >
      <Floating
        content={<Box />}
        contentClasses="Tooltip"
        hoverOpen
        placement="right"
        onOpenChange={(open) =>
          !!open && act('swapMapView', { id: appearance.data.id })
        }
      >
        <Box
          backgroundColor={'#000000'}
          py={1}
          px={1}
          className="ObjectComponent__Titlebar"
        >
          <Stack>
            <Stack.Item grow>
              {appearance.data.name || appearance.data.icon_state}
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
              layer:{' '}
              {appearance.data.layer_text_override ||
                Object.keys(layerToText).find(
                  (x) => layerToText[x] === appearance.data.layer,
                )}
              {appearance.data.layer !== -1 && ` (${appearance.data.layer})`}
            </Stack.Item>
            <Stack.Item style={{ borderBottom: '1px dashed hsl(0, 0%, 60%);' }}>
              <Tooltip content={`True plane: ${appearance.data.plane_true}`}>
                plane:{' '}
                {Object.keys(planeToText).find(
                  (x) => planeToText[x] === appearance.data.plane_true,
                ) || appearance.data.plane_true}
                {appearance.data.plane !== -32767 &&
                  ` (${appearance.data.plane})`}
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
      </Floating>
    </Box>
  );
}
