import { useBackend } from '../backend';
import { Button, Dropdown, LabeledList, Section } from '../components';
import { Window } from '../layouts';
import { InterfaceLockNoticeBox } from './common/InterfaceLockNoticeBox';

export const NavBeacon = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    location,
    locked,
    silicon_user,
    patrol_enabled,
    patrol_next,
    delivery_enabled,
    delivery_direction,
    direction_options,
  } = data;
  return (
    <Window title="Nagivational Beacon" width={400} height={300}>
      <Window.Content>
        <InterfaceLockNoticeBox />
        <Section title="Controls">
          <LabeledList>
            <LabeledList.Item label="Location">
              <Button
                content={location ?? 'None set'}
                icon="pencil-alt"
                disabled={locked && !silicon_user}
                onClick={() => act('set_location')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Enable as Patrol Beacon">
              <Button.Checkbox
                fluid
                checked={patrol_enabled}
                content={patrol_enabled ? 'Enabled' : 'Disabled'}
                disabled={locked && !silicon_user}
                onClick={() => act('toggle_patrol')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Next patrol">
              <Button
                content={patrol_next ?? 'No next patrol location'}
                icon="pencil-alt"
                disabled={locked && !silicon_user}
                onClick={() => act('set_patrol_next')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Enable as Delivery Beacon">
              <Button.Checkbox
                fluid
                checked={delivery_enabled}
                content={delivery_enabled ? 'Enabled' : 'Disabled'}
                disabled={locked && !silicon_user}
                onClick={() => act('toggle_delivery')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Delivery Direction">
              <Dropdown
                disabled={locked && !silicon_user}
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
      </Window.Content>
    </Window>
  );
};
