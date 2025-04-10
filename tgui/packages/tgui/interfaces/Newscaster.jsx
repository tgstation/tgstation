/**
 * @file
 * @author Original by ArcaneMusic (https://github.com/ArcaneMusic)
 * @author Changes Shadowh4nD/jlsnow301
 * @license MIT
 */

import { useState } from 'react';
import {
  BlockQuote,
  Box,
  Button,
  Divider,
  Image,
  LabeledList,
  Modal,
  Section,
  Stack,
  Tabs,
  TextArea,
} from 'tgui-core/components';
import { decodeHtmlEntities } from 'tgui-core/string';

import { useBackend, useSharedState } from '../backend';
import { processedText } from '../process';
import { BountyBoardContent } from './BountyBoard';
import { LoadingScreen } from './common/LoadingScreen';
import { UserDetails } from './Vending';

const CENSOR_MESSAGE =
  'This channel has been deemed as threatening to \
  the welfare of the station, and marked with a Nanotrasen D-Notice.';

export const Newscaster = (props) => {
  const { act, data } = useBackend();
  const NEWSCASTER_SCREEN = 1;
  const BOUNTYBOARD_SCREEN = 2;
  const [screenmode, setScreenmode] = useSharedState(
    'tab_main',
    NEWSCASTER_SCREEN,
  );

  return (
    <>
      <NewscasterChannelCreation />
      <NewscasterCommentCreation />
      <Stack fill vertical>
        <NewscasterWantedScreen />
        <Stack.Item>
          <Tabs fluid textAlign="center">
            <Tabs.Tab
              color="Green"
              selected={screenmode === NEWSCASTER_SCREEN}
              onClick={() => setScreenmode(NEWSCASTER_SCREEN)}
            >
              Newscaster
            </Tabs.Tab>
            <Tabs.Tab
              Color="Blue"
              selected={screenmode === BOUNTYBOARD_SCREEN}
              onClick={() => setScreenmode(BOUNTYBOARD_SCREEN)}
            >
              Bounty Board
            </Tabs.Tab>
          </Tabs>
        </Stack.Item>
        <Stack.Item grow>
          {screenmode === NEWSCASTER_SCREEN && <NewscasterContent />}
          {screenmode === BOUNTYBOARD_SCREEN && <BountyBoardContent />}
        </Stack.Item>
      </Stack>
    </>
  );
};

/** The modal menu that contains the prompts to making new channels. */
const NewscasterChannelCreation = (props) => {
  const { act, data } = useBackend();
  const [lockedmode, setLockedmode] = useState(true);
  const [cross_sector, setcross_sector] = useState(false);
  const { creating_channel, awaiting_approval, name, desc } = data;

  if (awaiting_approval) {
    return <LoadingScreen label="Awaiting Central Command approval..." />;
  }

  if (!creating_channel) {
    return null;
  }

  return (
    <Modal textAlign="center" mr={1.5}>
      <Stack vertical>
        <>
          <Stack.Item>
            <Box pb={1}>
              Enter channel name here:
              <Button
                color="red"
                icon="times"
                position="relative"
                top="20%"
                left="15%"
                onClick={() => act('cancelCreation')}
              />
            </Box>
            <TextArea
              fluid
              height="40px"
              width="240px"
              backgroundColor="black"
              textColor="white"
              maxLength={42}
              onChange={(e, name) =>
                act('setChannelName', {
                  channeltext: name,
                })
              }
            >
              Channel Name
            </TextArea>
          </Stack.Item>
          <Stack.Item>
            <Box pb={1}>Enter channel description here:</Box>
            <TextArea
              fluid
              height="150px"
              width="240px"
              backgroundColor="black"
              textColor="white"
              maxLength={512}
              onChange={(e, desc) =>
                act('setChannelDesc', {
                  channeldesc: desc,
                })
              }
            >
              Channel Description
            </TextArea>
          </Stack.Item>
          <Stack.Item>
            <Section>
              Set Channel as Public or Private
              <Box pt={1}>
                <Button
                  selected={!lockedmode}
                  disabled={cross_sector}
                  onClick={() => setLockedmode(false)}
                >
                  Public
                </Button>
                <Button
                  selected={!!lockedmode}
                  disabled={cross_sector}
                  onClick={() => setLockedmode(true)}
                >
                  Private
                </Button>
              </Box>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Button.Checkbox
              fluid
              checked={cross_sector}
              onClick={() => {
                setcross_sector(!cross_sector);
                setLockedmode(true);
              }}
              tooltip="Cross-sector newscaster messaging will require Central Command approval for each article. Cross-sector channels are automatically locked."
              tooltipPosition="bottom-start"
            >
              Make cross-sector?
            </Button.Checkbox>
          </Stack.Item>
          <Stack.Item>
            <Box>
              <Button
                onClick={() =>
                  act('createChannel', {
                    cross_sector: cross_sector,
                    lockedmode: lockedmode,
                  })
                }
              >
                Submit Channel
              </Button>
            </Box>
          </Stack.Item>
        </>
      </Stack>
    </Modal>
  );
};

