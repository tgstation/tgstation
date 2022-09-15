import { useBackend } from '../backend';
import { Box, Button, Dropdown, Flex, Icon, LabeledList, Modal, Section } from '../components';
import { Window } from '../layouts';

export const ShuttleConsole = (props, context) => {
  const { act, data } = useBackend(context);
  const { type = 'shuttle', blind_drop } = props;
  const { authorization_required } = data;
  return (
    <Window width={350} height={230}>
      {!!authorization_required && (
        <Modal
          ml={1}
          mt={1}
          width={26}
          height={12}
          fontSize="28px"
          fontFamily="monospace"
          textAlign="center">
          <Flex>
            <Flex.Item mt={2}>
              <Icon name="minus-circle" />
            </Flex.Item>
            <Flex.Item mt={2} ml={2} color="bad">
              {type === 'shuttle' ? 'SHUTTLE LOCKED' : 'BASE LOCKED'}
            </Flex.Item>
          </Flex>
          <Box fontSize="18px" mt={4}>
            <Button
              lineHeight="40px"
              icon="arrow-circle-right"
              content="Request Authorization"
              color="bad"
              onClick={() => act('request')}
            />
          </Box>
        </Modal>
      )}
      <Window.Content>
        <ShuttleConsoleContent type={type} blind_drop={blind_drop} />
      </Window.Content>
    </Window>
  );
};

const getLocationNameById = (locations, id) => {
  return locations?.find((location) => location.id === id)?.name;
};

const getLocationIdByName = (locations, name) => {
  return locations?.find((location) => location.name === name)?.id;
};

const STATUS_COLOR_KEYS = {
  'In Transit': 'good',
  'Idle': 'average',
  'Igniting': 'average',
  'Recharging': 'average',
  'Missing': 'bad',
  'Unauthorized Access': 'bad',
  'Locked': 'bad',
};

export const ShuttleConsoleContent = (props, context) => {
  const { act, data } = useBackend(context);
  const { type, blind_drop } = props;
  const {
    status,
    locked,
    authorization_required,
    destination,
    docked_location,
    timer_str,
    locations = [],
  } = data;
  return (
    <Section>
      <Box bold fontSize="26px" textAlign="center" fontFamily="monospace">
        {timer_str || '00:00'}
      </Box>
      <Box textAlign="center" fontSize="14px" mb={1}>
        <Box inline bold>
          STATUS:
        </Box>
        <Box inline color={STATUS_COLOR_KEYS[status] || 'bad'} ml={1}>
          {status || 'Not Available'}
        </Box>
      </Box>
      <Section
        title={type === 'shuttle' ? 'Shuttle Controls' : 'Base Launch Controls'}
        level={2}>
        <LabeledList>
          <LabeledList.Item label="Location">
            {docked_location || 'Not Available'}
          </LabeledList.Item>
          <LabeledList.Item
            label="Destination"
            buttons={
              type !== 'shuttle' &&
              locations.length === 0 &&
              !!blind_drop && (
                <Button
                  color="bad"
                  icon="exclamation-triangle"
                  disabled={authorization_required || !blind_drop}
                  content={'Blind Drop'}
                  onClick={() => act('random')}
                />
              )
            }>
            {(locations.length === 0 && (
              <Box mb={1.7} color="bad">
                Not Available
              </Box>
            )) ||
              (locations.length === 1 && (
                <Box mb={1.7} color="average">
                  {getLocationNameById(locations, destination)}
                </Box>
              )) || (
                <Dropdown
                  mb={1.7}
                  over
                  width="240px"
                  options={locations.map((location) => location.name)}
                  disabled={locked || authorization_required}
                  selected={
                    getLocationNameById(locations, destination) ||
                    'Select a Destination'
                  }
                  onSelected={(value) =>
                    act('set_destination', {
                      destination: getLocationIdByName(locations, value),
                    })
                  }
                />
              )}
          </LabeledList.Item>
        </LabeledList>
        <Button
          fluid
          content="Depart"
          disabled={
            !getLocationNameById(locations, destination) ||
            locked ||
            authorization_required
          }
          icon="arrow-up"
          textAlign="center"
          onClick={() =>
            act('move', {
              shuttle_id: destination,
            })
          }
        />
      </Section>
    </Section>
  );
};
