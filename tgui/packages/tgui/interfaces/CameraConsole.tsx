import { filter, sort } from 'common/collections';
import { useState } from 'react';
import {
  Box,
  Button,
  ByondUi,
  Icon,
  Input,
  NoticeBox,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';
import { BooleanLike, classes } from 'tgui-core/react';
import { createSearch } from 'tgui-core/string';

import { useBackend } from '../backend';
import { NanoMap } from '../components/NanoMap'; // BANDASTATION EDIT START - Nanomap
import { Window } from '../layouts';

type Data = {
  activeCamera: Camera & { status: BooleanLike };
  cameras: Camera[];
  can_spy: BooleanLike;
  mapRef: string;
  network: string[];
  // BANDASTATION EDIT START - Nanomap
  mapUrl: string;
  selected_z_level: number;
  // BANDASTATION EDIT END - Nanomap
};

type Camera = {
  name: string;
  ref: string;
  // BANDASTATION EDIT START - Nanomap
  x: number;
  y: number;
  z: number;
  status: BooleanLike;
  // BANDASTATION EDIT END - Nanomap
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
  queriedCameras = sort(queriedCameras);

  return queriedCameras;
};

// BANDASTATION EDIT START - Nanomap
export const CameraConsole = (props) => {
  const [tabIndex, setTabIndex] = useState(0);
  const decideTab = (index) => {
    switch (index) {
      case 0:
        return <CameraConsoleMapContent />;
      case 1:
        return <CameraContent />;
      default:
        return "WE SHOULDN'T BE HERE!";
    }
  };
  return (
    <Window width={1170} height={755}>
      <Window.Content>
        <Stack>
          <Box fillPositionedParent>
            <Stack.Item
              width={tabIndex === 1 ? '222px' : '475px'}
              textAlign="center"
            >
              <Tabs
                fluid
                ml={tabIndex === 1 ? 1 : 0}
                mt={tabIndex === 1 ? 1 : 0}
              >
                <Tabs.Tab
                  key="Map"
                  selected={tabIndex === 0}
                  onClick={() => setTabIndex(0)}
                >
                  <Icon name="map-marked-alt" /> Карта
                </Tabs.Tab>
                <Tabs.Tab
                  key="List"
                  selected={tabIndex === 1}
                  onClick={() => setTabIndex(1)}
                >
                  <Icon name="table" /> Список
                </Tabs.Tab>
              </Tabs>
            </Stack.Item>
            {decideTab(tabIndex)}
          </Box>
        </Stack>
      </Window.Content>
    </Window>
  );
};

export const CameraConsoleMapContent = (props) => {
  const { act, data } = useBackend<Data>();
  const cameras = selectCameras(data.cameras, '');
  const [zoom, setZoom] = useState(1);
  const { activeCamera, mapUrl, selected_z_level } = data;
  return (
    <Stack fill>
      <Stack.Item height="100%" width="475px">
        <NanoMap onZoom={(v) => setZoom(v)} mapUrl={mapUrl}>
          {cameras
            .filter((cam) => cam.z === Number(selected_z_level))
            .map((cm) => (
              <NanoMap.NanoButton
                props={props}
                activeCamera={activeCamera}
                key={cm.ref}
                x={cm.x}
                y={cm.y}
                zoom={zoom}
                icon={null}
                tooltip={cm.name}
                name={cm.name}
                color={'blue'}
                status={cm.status}
                cam_ref={cm.ref}
              />
            ))}
        </NanoMap>
      </Stack.Item>
      <Stack.Item className="CameraConsole__right_map">
        <CameraControls searchText={''} />
      </Stack.Item>
    </Stack>
  );
};
// BANDASTATION EDIT END - Nanomap

export const CameraContent = (props) => {
  const [searchText, setSearchText] = useState('');

  return (
    <Stack fill>
      <Stack.Item grow>
        <CameraSelector searchText={searchText} setSearchText={setSearchText} />
      </Stack.Item>
      <Stack.Item grow={3}>
        <CameraControls searchText={searchText} />
      </Stack.Item>
    </Stack>
  );
};

const CameraSelector = (props) => {
  const { act, data } = useBackend<Data>();
  const { searchText, setSearchText } = props;
  const { activeCamera } = data;
  const cameras = selectCameras(data.cameras, searchText);

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Input
          autoFocus
          expensive
          fluid
          mt={1}
          placeholder="Search for a camera"
          onInput={(e, value) => setSearchText(value)}
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

const CameraControls = (props: { searchText: string }) => {
  const { act, data } = useBackend<Data>();
  const { activeCamera, can_spy, mapRef } = data;
  const { searchText } = props;

  const cameras = selectCameras(data.cameras, searchText);

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
