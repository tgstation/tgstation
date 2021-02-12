import { useBackend } from '../backend';
import { Stack } from '../components';
import { Window } from '../layouts';
import { ThermometerIcon } from './common/ThermometerIcon';
import { Component } from 'inferno';

export class Thermometer extends Component {
  componentDidMount() {
    Byond.winset(window.__windowId__, {
      'transparent-color': '#242322',
    });
  }
  
  componentWillUnmount() {
    Byond.winset(window.__windowId__, {
      'transparent-color': null,
    });
  }
  
  render() {
    const { act, data } = useBackend(this.context);
    return (
      <Window
        width={70}
        height={430}
        key="Thermometer">
        <Stack
          fill
          align="center"
          justify="space-around"
          backgroundColor="#242322"
          style={{
            'background-image': "url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAIAAAACAQMAAABIeJ9nAAAABlBMVEVya3UjIyN3S/1dAAAAAXRSTlMAQObYZgAAAAFiS0dEAIgFHUgAAAAMSURBVAjXY2hgcAAAAcQAwUlFKkkAAAAASUVORK5CYII=')",
          }} >
          <Stack.Item ml={1}>
            <ThermometerIcon
              temperature={data.Temperature}
              maxTemperature={1000} />
          </Stack.Item>
        </Stack>
      </Window>
    );
  }
} 