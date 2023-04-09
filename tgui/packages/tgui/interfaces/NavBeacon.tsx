import { useBackend } from '../backend';
import { Box, Button, Dropdown, LabeledList, Section } from '../components';
import { Window } from '../layouts';
import { InterfaceLockNoticeBox } from './common/InterfaceLockNoticeBox';
import { BooleanLike } from 'common/react';

export type Data = {
  locked: BooleanLike;
  siliconUser: BooleanLike;
  location: String;
  patrol_enabled: BooleanLike;
  patrol_next: String;
  delivery_enabled: BooleanLike;
  delivery_direction: String[];
  direction_options;
  has_codes;
  cover_locked: BooleanLike;
};

export const NavBeacon = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const {
    location,
    locked,
    siliconUser,
    patrol_enabled,
    patrol_next,
    delivery_enabled,
    delivery_direction,
    direction_options,
    has_codes,
    cover_locked,
  } = data;
  return (
    <Window title="Nagivational Beacon" width={400} height={350}>
      <Window.Content>
        <InterfaceLockNoticeBox />
        <Section title="Controls">
          <LabeledList>
            <LabeledList.Item label="Location">
              <Button
                fluid
                content={location ?? 'None set'}
                icon="pencil-alt"
                disabled={locked && !siliconUser}
                onClick={() => act('set_location')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Enable as Patrol Beacon">
              <Button.Checkbox
                fluid
                checked={patrol_enabled}
                content={patrol_enabled ? 'Enabled' : 'Disabled'}
                disabled={locked && !siliconUser}
                onClick={() => act('toggle_patrol')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Next patrol">
              <Button
                fluid
                content={patrol_next ?? 'No next patrol location'}
                icon="pencil-alt"
                disabled={locked && !siliconUser}
                onClick={() => act('set_patrol_next')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Enable as Delivery Beacon">
              <Button.Checkbox
                fluid
                checked={delivery_enabled}
                content={delivery_enabled ? 'Enabled' : 'Disabled'}
                disabled={locked && !siliconUser}
                onClick={() => act('toggle_delivery')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Delivery Direction">
              <Dropdown
                disabled={locked && !siliconUser}
                options={direction_options}
                displayText={delivery_direction || 'none'}
                onSelected={(value) =>
                  act('set_delivery_direction', {
                    direction: value,
                  })
                }
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Maintenance">
          <LabeledList>
            <LabeledList.Item label="Reset codes">
              {!!has_codes && (
                <Button
                  fluid
                  content={'Reset'}
                  icon="power-off"
                  disabled={locked && !siliconUser}
                  onClick={() => act('reset_codes')}
                />
              )}
              {!has_codes && <Box>No backup codes found</Box>}
            </LabeledList.Item>
            <LabeledList.Item label="Maintenance hatch cover">
              <Button.Checkbox
                fluid
                checked={cover_locked}
                content={cover_locked ? 'Locked' : 'Unlocked'}
                disabled={locked && !siliconUser}
                onClick={() => act('toggle_cover')}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
