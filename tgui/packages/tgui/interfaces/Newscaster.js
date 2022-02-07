import { useBackend } from '../backend';
import { BlockQuote, Box, Button, Flex, Icon, LabeledList, NoticeBox, Section, Stack, Tabs } from '../components';
import { Window } from '../layouts';

export const Newscaster = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    index,
    name,
    description,
    icon,
    viewing_channel,
    current_channel = [],
  } = data;
  return (
    <Window
      width={575}
      height={420}>
      <Window.Content scrollable>
        <Flex mb={1}>
          <Flex.Item mr={1}>
            <NewscasterChannelSelector />
          </Flex.Item>
          <Flex.Item grow={1} basis={0}>
            <NewscasterInfobox />
            <NewscasterChannelBox
              channelName={current_channel.name}
              channelOwner={current_channel.owner}
              channelDesc={current_channel.desc} />
          </Flex.Item>
        </Flex>
        <Section p={1}>
          <NewscasterChannelComments />
        </Section>
      </Window.Content>
    </Window>
  );
};

/** The Infobox is the user information panel in the top right. */
const NewscasterInfobox = (props, context) => {
  const { data } = useBackend(context);
  const { user } = data;

  if (!user) {
    return (
      <NoticeBox>No ID detected! Contact the Head of Personnel.</NoticeBox>
    );
  } else {
    return (
      <Section>
        <Stack>
          <Stack.Item>
            <Icon name="id-card" size={3} mr={1} />
          </Stack.Item>
          <Stack.Item>
            <LabeledList>
              <LabeledList.Item label="User">{user.name}</LabeledList.Item>
              <LabeledList.Item label="Occupation">
                {user.job || 'Unemployed'}
              </LabeledList.Item>
            </LabeledList>
          </Stack.Item>
        </Stack>
      </Section>
    );
  }
};

/** The Channel Box is the basic channel information where buttons live.*/
const NewscasterChannelBox = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    channelName,
    channelOwner,
    channelDesc,
  } = data;
  return (
    <Section title={channelName} >
      <BlockQuote italic mb={1} ml={1} fontSize={1.2}>
        {channelDesc}
      </BlockQuote>
      <LabeledList mt={1} mb={1}>
        <LabeledList.Item label="Owner">
          {channelOwner}
        </LabeledList.Item>
      </LabeledList>
      <Box>
        <Button
          icon="print"
          content="Submit Story"
          onClick={() => act('createStory')}
          mt={1} />
      </Box>
    </Section>
  );
};

/** Channel select is the left-hand menu where all the channels are listed. */
const NewscasterChannelSelector = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    channel = [],
    viewing_channel,
  } = data;
  return (
    <Section
      minHeight="100%"
      width={(window.innerWidth - 410) + "px"}>
      <Tabs vertical>
        {channel?.map(channels => (
          <Tabs.Tab
            key={channels.name}
            pt={0.75}
            pb={0.75}
            mr={1}
            selected={viewing_channel === channels.ID}
            textColor="white"
            onClick={() => act('setChannel', {
              channels: channels,
            })}>
            {channels.name}
          </Tabs.Tab>
        ))}
      </Tabs>
    </Section>
  );
};

/** This is where the channels comments get spangled out (tm) */
const NewscasterChannelComments = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    messages,
    viewing_channel,
  } = data;
  return (
    <Section>
      {messages?.map(message => {
        if (message.channel_num === viewing_channel) {
          return;
        }
        return (
          <BlockQuote key={message.body}>
            {message.body}
            <Box
              pl={2.5}
              italic>
              by: {message.auth}
            </Box>
          </BlockQuote>
        ); }
      )}
    </Section>
  );
};
