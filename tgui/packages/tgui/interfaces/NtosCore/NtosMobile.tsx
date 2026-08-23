/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { getRoutedComponent } from 'tgui/routes';
import { Box, Button } from 'tgui-core/components';
import { Window } from '../../layouts';
import { NtosHeader, NtosHeaderIcon } from './NtosHeader';
import { useNtos } from './ntos';

export const NtosCoreMobile = (props) => {
  const { system, api } = useNtos(props);
  const {
    device_theme,
    battery_icon,
    battery_percent,
    ntnet_icon,
    station_date,
    station_time,
    program_headers = [],
    is_lowpower_mode_on,
    programs = [],
  } = system;
  const { shutdown, minimize_program, exit_program } = api;

  const active_program = programs.find((program) => program.active);
  const component_id = active_program ? active_program.tgui_id : 'NtosMain';

  const Component = getRoutedComponent(component_id);

  return (
    <Window
      title={
        active_program
          ? active_program.desc
          : (device_theme === 'syndicate' && 'Syndix Main Menu') ||
            'NtOS Main Menu'
      }
      width={400}
      height={500}
      theme={device_theme}
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
                  tooltip={station_date}
                  color="transparent"
                  icon="calendar"
                  tooltipPosition="bottom"
                />
                {station_time}
              </Box>
              <Box inline italic mr={2} opacity={0.33}>
                {(device_theme === 'syndicate' && 'Syndix') || 'NtOS'}
                {is_lowpower_mode_on && ' - RUNNING ON LOW POWER MODE'}
              </Box>
            </>
          }
          right={
            <>
              {program_headers.map((header) => (
                <NtosHeaderIcon key={header.icon} name={header.icon} mr={1} />
              ))}
              <NtosHeaderIcon name={ntnet_icon} />
              {battery_icon && (
                <NtosHeaderIcon name={battery_icon} mr={1}>
                  {battery_percent}
                </NtosHeaderIcon>
              )}
            </>
          }
          buttons={
            <>
              {active_program && (
                <Button
                  color="transparent"
                  icon="window-minimize-o"
                  tooltip="Minimize"
                  tooltipPosition="bottom"
                  onClick={() => minimize_program(active_program.name)}
                />
              )}
              {active_program && (
                <Button
                  color="transparent"
                  icon="window-close-o"
                  tooltip="Close"
                  tooltipPosition="bottom-start"
                  onClick={() => exit_program(active_program.name)}
                />
              )}
              {!active_program && (
                <Button
                  textAlign="center"
                  color="transparent"
                  icon="power-off"
                  tooltip="Power off"
                  tooltipPosition="bottom-start"
                  onClick={() => shutdown()}
                />
              )}
            </>
          }
        />
        <Component tgui_id={component_id} />
      </div>
    </Window>
  );
};
