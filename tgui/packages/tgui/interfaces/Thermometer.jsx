import { Component } from 'react';
import { Box, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export class Thermometer extends Component {
  componentDidMount() {
    Byond.winset(Byond.windowId, {
      'transparent-color': '#242322',
    });
  }

  componentWillUnmount() {
    Byond.winset(Byond.windowId, {
      'transparent-color': null,
    });
  }

  render() {
    const { act, data } = useBackend();
    return (
      <Window width={70} height={430}>
        <Stack
          fill
          align="center"
          justify="space-around"
          backgroundColor="#242322"
          style={{
            backgroundImage:
              "url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAIAAAACAQMAAABIeJ9nAAAABlBMVEVya3UjIyN3S/1dAAAAAXRSTlMAQObYZgAAAAFiS0dEAIgFHUgAAAAMSURBVAjXY2hgcAAAAcQAwUlFKkkAAAAASUVORK5CYII=')",
          }}
        >
          <Stack.Item ml={1}>
            <ThermometerIcon
              temperature={data.Temperature}
              maxTemperature={1000}
            />
          </Stack.Item>
        </Stack>
      </Window>
    );
  }
}

const ThermometerIcon = (props) => {
  const { temperature, maxTemperature } = props;
  return (
    <Box>
      <Box
        style={{
          position: 'relative',
          width: '22px',
          height: '340px',
          margin: '0 auto',
          backgroundColor: '#595959',
          border: '4px solid #363636',
          borderRadius: '12px',
          borderBottom: 'none',
          borderIndex: '0',
          boxShadow: '4px 4px #000000',
        }}
      >
        <Box
          style={{
            position: 'absolute',
            width: '5x',
            bottom: 0,
            left: '0px',
            right: 0,
            transition: 'height 2s ease-out',
            // Temp in %
            height: `${(temperature / maxTemperature) * 100}%`,
            backgroundColor: '#bd2020',
            borderRadius: '8px',
            borderBottom: 'none',
            zIndex: '1',
          }}
        />
      </Box>
      <Box
        style={{
          position: 'relative',
          width: '56px',
          lineHeight: '48px',
          textAlign: 'center',
          margin: '-8px auto 0 auto',
          backgroundColor: '#bd2020',
          border: '4px solid #363636',
          borderSpacing: '5px',
          borderRadius: '35px',
          borderIndex: '1',
          borderBottom: '0.1',
          boxShadow: '4px 4px #000000',
          zIndex: '0',
        }}
      >
        {temperature}K
      </Box>
    </Box>
  );
};