/** The modal menu that contains the prompts to making new comments. */
const NewscasterCommentCreation = (props) => {
  const { act, data } = useBackend();
  const { creating_comment, viewing_message } = data;
  if (!creating_comment) {
    return null;
  }
  return (
    <Modal textAlign="center" mr={1.5}>
      <Stack vertical>
        <Stack.Item>
          <Box pb={1}>
            Enter comment:
            <Button
              color="red"
              position="relative"
              icon="times"
              top="20%"
              left="25%"
              onClick={() => act('cancelCreation')}
            />
          </Box>
          <TextArea
            fluid
            height="120px"
            width="240px"
            backgroundColor="black"
            textColor="white"
            maxLength={512}
            onChange={(e, comment) =>
              act('setCommentBody', {
                commenttext: comment,
              })
            }
          >
            Channel Name
          </TextArea>
        </Stack.Item>
        <Stack.Item>
          <Box>
            <Button
              onClick={() =>
                act('createComment', {
                  messageID: viewing_message,
                })
              }
            >
              Submit Comment
            </Button>
          </Box>
        </Stack.Item>
      </Stack>
    </Modal>
  );
};

const NewscasterWantedScreen = (props) => {
  const { act, data } = useBackend();
  const {
    viewing_wanted,
    photo_data,
    security_mode,
    wanted = [],
    criminal_name,
    crime_description,
  } = data;
  if (!viewing_wanted) {
    return null;
  }
  return (
    <Modal textAlign="center" mr={1} width={25}>
      {wanted.map((activeWanted) => (
        <>
          <Stack vertical>
            <Stack.Item>
              <Box bold color="red">
                {activeWanted.active
                  ? 'Active Wanted Issue:'
                  : 'Dismissed Wanted Issue:'}
                <Button
                  color="red"
                  position="relative"
                  icon="times"
                  top="20%"
                  left="15%"
                  onClick={() => act('cancelCreation')}
                />
              </Box>
              {!!activeWanted.criminal && (
                <>
                  <Section>
                    <Box bold>{activeWanted.criminal}</Box>
                    <Box italic>{activeWanted.crime}</Box>
                  </Section>
                  <Image src={activeWanted.image ? activeWanted.image : null} />
                  <Box italic>
                    Posted by{' '}
                    {activeWanted.author ? activeWanted.author : 'N/A'}
                  </Box>
                </>
              )}
            </Stack.Item>
          </Stack>
          <Divider />
        </>
      ))}
      {security_mode ? (
        <>
          <LabeledList>
            <LabeledList.Item label="Criminal Name">
              <Button
                disabled={!security_mode}
                icon="pen"
                onClick={() => act('setCriminalName')}
              >
                {criminal_name ? criminal_name : ' N/A'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Criminal Activity">
              <Button
                nowrap={false}
                disabled={!security_mode}
                icon="pen"
                onClick={() => act('setCrimeData')}
              >
                {crime_description ? crime_description : ' N/A'}
              </Button>
            </LabeledList.Item>
          </LabeledList>
          <Section>
            <Button
              icon="camera"
              selected={photo_data}
              disabled={!security_mode}
              onClick={() => act('togglePhoto')}
            >
              {photo_data ? 'Remove photo' : 'Attach photo'}
            </Button>
            <Button
              disabled={!security_mode}
              icon="volume-up"
              onClick={() => act('submitWantedIssue')}
            >
              Set Wanted Issue
            </Button>
            <Button
              disabled={!security_mode}
              icon="times"
              color="red"
              onClick={() => act('clearWantedIssue')}
            >
              Clear Wanted
            </Button>
          </Section>
        </>
      ) : (
        <Box>
          {wanted.map((activeWanted) =>
            activeWanted.active
              ? 'Please contact your local security officer if spotted.'
              : 'No wanted issue posted. Have a secure day.',
          )}
        </Box>
      )}
    </Modal>
  );
};

const NewscasterContent = (props) => {
  const { act, data } = useBackend();
  const { current_channel = {} } = data;
  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <Stack fill>
          <Stack.Item grow>
            <NewscasterChannelSelector />
          </Stack.Item>
          <Stack.Item grow={2}>
            <Stack fill vertical>
              <Stack.Item>
                <UserDetails />
              </Stack.Item>
              <Stack.Item grow>
                <NewscasterChannelBox
                  channelName={current_channel.name}
                  channelOwner={current_channel.owner}
                  channelDesc={current_channel.desc}
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item grow>
        <NewscasterChannelMessages />
      </Stack.Item>
    </Stack>
  );
};

