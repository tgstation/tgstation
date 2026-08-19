/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { getRoutedComponent } from 'tgui/routes';
import { Box, Button } from 'tgui-core/components';
import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import type { NTOSData } from '../../layouts/NtosWindow';
import { NtosHeader, NtosHeaderIcon } from './NtosHeader';

export const NtosCoreMobile = (props) => {
  const { act, data } = useBackend<NTOSData>();
  const {
    PC_device_theme,
    PC_batteryicon,
    PC_batterypercent,
    PC_ntneticon,
    PC_stationdate,
    PC_stationtime,
    PC_programheaders = [],
    PC_showexitprogram,
    PC_lowpower_mode,
    programs,
  } = data;

  const active_program = programs.find((program) => program.active);
  const Component = getRoutedComponent(
    active_program ? active_program.tgui_id : 'NtosMain',
  );

  return (
    <Window
      title={
        active_program
          ? active_program.desc
          : (PC_device_theme === 'syndicate' && 'Syndix Main Menu') ||
            'NtOS Main Menu'
      }
      width={400}
      height={500}
      theme={PC_device_theme}
    >
      <div>
        <NtosHeader
          left={
            <>
              <Box inline bold mr={2}>
                <Button
                  width="26px"
                  lineHeight="22px"
                  textAlign="left"
                  tooltip={PC_stationdate}
                  color="transparent"
                  icon="calendar"
                  tooltipPosition="bottom"
                />
                {PC_stationtime}
              </Box>
              <Box inline italic mr={2} opacity={0.33}>
                {(PC_device_theme === 'syndicate' && 'Syndix') || 'NtOS'}
                {!!PC_lowpower_mode && ' - RUNNING ON LOW POWER MODE'}
              </Box>
            </>
          }
          right={
            <>
              {PC_programheaders.map((header) => (
                <NtosHeaderIcon key={header.icon} name={header.icon} mr={1} />
              ))}
              <NtosHeaderIcon name={PC_ntneticon} />
              {!!PC_batteryicon && (
                <NtosHeaderIcon name={PC_batteryicon} mr={1}>
                  {PC_batterypercent}
                </NtosHeaderIcon>
              )}
            </>
          }
          buttons={
            <>
              {!!PC_showexitprogram && (
                <Button
                  color="transparent"
                  icon="window-minimize-o"
                  tooltip="Minimize"
                  tooltipPosition="bottom"
                  onClick={() => act('PC_minimize')}
                />
              )}
              {!!PC_showexitprogram && (
                <Button
                  color="transparent"
                  icon="window-close-o"
                  tooltip="Close"
                  tooltipPosition="bottom-start"
                  onClick={() => act('PC_exit')}
                />
              )}
              {!PC_showexitprogram && (
                <Button
                  textAlign="center"
                  color="transparent"
                  icon="power-off"
                  tooltip="Power off"
                  tooltipPosition="bottom-start"
                  onClick={() => act('PC_shutdown')}
                />
              )}
            </>
          }
        />
        <Component />
      </div>
    </Window>
  );
};
