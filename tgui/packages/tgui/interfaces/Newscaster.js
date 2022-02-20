/**
 * @file
 * @author Original by ArcaneMusic (https://github.com/ArcaneMusic)
 * @license MIT
 */

import { useBackend, useSharedState } from '../backend';
import { BountyBoardContent } from './BountyBoard';
import { BlockQuote, Box, Button, Divider, Flex, Icon, LabeledList, NoticeBox, Section, Stack, Tabs } from '../components';
import { Window } from '../layouts';
import { marked } from 'marked';
import { sanitizeText } from "../sanitize";

export const Newscaster = (props, context) => {
  const { act, data } = useBackend(context);
  const [screenmode, setScreenmode] = useSharedState(context, 'tab_main', 1);
  return (
    <Window
      width={575}
      height={550}>
      <Window.Content scrollable>
        <Tabs fluid textAlign="center">
          <Tabs.Tab
            color="Green"
            selected={screenmode === 1}
            onClick={() => setScreenmode(1)}>
            Newscaster
          </Tabs.Tab>
          <Tabs.Tab
            Color="Blue"
            selected={screenmode === 2}
            onClick={() => setScreenmode(2)}>
            Bounty Board
          </Tabs.Tab>
        </Tabs>
        {screenmode === 1 && (
          <NewscasterContent />
        )}
        {screenmode === 2 && (
          <BountyBoardContent />
        )}
      </Window.Content>
    </Window>
  );
};

export const NewscasterContent = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    current_channel = [],
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
    channelCensored,
    viewing_channel,
    security_mode,
    photo_data,
    paper,
    user,
  } = data;
  return (
    <Section title={channelName} >
      {channelCensored === 1 && (
        <Section>
          <BlockQuote color="Red">
            <b>ATTENTION:</b> This channel has been deemed as threatening to
            the welfare of the station, and marked with a Nanotrasen D-Notice.
          </BlockQuote>
        </Section>
      )}
      {channelCensored !== 1 &&(
        <Box>
          <BlockQuote italic mb={1} ml={1} fontSize={1.2}>
            {channelDesc}
          </BlockQuote>
          <LabeledList mt={1} mb={1}>
            <LabeledList.Item label="Owner">
              {channelAuthor}
            </LabeledList.Item>
          </LabeledList>
        </Box>
      )}
      <Box>
        <Button
          icon="print"
          content="Submit Story"
          disabled={(channelBlocked && (channelAuthor !== user.name))
            || channelCensored}
          onClick={() => act('createStory', { current: viewing_channel })}
          mt={1} />
        <Button
          icon="camera"
          selected={photo_data}
          content="Select Photo"
          disabled={(channelBlocked && (channelAuthor !== user.name))
            || channelCensored}
          onClick={() => act('togglePhoto')} />
        {security_mode === 1 && (
          <Button
            icon={"ban"}
            content={"D-Notice"}
            tooltip="Censor the whole channel and it's contents as dangerous to the station. Cannot be undone."
            disabled={!security_mode}
            onClick={() => act('channelDNotice',
              { secure: security_mode,
                channel: viewing_channel })} />
        )}
      </Box>
      <Box>
        <Button
          icon={"Newspaper"}
          content={"Print Newspaper"}
          disabled={paper <= 0}
          onClick={() => act('paper')} />
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
            icon={channels.censored ? 'ban' : null}
            textColor={channels.censored ? "Red" :"white"}
            onClick={() => act('setChannel', {
              channels: channels.ID,
            })}>
            {channels.name}
          </Tabs.Tab>
        ))}
        <Tabs.Tab
          pt={0.75}
          pb={0.75}
          mr={1}
          textColor="white"
          onClick={() => act('createChannel')}>
          Create Channel[+]
        </Tabs.Tab>
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
    channelCensored,
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
                {message.censored_author === 1 && (
                  <Box textColor="Red">
                    By: [REDACTED]. <b>D-Notice Notice</b> .
                  </Box>
                )}
                {message.censored_author !== 1 && (
                  <>
                    By: {message.auth} at {message.time}
                  </>
                )}
              </i>
            )}
            buttons={(
              <>
                {security_mode === 1 && (
                  <Button
                    icon={"comment-slash"}
                    tooltip={"Censor Story"}
                    disabled={!security_mode}
                    onClick={() => act('storyCensor', {
                      secure: security_mode,
                      messageID: message.ID })} />
                )}
                {security_mode === 1 && (
                  <Button
                    icon={'user-slash'}
                    tooltip={"Censor Author"}
                    disabled={!security_mode}
                    onClick={() => act('authorCensor', {
                      secure: security_mode,
                      messageID: message.ID })} />
                )}
              </>
            )} >
            <BlockQuote
              textColor="white">
              {message.censored_message === 1 &&(
                <Section textColor="Red">
                  This message was deemed dangerous to the general welfare
                  of the station and therefore marked with a <b>D-Notice</b>.
                </Section>
              )}
              {message.censored_message !== 1 &&(
                <Section
                  color="label"
                  dangerouslySetInnerHTML={processedText(message.body)}
                  pl={1} />
              )}
              {message.photo !== null && message.censored_message !== 1 &&(
                <Box
                  as="img"
                  src={message.Photo} />
              )}
            </BlockQuote>
            <Divider />
          </Section>
        ); }
      )}
    </Section>
  );
};
