import { useBackend } from '../backend';
import { Button, ByondUi } from '../components';
import { NtosWindow } from '../layouts';
import { prevNextCamera, selectCameras, CameraConsoleContent } from './CameraConsole';

type Data = {
  mapRef: string;
  activeCamera: Camera;
  cameras: Camera[];
};

type Camera = {
  name: string;
};

export const NtosSecurEye = (props, context) => {
  return (
    <NtosWindow width={800} height={600}>
      <NtosWindow.Content>
        <div className="CameraConsole__left">
          <CameraConsoleContent />
        </div>
        <CameraControls />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

/** Displays info and controls for the current camera */
const CameraControls = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { activeCamera, mapRef } = data;
  const cameras = selectCameras(data.cameras);
  const [prevCameraName, nextCameraName] = prevNextCamera(
    cameras,
    activeCamera
  );

  return (
    <div className="CameraConsole__right">
      <div className="CameraConsole__toolbar">
        <b>Camera: </b>
        {(activeCamera && activeCamera.name) || '—'}
      </div>
      <div className="CameraConsole__toolbarRight">
        <Button
          icon="chevron-left"
          disabled={!prevCameraName}
          onClick={() =>
            act('switch_camera', {
              name: prevCameraName,
            })
          }
        />
        <Button
          icon="chevron-right"
          disabled={!nextCameraName}
          onClick={() =>
            act('switch_camera', {
              name: nextCameraName,
            })
          }
        />
      </div>
      <ByondUi
        className="CameraConsole__map"
        params={{
          id: mapRef,
          type: 'map',
        }}
      />
    </div>
  );
};
