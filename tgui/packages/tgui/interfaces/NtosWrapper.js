import { useBackend } from '../backend';
import { Box, Button } from '../components';
import { refocusLayout } from '../refocus';

export const NtosWrapper = props => {
  const { children } = props;
  const { act, data } = useBackend(props);
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
    <div className="NtosWrapper">
      <div
        className="NtosWrapper__header NtosHeader"
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
      <div className="NtosWrapper__content">
        {children}
      </div>
    </div>
  );
};
