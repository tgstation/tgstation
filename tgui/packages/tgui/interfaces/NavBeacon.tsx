import { BooleanLike } from 'common/react';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  Dropdown,
  LabeledList,
  Section,
  Stack,
} from '../components';
import { Window } from '../layouts';
import { InterfaceLockNoticeBox } from './common/InterfaceLockNoticeBox';

export type Data = {
  locked: BooleanLike;
  siliconUser: BooleanLike;
  controls: NavBeaconControl;
  static_controls: NavBeaconStaticControl;
};

export type NavBeaconControl = {
  location: string;
  patrol_enabled: BooleanLike;
  patrol_next: string;
  delivery_enabled: BooleanLike;
  delivery_direction: string;
  cover_locked: BooleanLike;
};

export type DisabledProps = {
  disabled: BooleanLike;
};

export type NavBeaconStaticControl = {
  direction_options: string[];
  has_codes: BooleanLike;
};

export const NavBeacon = (props) => {
  const { act, data } = useBackend();
  return (
    <Window title="Nagivational Beacon" width={400} height={350}>
      <Window.Content>
        <NavBeaconContent />
      </Window.Content>
    </Window>
  );
};

export const NavBeaconContent = (props) => {
  const { act, data } = useBackend<Data>();
  const { controls, static_controls } = data;
  const disabled = data.locked && !data.siliconUser;
  return (
    <Stack vertical fill>
      <InterfaceLockNoticeBox />
      <NavBeaconControlSection disabled={disabled} />
      <NavBeaconMaintenanceSection disabled={disabled} />
    </Stack>
  );
};

export const NavBeaconControlSection = (props: DisabledProps) => {
  const { act, data } = useBackend<Data>();
  const { controls, static_controls } = data;
  return (
    <Section title="Controls">
      <LabeledList>
        <LabeledList.Item label="Location">
          <Button
            fluid
            content={controls.location ?? 'None set'}
            icon="pencil-alt"
            disabled={props.disabled}
            onClick={() => act('set_location')}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Enable as Patrol Beacon">
          <Button.Checkbox
            fluid
            checked={controls.patrol_enabled}
            content={controls.patrol_enabled ? 'Enabled' : 'Disabled'}
            disabled={props.disabled}
            onClick={() => act('toggle_patrol')}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Next patrol">
          <Button
            fluid
            content={controls.patrol_next ?? 'No next patrol location'}
            icon="pencil-alt"
            disabled={props.disabled}
            onClick={() => act('set_patrol_next')}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Enable as Delivery Beacon">
          <Button.Checkbox
            fluid
            checked={controls.delivery_enabled}
            content={controls.delivery_enabled ? 'Enabled' : 'Disabled'}
            disabled={props.disabled}
            onClick={() => act('toggle_delivery')}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Delivery Direction">
          <Dropdown
            disabled={!!props.disabled}
            options={static_controls.direction_options}
            selected={controls.delivery_direction}
            onSelected={(value) =>
              act('set_delivery_direction', {
                direction: value,
              })
            }
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

export const NavBeaconMaintenanceSection = (props: DisabledProps) => {
  const { act, data } = useBackend<Data>();
  const { controls, static_controls } = data;
  return (
    <Section title="Maintenance">
      <LabeledList>
        <LabeledList.Item label="Reset codes">
          {!!static_controls.has_codes && (
            <Button
              fluid
              content={'Reset'}
              icon="power-off"
              disabled={props.disabled}
              onClick={() => act('reset_codes')}
            />
          )}
          {!static_controls.has_codes && <Box>No backup codes found</Box>}
        </LabeledList.Item>
        <LabeledList.Item label="Maintenance hatch cover">
          <Button.Checkbox
            fluid
            checked={controls.cover_locked}
            content={controls.cover_locked ? 'Locked' : 'Unlocked'}
            disabled={props.disabled}
            onClick={() => act('toggle_cover')}
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
