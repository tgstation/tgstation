import { sortBy } from 'es-toolkit';
import { filter } from 'es-toolkit/compat';
import { useState } from 'react';
import {
  Button,
  ByondUi,
  Input,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';
import { type BooleanLike, classes } from 'tgui-core/react';
import { createSearch } from 'tgui-core/string';
import { Window } from '../layouts';
import { useBackend } from '../backend';

export type CameraConsoleData = {
  activeCamera: Camera & { status: BooleanLike };
  cameras: Camera[];
  can_spy: BooleanLike;
  mapRef: string;
  network: string[];
};

type Camera = {
  name: string;
  ref: string;
};

/**
 * Returns previous and next camera names relative to the currently
 * active camera.
 */
const prevNextCamera = (
  cameras: Camera[],
  activeCamera: Camera & { status: BooleanLike },
) => {
  if (!activeCamera || cameras.length < 2) {
    return [];
  }

  const index = cameras.findIndex((camera) => camera.ref === activeCamera.ref);

  switch (index) {
    case -1: // Current camera is not in the list
      return [cameras[cameras.length - 1].ref, cameras[0].ref];

    case 0: // First camera
      if (cameras.length === 2) return [cameras[1].ref, cameras[1].ref]; // Only two

      return [cameras[cameras.length - 1].ref, cameras[index + 1].ref];

    case cameras.length - 1: // Last camera
      if (cameras.length === 2) return [cameras[0].ref, cameras[0].ref];

      return [cameras[index - 1].ref, cameras[0].ref];

    default:
      // Middle camera
      return [cameras[index - 1].ref, cameras[index + 1].ref];
  }
};

/**
 * Camera selector.
 *
 * Filters cameras, applies search terms and sorts the alphabetically.
 */
const selectCameras = (cameras: Camera[], searchText = ''): Camera[] => {
  let queriedCameras = filter(cameras, (camera: Camera) => !!camera.name);
  if (searchText) {
    const testSearch = createSearch(
      searchText,
      (camera: Camera) => camera.name,
    );
    queriedCameras = filter(queriedCameras, testSearch);
  }
  queriedCameras = sortBy(queriedCameras, [(c) => c.name]);

  return queriedCameras;
};

export const CameraConsole = (props) => {
  const { act, data } = useBackend<CameraConsoleData>();

  return (
    <Window width={850} height={708}>
      <Window.Content>
        <CameraContent act={act} data={data} />
      </Window.Content>
    </Window>
  );
};

type CameraContentProps = {
  act: any;
  data: CameraConsoleData;
};

export const CameraContent = (props: CameraContentProps) => {
  const { act, data } = props;
  const [searchText, setSearchText] = useState('');

  return (
    <Stack fill>
      <Stack.Item grow>
        <CameraSelector
          act={act}
          {...data}
          searchText={searchText}
          setSearchText={setSearchText}
        />
      </Stack.Item>
      <Stack.Item grow={3}>
        <CameraControls act={act} {...data} searchText={searchText} />
      </Stack.Item>
    </Stack>
  );
};

type CameraSelectorProps = {
  act: any;
  searchText: string;
  setSearchText: any;
} & CameraConsoleData;

const CameraSelector = (props: CameraSelectorProps) => {
  const { act, searchText, setSearchText, activeCamera } = props;
  const cameras = selectCameras(props.cameras, searchText);

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Input
          autoFocus
          fluid
          mt={1}
          placeholder="Search for a camera"
          onChange={setSearchText}
          value={searchText}
        />
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable>
          {cameras.map((camera) => (
            // We're not using the component here because performance
            // would be absolutely abysmal (50+ ms for each re-render).
            <div
              key={camera.ref}
              title={camera.name}
              className={classes([
                'Button',
                'Button--fluid',
                'Button--color--transparent',
                'Button--ellipsis',
                activeCamera?.ref === camera.ref
                  ? 'Button--selected'
                  : 'candystripe',
              ])}
              onClick={() =>
                act('switch_camera', {
                  camera: camera.ref,
                })
              }
            >
              {camera.name}
            </div>
          ))}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

type CameraControlsProps = {
  act: any;
  searchText: string;
} & CameraConsoleData;

const CameraControls = (props: CameraControlsProps) => {
  const { act, activeCamera, can_spy, mapRef, searchText } = props;

  const cameras = selectCameras(props.cameras, searchText);

  const [prevCamera, nextCamera] = prevNextCamera(cameras, activeCamera);

  return (
    <Section fill>
      <Stack fill vertical>
        <Stack.Item>
          <Stack fill>
            <Stack.Item grow>
              {activeCamera?.status ? (
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
                disabled={!prevCamera}
                onClick={() =>
                  act('switch_camera', {
                    camera: prevCamera,
                  })
                }
              />
            </Stack.Item>

            <Stack.Item>
              <Button
                icon="chevron-right"
                disabled={!nextCamera}
                onClick={() =>
                  act('switch_camera', {
                    camera: nextCamera,
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
