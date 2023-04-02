import { useBackend } from '../backend';
import { Box, Button, Section, Stack } from '../components';
import { Window } from '../layouts';

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
  } = data;
  return (
    <Window title="Nagivational Beacon" width={300} height={400}>
      <Window.Content>
        <Stack vertical fill>
          <NoticeBox>
            Swipe an ID card to {locked ? 'unlock' : 'lock'} this interface.
          </NoticeBox>
          <Section>
            Location:
            <Button
              content={location ?? 'None set'}
              icon="pencil-alt"
              disabled={locked && !silicon_user}
              onClick={() => act('change_location')}
            />
          </Section>
          <Button.Checkbox
            fluid
            checked={patrol_enabled}
            content="Enable as Patrol Beacon"
            disabled={locked && !silicon_user}
            onClick={() => act('toggle_patrol')}
          />
          <Section>
            Next patrol:
            <Button
              content={patrol_next ?? 'No next patrol location'}
              icon="pencil-alt"
              disabled={locked && !silicon_user}
              onClick={() => act('change_patrol_next')}
            />
          </Section>
          <Button.Checkbox
            fluid
            checked={delivery_enabled}
            content="Enable as Delivery Beacon"
            disabled={locked && !silicon_user}
            onClick={() => act('toggle_delivery')}
          />
          <Section>
            Delivery Direction:
            <Button
              content={delivery_direction ?? 'No delivery direction'}
              icon="pencil-alt"
              disabled={locked && !silicon_user}
              onClick={() => act('change_delivery_direction')}
            />
          </Section>
        </Stack>
      </Window.Content>
    </Window>
  );
};
