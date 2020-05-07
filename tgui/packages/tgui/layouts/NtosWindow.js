/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { useBackend } from '../backend';
import { Box, Button } from '../components';
import { refocusLayout } from './Layout';
import { Window } from './Window';

export const NtosWindow = (props, context) => {
  const {
    resizable,
    theme = 'ntos',
    children,
  } = props;
  const { act, data } = useBackend(context);
  const {
    PC_batteryicon,
    PC_showbatteryicon,
    PC_batterypercent,
    PC_ntneticon,
    PC_apclinkicon,
    PC_stationtime,
    PC_programheaders = [],
    PC_showexitprogram,
  } = data;
  return (
    <Window
      theme={theme}
      resizable={resizable}>
      <div className="NtosWindow">
        <div
          className="NtosWindow__header NtosHeader"
          onMouseDown={() => {
            refocusLayout();
          }}>
          <div className="NtosHeader__left">
            <Box inline bold mr={2}>
              {PC_stationtime}
            </Box>
            <Box inline italic mr={2} opacity={0.33}>
              NtOS
            </Box>
          </div>
          <div className="NtosHeader__right">
            {PC_programheaders.map(header => (
              <Box key={header.icon} inline mr={1}>
                <img
                  className="NtosHeader__icon"
                  src={header.icon} />
              </Box>
            ))}
            <Box inline>
              {PC_ntneticon && (
                <img
                  className="NtosHeader__icon"
                  src={PC_ntneticon} />
              )}
            </Box>
            {!!PC_showbatteryicon && PC_batteryicon && (
              <Box inline mr={1}>
                {PC_batteryicon && (
                  <img
                    className="NtosHeader__icon"
                    src={PC_batteryicon} />
                )}
                {PC_batterypercent && (
                  PC_batterypercent
                )}
              </Box>
            )}
            {PC_apclinkicon && (
              <Box inline mr={1}>
                <img
                  className="NtosHeader__icon"
                  src={PC_apclinkicon} />
              </Box>
            )}
            {!!PC_showexitprogram && (
              <Button
                width="26px"
                lineHeight="22px"
                textAlign="center"
                color="transparent"
                icon="window-minimize-o"
                tooltip="Minimize"
                tooltipPosition="bottom"
                onClick={() => act('PC_minimize')} />
            )}
            {!!PC_showexitprogram && (
              <Button
                mr="-3px"
                width="26px"
                lineHeight="22px"
                textAlign="center"
                color="transparent"
                icon="window-close-o"
                tooltip="Close"
                tooltipPosition="bottom-left"
                onClick={() => act('PC_exit')} />
            )}
            {!PC_showexitprogram && (
              <Button
                mr="-3px"
                width="26px"
                lineHeight="22px"
                textAlign="center"
                color="transparent"
                icon="power-off"
                tooltip="Power off"
                tooltipPosition="bottom-left"
                onClick={() => act('PC_shutdown')} />
            )}
          </div>
        </div>
        {children}
      </div>
    </Window>
  );
};

const NtosWindowContent = props => {
  return (
    <div className="NtosWindow__content">
      <Window.Content {...props} />
    </div>
  );
};

NtosWindow.Content = NtosWindowContent;
