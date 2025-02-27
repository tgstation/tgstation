// THIS IS A NOVA SECTOR UI FILE
import {
  BlockQuote,
  Box,
  Button,
  Collapsible,
  Divider,
  Flex,
  LabeledList,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const SoulcatcherUser = (props) => {
  const { act, data } = useBackend();
  const { current_room, user_data, communicate_as_parent, souls = [] } = data;

  return (
    <Window width={520} height={400} resizable>
      <Window.Content scrollable>
        <Section
          key={current_room.key}
          title={
            <span style={{ color: current_room.color }}>
              {current_room.name}
            </span>
          }
        >
          <BlockQuote preserveWhitespace>
            {' '}
            {current_room.description}
          </BlockQuote>
          <br />
          <Box textAlign="center" fontSize="15px" opacity={0.8}>
            <b>{user_data.name} </b>
            {!user_data.scan_needed && user_data.able_to_rename ? (
              <>
                <Button
                  color="green"
                  icon="pen"
                  tooltip="Change your name."
                  onClick={() => act('change_name', {})}
                />
                <Button
                  color="red"
                  icon="arrow-rotate-left"
                  tooltip="Reset your name."
                  onClick={() => act('reset_name', {})}
                />
              </>
            ) : (
              <> </>
            )}
            {communicate_as_parent ? (
              <Button
                color={user_data.communicating_externally ? 'green' : 'red'}
                icon={
                  user_data.communicating_externally ? 'bullhorn' : 'microphone'
                }
                tooltip="Toggle sending messages as part of the soulcatcher."
                onClick={() => act('toggle_external_communication', {})}
              />
            ) : (
              <> </>
            )}
          </Box>
          <Divider />
          <Collapsible title="Flavor Text">
            <BlockQuote preserveWhitespace>{user_data.description}</BlockQuote>
          </Collapsible>
          <Collapsible title="OOC Notes">
            <BlockQuote preserveWhitespace>{user_data.ooc_notes}</BlockQuote>
          </Collapsible>
          <Collapsible title="Soul Info">
            <LabeledList textAlign>
              <LabeledList.Item label="Ability to see outside">
                {user_data.outside_sight ? 'Enabled' : 'Disabled'}
              </LabeledList.Item>
              <LabeledList.Item label="Ability to hear outside">
                {user_data.outside_hearing ? 'Enabled' : 'Disabled'}
              </LabeledList.Item>
              <LabeledList.Item label="Ability to see inside">
                {user_data.internal_sight ? 'Enabled' : 'Disabled'}
              </LabeledList.Item>
              <LabeledList.Item label="Ability to hear inside">
                {user_data.internal_hearing ? 'Enabled' : 'Disabled'}
              </LabeledList.Item>
              <LabeledList.Item label="Ability to speak">
                {user_data.able_to_speak ? 'Enabled' : 'Disabled'}
              </LabeledList.Item>
              <LabeledList.Item label="Ability to emote">
                {user_data.able_to_emote ? 'Enabled' : 'Disabled'}
              </LabeledList.Item>
              {communicate_as_parent ? (
                <>
                  <LabeledList.Item label="Ability to speak as container">
                    {user_data.able_to_speak_as_container
                      ? 'Enabled'
                      : 'Disabled'}
                  </LabeledList.Item>
                  <LabeledList.Item label="Ability to emote as container">
                    {user_data.able_to_emote_as_container
                      ? 'Enabled'
                      : 'Disabled'}
                  </LabeledList.Item>
                </>
              ) : (
                <> </>
              )}
              <LabeledList.Item label="Ability to change name">
                {user_data.able_to_rename && !user_data.scan_needed
                  ? 'Enabled'
                  : 'Disabled'}
              </LabeledList.Item>
              <LabeledList.Item label="Body Scan Needed">
                {user_data.scan_needed ? 'True' : 'False'}
              </LabeledList.Item>
            </LabeledList>
          </Collapsible>

          {souls && user_data.internal_sight ? (
            <>
              <br />
              <Box textAlign="center" fontSize="15px" opacity={0.8}>
                <b>Souls</b>
              </Box>
              <Divider />
              <Flex direction="column">
                {souls.map((soul) => (
                  <Flex.Item key={soul.key}>
                    <Collapsible title={soul.name}>
                      <Box textAlign="center" fontSize="13px" opacity={0.8}>
                        <b>Flavor Text</b>
                      </Box>
                      <Divider />
                      <BlockQuote preserveWhitespace>
                        {soul.description}
                      </BlockQuote>
                      <br />
                      <Box textAlign="center" fontSize="13px" opacity={0.8}>
                        <b>OOC Notes</b>
                      </Box>
                      <Divider />
                      <BlockQuote preserveWhitespace>
                        {soul.ooc_notes}
                      </BlockQuote>
                    </Collapsible>
                  </Flex.Item>
                ))}
              </Flex>
            </>
          ) : (
            <> </>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
