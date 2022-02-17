/**
 * @file
 * @author Original by ArcaneMusic (https://github.com/ArcaneMusic)
 * @license MIT
 */

import { useBackend } from '../backend';
import { RequestKioskContent } from './RequestKiosk';
import { BlockQuote, Box, Button, Divider, Flex, Icon, LabeledList, NoticeBox, Section, Stack, Tabs } from '../components';
import { Window } from '../layouts';
import marked from 'marked';
import { sanitizeText } from "../sanitize";

export const Newscaster = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    screenmode,
  } = data;
  return (
    <Window
      width={575}
      height={420}>
      <Window.Content scrollable>
        <Tabs fluid textAlign="center">
          <Tabs.Tab
            color="Green"
            selected={screenmode == 1}
            onClick={() => setTab_main(1)}>
            Newscaster
          </Tabs.Tab>
          <Tabs.Tab
            color="Blue"
            selected={screenmode == 2}
            onClick={() => setTab_main(2)}>
            Bounty Board
          </Tabs.Tab>
          <Tabs.Tab
            color="Purple"
            selected={screenmode == 3}
            onClick={() => setTab_main(3)}>
            Station Mandates
          </Tabs.Tab>
        </Tabs>
        if (screenmode == 1) {
          <NewscasterContent />
        } else if (screenmode == 2) {
          <RequestKioskContent />
        } else {
          <Box>
            Not done yet :)
          </Box>
        }

      </Window.Content>
    </Window>
  );
};

export const NewscasterContent = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    index,
    name,
    description,
    icon,
    viewing_channel,
    current_channel = [],
    security_mode,
  } = data;
  return (
    <>
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
        <NewscasterChannelMessages />
      </Section>
    </>
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
    channelDesc,
    channelBlocked,
    channelAuthor,
    viewing_channel,
  } = data;
  return (
    <Section title={channelName} >
      <BlockQuote italic mb={1} ml={1} fontSize={1.2}>
        {channelDesc}
      </BlockQuote>
      <LabeledList mt={1} mb={1}>
        <LabeledList.Item label="Owner">
          {channelAuthor}
        </LabeledList.Item>
      </LabeledList>
      <Box>
        <Button
          icon="print"
          content="Submit Story"
          disabled={channelBlocked}
          onClick={() => act('createStory', { current: viewing_channel })}
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
              channels: channels.ID,
            })}>
            {channels.name}
          </Tabs.Tab>
        ))}
      </Tabs>
    </Section>
  );
};

const processedText = value => {
  const textHtml = {
    __html: sanitizeText(marked(value, {
      breaks: true,
      smartypants: true,
      smartLists: true,
      baseUrl: 'thisshouldbreakhttp',
    })),
  };
  return textHtml;
};


/** This is where the channels comments get spangled out (tm) */
const NewscasterChannelMessages = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    messages = [],
    viewing_channel,
    security_mode,
  } = data;
  return (
    <Section scrollable>
      {messages?.map(message => {
        if (message.channel_num !== viewing_channel) {
          return;
        }
        return (
          <Section
            key={message.body}
            title={(
              <i>
                By: {message.auth} at {message.time}
              </i>
            )}
            buttons={(
              <>
                <Button
                  icon={"comment-slash"}
                  tooltip={"Censor Story"}
                  disabled={!security_mode}
                  onClick={() => act('storyCensor', { secure: security_mode })} />
                <Button
                  icon={'user-slash'}
                  tooltip={"Censor Author"}
                  disabled={!security_mode}
                  onClick={() => act('authorCensor', { secure: security_mode })} />
              </>
            )} >
            <BlockQuote
              textColor="white">
              <Section
                color="label"
                dangerouslySetInnerHTML={processedText(message.body)}
                pl={1} />
            </BlockQuote>
            <Divider />
          </Section>
        ); }
      )}
    </Section>
  );
};
