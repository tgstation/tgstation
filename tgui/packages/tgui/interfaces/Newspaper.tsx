import { BooleanLike } from '../../common/react';
import { useBackend } from '../backend';
import { Box, Button, Divider, Image, Section } from '../components';
import { Window } from '../layouts';
import { processedText } from '../process';

type Data = {
  current_page: number;
  scribble_message: string;
  channel_has_messages: BooleanLike;
  channels: ChannelNames[];
  channel_data: ChannelData[];
  wanted_information: WantedInformation[];
};

type ChannelNames = {
  name: string;
  page_number: number;
};

type WantedInformation = {
  wanted_criminal: string;
  wanted_body: string;
  wanted_photo: string;
};

type ChannelData = {
  channel_name: string;
  author_name: string;
  is_censored: BooleanLike;
  channel_messages: ChannelMessages[];
};

type ChannelMessages = {
  message: string;
  photo: string;
  author: string;
};

export const Newspaper = (props) => {
  const { act, data } = useBackend<Data>();
  const { channels = [], current_page, scribble_message } = data;

  return (
    <Window width={300} height={400}>
      <Window.Content backgroundColor="#858387">
        {current_page === channels.length + 1 ? (
          <NewspaperEnding />
        ) : current_page ? (
          <NewspaperChannel />
        ) : (
          <NewspaperIntro />
        )}
        {!!scribble_message && (
          <Box
            style={{
              borderTop: '3px dotted rgba(255, 255, 255, 0.8)',
              borderBottom: '3px dotted rgba(255, 255, 255, 0.8)',
            }}
          >
            {scribble_message}
          </Box>
        )}
        <Section>
          <Button
            icon="arrow-left"
            width="49%"
            disabled={!current_page}
            onClick={() => act('prev_page')}
          >
            Previous Page
          </Button>
          <Button
            icon="arrow-right"
            width="50%"
            disabled={current_page === channels.length + 1}
            onClick={() => act('next_page')}
          >
            Next Page
          </Button>
        </Section>
      </Window.Content>
    </Window>
  );
};

const NewspaperIntro = (props) => {
  const { act, data } = useBackend<Data>();
  const { channels = [], wanted_information = [] } = data;

  return (
    <Section>
      <Box bold fontSize="30px">
        The Griffon
      </Box>
      <Box bold fontSize="15px">
        For use on Space Facilities only!
      </Box>
      <Box fontSize="12px">Table of Contents:</Box>
      {channels.map((channel) => (
        <Box key={channel.page_number}>
          Page {channel.page_number || 0}: {channel.name}
        </Box>
      ))}
      {!!wanted_information && (
        <Box bold>Last Page: Important Security Announcement</Box>
      )}
    </Section>
  );
};

const NewspaperChannel = (props) => {
  const { act, data } = useBackend<Data>();
  const { channel_has_messages, channel_data = [] } = data;

  return (
    <Section>
      {channel_data.map((individual_channel) => (
        <Box key={individual_channel.channel_name}>
          <Box bold fontSize="15px">
            {individual_channel.channel_name}
          </Box>
          <Box fontSize="12px">
            Channel made by: {individual_channel.author_name}
          </Box>
          {channel_has_messages ? (
            <>
              {individual_channel.channel_messages.map((message) => (
                <>
                  <Box key={message.message}>
                    <Box
                      dangerouslySetInnerHTML={processedText(message.message)}
                    />
                    {!!message.photo && <Image src={message.photo} />}
                    <Box>Written by: {message.author}</Box>
                  </Box>
                  <Divider />
                </>
              ))}
            </>
          ) : (
            'No feed stories stem from this channel...'
          )}
        </Box>
      ))}
    </Section>
  );
};

const NewspaperEnding = (props) => {
  const { act, data } = useBackend<Data>();
  const { wanted_information = [] } = data;

  return (
    <Section>
      {wanted_information ? (
        <>
          <Box bold fontSize="15px">
            Wanted Issue
          </Box>
          {wanted_information.map((wanted) => (
            <Box key={wanted.wanted_criminal}>
              <Box fontSize="12px">Criminal Name: {wanted.wanted_criminal}</Box>
              <Box>Description: {wanted.wanted_body}</Box>
              {!!wanted.wanted_photo && <Image src={wanted.wanted_photo} />}
            </Box>
          ))}
        </>
      ) : (
        'Apart from some uninteresting classified ads, theres nothing in this page...'
      )}
    </Section>
  );
};
