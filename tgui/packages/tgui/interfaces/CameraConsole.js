import { filter, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { classes } from 'common/react';
import { createSearch } from 'common/string';
import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Button, ByondUi, Input, Section } from '../components';
import { Window } from '../layouts';

/**
 * Returns previous and next camera names relative to the currently
 * active camera.
 */
const prevNextCamera = (cameras, activeCamera) => {
  if (!activeCamera) {
    return [];
  }
  const index = cameras.findIndex(camera => (
    camera.name === activeCamera.name
  ));
  return [
    cameras[index - 1]?.name,
    cameras[index + 1]?.name,
  ];
};

/**
 * Camera selector.
 *
 * Filters cameras, applies search terms and sorts the alphabetically.
 */
const selectCameras = (cameras, searchText = '') => {
  const testSearch = createSearch(searchText, camera => camera.name);
  return flow([
    // Null camera filter
    filter(camera => camera?.name),
    // Optional search term
    searchText && filter(testSearch),
    // Slightly expensive, but way better than sorting in BYOND
    sortBy(camera => camera.name),
  ])(cameras);
};

export const CameraConsole = (props, context) => {
  const { act, data, config } = useBackend(context);
  const { mapRef, activeCamera } = data;
  const cameras = selectCameras(data.cameras);
  const [
    prevCameraName,
    nextCameraName,
  ] = prevNextCamera(cameras, activeCamera);
  return (
    <Window
      width={870}
      height={708}
      resizable>
      <div className="CameraConsole__left">
        <Window.Content scrollable>
          <CameraConsoleContent />
        </Window.Content>
      </div>
      <div className="CameraConsole__right">
        <div className="CameraConsole__toolbar">
          <b>Camera: </b>
          {activeCamera
            && activeCamera.name
            || '—'}
        </div>
        <div className="CameraConsole__toolbarRight">
          <Button
            icon="chevron-left"
            disabled={!prevCameraName}
            onClick={() => act('switch_camera', {
              name: prevCameraName,
            })} />
          <Button
            icon="chevron-right"
            disabled={!nextCameraName}
            onClick={() => act('switch_camera', {
              name: nextCameraName,
            })} />
        </div>
        <ByondUi
          className="CameraConsole__map"
          params={{
            id: mapRef,
            type: 'map',
          }} />
      </div>
    </Window>
  );
};

export const CameraConsoleContent = (props, context) => {
  const { act, data } = useBackend(context);
  const [
    searchText,
    setSearchText,
  ] = useLocalState(context, 'searchText', '');
  const { activeCamera } = data;
  const cameras = selectCameras(data.cameras, searchText);
  return (
    <Fragment>
      <Input
        autoFocus
        fluid
        mb={1}
        placeholder="Search for a camera"
        onInput={(e, value) => setSearchText(value)} />
      <Section>
        {cameras.map(camera => (
          // We're not using the component here because performance
          // would be absolutely abysmal (50+ ms for each re-render).
          <div
            key={camera.name}
            title={camera.name}
            className={classes([
              'Button',
              'Button--fluid',
              'Button--color--transparent',
              'Button--ellipsis',
              activeCamera
                && camera.name === activeCamera.name
                && 'Button--selected',
            ])}
            onClick={() => act('switch_camera', {
              name: camera.name,
            })}>
            {camera.name}
          </div>
        ))}
      </Section>
    </Fragment>
  );
};
