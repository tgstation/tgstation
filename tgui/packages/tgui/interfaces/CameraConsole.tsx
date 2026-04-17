import { sortBy } from 'es-toolkit';
import { filter } from 'es-toolkit/compat';
import { useState } from 'react';
import {
  Button,
  ByondUi,
  ImageButton,
  Input,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';
import { type BooleanLike, classes } from 'tgui-core/react';
import { createSearch } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  activeCamera: Camera & { status: BooleanLike };
  cameras: Camera[];
  pictures: Picture[];
  can_spy: BooleanLike;
  mapRef: string;
  network: string[];
  recording_cameras: string[];
};

type Camera = {
  name: string;
  ref: string;
};

type Picture = {
  name: string;
  desc: string;
  id: number;
  photo_url: string;
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
  return (
    <Window width={850} height={708}>
      <Window.Content>
        <CameraContent />
      </Window.Content>
    </Window>
  );
};

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
  const { activeCamera, recording_cameras = [] } = data;
  const cameras = selectCameras(data.cameras, searchText);

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
          {cameras.map((camera) => {
            return (
              <div
                key={camera.ref}
                title={camera.name}
                className={classes([
                  'Button',
                  'Button--fluid',
                  recording_cameras.includes(camera.ref)
                    ? 'Button--color--red'
                    : 'Button--color--transparent',
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
            );
          })}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const CameraControls = (props: { searchText: string }) => {
  const { act, data } = useBackend<Data>();
  const {
    activeCamera,
    can_spy,
    mapRef,
    pictures,
    recording_cameras = [],
  } = data;
  const { searchText } = props;
  const [showPictures, setShowPictures] = useState(true);

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
                icon="image"
                disabled={!activeCamera}
                onClick={() => act('take_photo')}
              />
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

            <Stack.Item>
              <Button
                icon={showPictures ? 'eye-slash' : 'eye'}
                tooltip={showPictures ? 'Hide photos' : 'Show photos'}
                onClick={() => setShowPictures(!showPictures)}
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item grow>
          <Stack fill vertical>
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
            {showPictures && (
              <Stack.Item basis="118px">
                <Section
                  fill
                  scrollable
                  title="Captured Pictures"
                  buttons={
                    activeCamera && [
                      <Button
                        key={`toggle-${activeCamera.ref}`}
                        color={
                          recording_cameras.includes(activeCamera.ref)
                            ? 'green'
                            : 'red'
                        }
                        icon={
                          recording_cameras.includes(activeCamera.ref)
                            ? 'circle-stop'
                            : 'video'
                        }
                        tooltipPosition="right"
                        onClick={() =>
                          act('toggle_recording', {
                            camera: activeCamera.ref,
                          })
                        }
                      >
                        {recording_cameras.includes(activeCamera.ref)
                          ? 'Recording...'
                          : 'Off'}
                      </Button>,
                    ]
                  }
                >
                  {!activeCamera ? (
                    <NoticeBox>No camera selected.</NoticeBox>
                  ) : pictures.length ? (
                    <Stack fill scrollable wrap="wrap" g={0.5}>
                      {pictures.map((picture) => (
                        <Stack.Item key={picture.id} basis="88px" grow={false}>
                          <ImageButton
                            fluid
                            imageSize={64}
                            imageSrc={picture.photo_url}
                            tooltip={picture.name || `Picture #${picture.id}`}
                            tooltipPosition="top"
                            onClick={() => {
                              act('show_photo', {
                                camera: activeCamera.ref,
                                photo_id: picture.id,
                              });
                            }}
                            buttons={
                              <Button
                                compact
                                icon="print"
                                tooltip="Print photo"
                                onClick={() =>
                                  act('print_photo', {
                                    camera: activeCamera.ref,
                                    photo_id: picture.id,
                                  })
                                }
                              />
                            }
                          />
                        </Stack.Item>
                      ))}
                    </Stack>
                  ) : (
                    <NoticeBox info>
                      This camera has no captured pictures yet.
                    </NoticeBox>
                  )}
                </Section>
              </Stack.Item>
            )}
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