/** The Channel Box is the basic channel information where buttons live.*/
const NewscasterChannelBox = (props) => {
  const { act, data } = useBackend();
  const {
    channelName,
    channelDesc,
    channelLocked,
    channelAuthor,
    channelCensored,
    receivingCrossSector,
    viewing_channel,
    admin_mode,
    photo_data,
    paper,
    user,
  } = data;
  return (
    <Section fill title={channelName}>
      <Stack fill vertical>
        <Stack.Item grow>
          {channelCensored ? (
            <Section>
              <BlockQuote color="red">
                <b>ATTENTION:</b> {CENSOR_MESSAGE}
              </BlockQuote>
            </Section>
          ) : (
            <Section fill scrollable>
              <BlockQuote italic fontSize={1.2} wrap>
                {decodeHtmlEntities(channelDesc)}
              </BlockQuote>
            </Section>
          )}
        </Stack.Item>
        <Stack.Item>
          <Box>
            <Button
              icon="print"
              disabled={
                (channelLocked && channelAuthor !== user.name) ||
                channelCensored ||
                receivingCrossSector
              }
              onClick={() => act('createStory', { current: viewing_channel })}
              mt={1}
            >
              Submit Story
            </Button>
            <Button
              icon="camera"
              selected={photo_data}
              disabled={
                (channelLocked && channelAuthor !== user.name) ||
                channelCensored ||
                receivingCrossSector
              }
              onClick={() => act('togglePhoto')}
            >
              Select Photo
            </Button>
            {!!admin_mode && (
              <Button
                icon="ban"
                tooltip="Censor the whole channel and its \
                  contents as dangerous to the station. Cannot be undone."
                disabled={!admin_mode || !viewing_channel}
                onClick={() =>
                  act('channelDNotice', {
                    secure: admin_mode,
                    channel: viewing_channel,
                  })
                }
              >
                D-Notice
              </Button>
            )}
          </Box>
          <Box>
            <Button
              icon="newspaper"
              tooltip={paper <= 0 ? 'Insert paper first!' : ''}
              disabled={paper <= 0}
              onClick={() => act('printNewspaper')}
            >
              Print Newspaper
            </Button>
          </Box>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

/** Channel select is the left-hand menu where all the channels are listed. */
const NewscasterChannelSelector = (props) => {
  const { act, data } = useBackend();
  const { channels = [], viewing_channel, wanted = [] } = data;
  return (
    <Section minHeight="100%" width={window.innerWidth - 410 + 'px'}>
      <Tabs vertical>
        {wanted.map((activeWanted) => (
          <Tabs.Tab
            pt={0.75}
            pb={0.75}
            mr={1}
            key={activeWanted.index}
            icon={activeWanted.active ? 'skull-crossbones' : null}
            textColor={activeWanted.active ? 'red' : 'grey'}
            onClick={() => act('toggleWanted')}
          >
            Wanted Issue
          </Tabs.Tab>
        ))}
        {channels.map((channel) => (
          <Tabs.Tab
            key={channel.index}
            pt={0.75}
            pb={0.75}
            mr={1}
            selected={viewing_channel === channel.ID}
            icon={channel.censored ? 'ban' : null}
            textColor={channel.censored ? 'red' : 'white'}
            onClick={() =>
              act('setChannel', {
                channel: channel.ID,
              })
            }
          >
            {channel.name}
          </Tabs.Tab>
        ))}
        <Tabs.Tab
          pt={0.75}
          pb={0.75}
          mr={1}
          textColor="white"
          color="Green"
          onClick={() => act('startCreateChannel')}
        >
          Create Channel [+]
        </Tabs.Tab>
      </Tabs>
    </Section>
  );
};

/** This is where the channels comments get spangled out (tm) */
const NewscasterChannelMessages = (props) => {
  const { act, data } = useBackend();
  const {
    messages = [],
    viewing_channel,
    admin_mode,
    channelCensored,
    receivingCrossSector,
    channelLocked,
    channelAuthor,
    user,
  } = data;
  if (channelCensored) {
    return (
      <Section color="red">
        <b>ATTENTION:</b> Comments cannot be read at this time.
        <br />
        Thank you for your understanding, and have a secure day.
      </Section>
    );
  }
  const visibleMessages = messages.filter(
    (message) => message.ID !== viewing_channel,
  );
  return (
    <Section>
      {visibleMessages.map((message) => {
        return (
          <Section
            key={message.index}
            textColor="white"
            title={
              <i>
                {message.censored_author ? (
                  <Box textColor="red">
                    By: [REDACTED]. <b>D-Notice Notice</b> .
                  </Box>
                ) : (
                  <>
                    By: {message.auth} at {message.time}
                  </>
                )}
              </i>
            }
            buttons={
              <>
                {!!admin_mode && (
                  <Button
                    icon="comment-slash"
                    tooltip="Censor Story"
                    disabled={!admin_mode}
                    onClick={() =>
                      act('storyCensor', {
                        messageID: message.ID,
                      })
                    }
                  />
                )}
                {!!admin_mode && (
                  <Button
                    icon="user-slash"
                    tooltip="Censor Author"
                    disabled={!admin_mode}
                    onClick={() =>
                      act('authorCensor', {
                        messageID: message.ID,
                      })
                    }
                  />
                )}
                <Button
                  icon="comment"
                  tooltip="Leave a Comment."
                  disabled={
                    message.censored_author ||
                    message.censored_message ||
                    user.name === 'Unknown' ||
                    (!!channelLocked && channelAuthor !== user.name)
                  }
                  onClick={() =>
                    act('startComment', {
                      messageID: message.ID,
                    })
                  }
                />
              </>
            }
          >
            <BlockQuote>
              {message.censored_message ? (
                <Section textColor="red">
                  This message was deemed dangerous to the general welfare of
                  the station and therefore marked with a <b>D-Notice</b>.
                </Section>
              ) : (
                <Section pl={1}>
                  <Box dangerouslySetInnerHTML={processedText(message.body)} />
                </Section>
              )}
              {message.photo !== null && !message.censored_message && (
                <Image src={message.photo} />
              )}
              {!!message.comments && (
                <Box>
                  {message.comments.map((comment) => (
                    <BlockQuote key={comment.index}>
                      <Box italic textColor="white">
                        By: {comment.auth} at {comment.time}
                      </Box>
                      <Section ml={2.5}>
                        <Box
                          dangerouslySetInnerHTML={processedText(comment.body)}
                        />
                      </Section>
                    </BlockQuote>
                  ))}
                </Box>
              )}
            </BlockQuote>
            <Divider />
          </Section>
        );
      })}
    </Section>
  );
};
