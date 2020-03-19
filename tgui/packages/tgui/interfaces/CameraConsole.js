import { classes } from 'common/react';
import { Component, Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, ByondUi, Input, NoticeBox, Section } from '../components';
import { createLogger } from '../logging';
import { refocusLayout } from '../refocus';

const logger = createLogger('CameraConsole');

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

export const CameraConsoleWrapper = props => {
  const { act, data, config, visible } = useBackend(props);
  const { children } = props;
  const {
    mapRef,
    activeCamera,
    cameras,
  } = data;
  const [
    prevCameraName,
    nextCameraName,
  ] = prevNextCamera(cameras, activeCamera);
  return (
    <Fragment>
      <div className="CameraConsole__left">
        {children}
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
            parent: config.window,
            type: 'map',
          }} />
      </div>
    </Fragment>
  );
};

export class CameraConsole extends Component {
  constructor() {
    super();
    this.state = {
      searchTerm: '',
    };
  }

  render() {
    const { props } = this;
    const { act, data } = useBackend(props);
    const { searchTerm } = this.state;
    const {
      activeCamera,
      network,
    } = data;
    const cameras = data.cameras
      .filter(camera => (
        camera.name?.toLowerCase()
          .includes(searchTerm.toLowerCase())
      ));
    return (
      <Fragment>
        <Input
          fluid
          mb={1}
          placeholder="Search for a camera"
          onInput={(e, value) => this.setState({
            searchTerm: value,
          })} />
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
              onClick={() => {
                refocusLayout();
                act('switch_camera', {
                  name: camera.name,
                });
              }}>
              {camera.name}
            </div>
          ))}
        </Section>
      </Fragment>
    );
  }
}
