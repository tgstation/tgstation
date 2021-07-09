import { Component } from 'inferno';
import { useBackend } from '../backend';
import { Box, Stack } from '../components';
import { Window } from '../layouts';

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
        height={430}>
        <Stack
          fill
          align="center"
          justify="space-around"
          backgroundColor="#242322"
          style={{
            'background-image': "url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAIAAAACAQMAAABIeJ9nAAAABlBMVEVya3UjIyN3S/1dAAAAAXRSTlMAQObYZgAAAAFiS0dEAIgFHUgAAAAMSURBVAjXY2hgcAAAAcQAwUlFKkkAAAAASUVORK5CYII=')",
          }}>
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

const ThermometerIcon = props => {
  const { temperature, maxTemperature } = props;
  return (
    <Box>
      <Box
        style={{
          'position': 'relative',
          'width': '22px',
          'height': '340px',
          'margin': '0 auto',
          'background-color': '#595959',
          'border': '4px solid #363636',
          'border-radius': '12px',
          'border-bottom': 'none',
          'border-index': '0',
          'box-shadow': '4px 4px #000000',
        }}>
        <Box
          style={{
            'position': 'absolute',
            'width': '5x',
            'bottom': 0,
            'left': '0px',
            'right': 0,
            'transition': 'height 2s ease-out',
            // Temp in %
            'height': `${((temperature / maxTemperature)*100)}%`,
            'background-color': '#bd2020',
            'border-radius': '8px',
            'border-bottom': 'none',
            'z-index': '1',
          }} />
      </Box>
      <Box
        style={{
          'position': 'relative',
          'width': '56px',
          'line-height': '48px',
          'text-align': 'center',
          'margin': '-8px auto 0 auto',
          'background-color': '#bd2020',
          'border': '4px solid #363636',
          'border-spacing': '5px',
          'border-radius': '35px',
          'border-index': '1',
          'border-bottom': '0.1',
          'box-shadow': '4px 4px #000000',
          'z-index': '0',
        }}>
        {temperature}K
      </Box>
    </Box>
  );
};

