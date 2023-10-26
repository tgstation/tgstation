import { filter, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { BooleanLike, classes } from 'common/react';
import { createSearch } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Button, ByondUi, Input, NoticeBox, Section, Stack } from '../components';
import { Window } from '../layouts';

type Data = {
  can_spy: BooleanLike;
  mapRef: string;
  cameras: Camera[];
  activeCamera: Camera & { status: BooleanLike };
  network: string[];
};

type Camera = {
  name: string;
};

/**
 * Returns previous and next camera names relative to the currently
 * active camera.
 */
const prevNextCamera = (
  cameras: Camera[],
  activeCamera: Camera & { status: BooleanLike }
) => {
  if (!activeCamera) {
    return [];
  }
  const index = cameras.findIndex(
    (camera) => camera?.name === activeCamera.name
  );
  return [cameras[index - 1]?.name, cameras[index + 1]?.name];
};

/**
 * Camera selector.
 *
 * Filters cameras, applies search terms and sorts the alphabetically.
 */
const selectCameras = (cameras: Camera[], searchText = ''): Camera[] => {
  const testSearch = createSearch(searchText, (camera: Camera) => camera.name);

  return flow([
    // Null camera filter
    filter((camera: Camera) => !!camera?.name),
    // Optional search term
    searchText && filter(testSearch),
    // Slightly expensive, but way better than sorting in BYOND
    sortBy((camera: Camera) => camera.name),
  ])(cameras);
};

export const CameraConsole = (props, context) => {
  return (
    <Window width={850} height={708}>
      <Window.Content>
        <CameraContent />
      </Window.Content>
    </Window>
  );
};

export const CameraContent = (props, context) => {
  return (
    <Stack fill>
      <Stack.Item grow>
        <CameraSelector />
      </Stack.Item>
      <Stack.Item grow={3}>
        <CameraControls />
      </Stack.Item>
    </Stack>
  );
};

const CameraSelector = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');
  const { activeCamera } = data;
  const cameras = selectCameras(data.cameras, searchText);

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Input
          autoFocus
          fluid
          mt={1}
          placeholder="Search for a camera"
          onInput={(e, value) => setSearchText(value)}
        />
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable>
          {cameras.map((camera) => (
            // We're not using the component here because performance
            // would be absolutely abysmal (50+ ms for each re-render).
            <div
              key={camera.name}
              title={camera.name}
              className={classes([
                'candystripe',
                'Button',
                'Button--fluid',
                'Button--color--transparent',
                'Button--ellipsis',
                activeCamera &&
                  camera.name === activeCamera.name &&
                  'Button--selected',
              ])}
              onClick={() =>
                act('switch_camera', {
                  name: camera.name,
                })
              }>
              {camera.name}
            </div>
          ))}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const CameraControls = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { activeCamera, can_spy, mapRef } = data;
  const cameras = selectCameras(data.cameras);

  const [prevCameraName, nextCameraName] = prevNextCamera(
    cameras,
    activeCamera
  );

  return (
    <Section fill>
      <Stack fill vertical>
        <Stack.Item>
          <Stack fill>
            <Stack.Item grow>
              {activeCamera?.name ? (
                <NoticeBox info>{activeCamera.name}</NoticeBox>
              ) : (
                <NoticeBox danger>No input signal</NoticeBox>
              )}
            </Stack.Item>

            <Stack.Item>
              {!!can_spy && (
                <Button
                  icon="magnifying-glass"
                  tooltip="Track Person"
                  onClick={() => act('start_tracking')}
                />
              )}
            </Stack.Item>

            <Stack.Item>
              <Button
                icon="chevron-left"
                disabled={!prevCameraName}
                onClick={() =>
                  act('switch_camera', {
                    name: prevCameraName,
                  })
                }
              />
            </Stack.Item>

            <Stack.Item>
              <Button
                icon="chevron-right"
                disabled={!nextCameraName}
                onClick={() =>
                  act('switch_camera', {
                    name: nextCameraName,
                  })
                }
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item grow>
          <ByondUi
            height="100%"
            width="100%"
            params={{
              id: mapRef,
              type: 'map',
            }}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};
