import { useBackend } from '../backend';
import { Box, Button, Dropdown, Flex, Icon, LabeledList, Modal, Section } from '../components';
import { Window } from '../layouts';

export const ShuttleConsole = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    authorization_required,
  } = data;
  return (
    <Window
      width={350}
      height={230}>
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
              <Icon
                name="minus-circle" />
            </Flex.Item>
            <Flex.Item
              mt={2}
              ml={2}
              color="bad">
              {'SHUTTLE LOCKED'}
            </Flex.Item>
          </Flex>
          <Box
            fontSize="18px"
            mt={4}>
            <Button
              lineHeight="40px"
              icon="arrow-circle-right"
              content="Request Authorization"
              color="bad"
              onClick={() => act('request')} />
          </Box>
        </Modal>
      )}
      <Window.Content>
        <ShuttleConsoleContent />
      </Window.Content>
    </Window>
  );
};

const getLocationNameById = (locations, id) => {
  return locations?.find(location => location.id === id).name;
};

const getLocationIdByName = (locations, name) => {
  return locations?.find(location => location.name === name).id;
};

const ShuttleConsoleContent = (props, context) => {
  const { act, data } = useBackend(context);
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
      <Box
        bold
        fontSize="26px"
        textAlign="center"
        fontFamily="monospace">
        {timer_str || "00:00"}
      </Box>
      <Box
        textAlign="center"
        fontSize="14px"
        mb={1}>
        <Box
          inline
          bold>
          STATUS:
        </Box>
        <Box
          inline
          color={status==="In Transit"
            ? 'good'
            : status==="Idle"
              ? 'average'
              : status==="Igniting"
                ? 'average'
                : 'bad'}
          ml={1}>
          {status || "Not Available"}
        </Box>
      </Box>
      <Section
        title="Shuttle Controls"
        level={2}>
        <LabeledList>
          <LabeledList.Item label="Location">
            {docked_location || "Not Available"}
          </LabeledList.Item>
          <LabeledList.Item label="Destination">
            {locations.length===0 && (
              <Box color="bad">
                Not Available
              </Box>
            ) || locations.length===1 &&(
              <Box color="average">
                {getLocationNameById(locations, destination)}
              </Box>
            ) || (
              <Dropdown
                over
                width="240px"
                options={locations.map(location => location.name)}
                disabled={locked || authorization_required}
                selected={destination ? getLocationNameById(locations, destination) : "Select a Destination"}
                onSelected={value => act('set_destination', {
                  destination: getLocationIdByName(locations, value),
                })} />)}
          </LabeledList.Item>
        </LabeledList>
        <Button
          fluid
          content="Depart"
          disabled={locked || authorization_required || !destination}
          mt={1.5}
          icon="arrow-up"
          textAlign="center"
          onClick={() => act('move', {
            shuttle_id: destination,
          })} />
      </Section>
    </Section>
  );
};
