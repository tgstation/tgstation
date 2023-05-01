import { useBackend, useLocalState } from '../../backend';
import { Button, NoticeBox, Section, TextArea } from '../../components';
import { RequestsData } from './types';

export const AnnouncementTab = (props, context) => {
  const { act, data } = useBackend<RequestsData>(context);
  const { authentication_data, is_admin_ghost_ai } = data;
  const [messageText, setMessageText] = useLocalState(
    context,
    'messageText',
    ''
  );
  return (
    <Section>
      <TextArea
        fluid
        height={20}
        maxLength={1025}
        multiline
        value={messageText}
        onChange={(_, value) => setMessageText(value)}
        placeholder="Type your announcement..."
      />
      <Section>
        <AuthenticationNoticeBox />
        <Button
          disabled={
            !(
              authentication_data.announcement_authenticated ||
              is_admin_ghost_ai
            ) || !messageText
          }
          icon="bullhorn"
          content="Send announcement"
          onClick={() => {
            if (
              !(
                authentication_data.announcement_authenticated ||
                is_admin_ghost_ai
              ) ||
              !messageText
            ) {
              return;
            }
            act('send_announcement', { message: messageText });
            setMessageText('');
          }}
        />
        <Button
          icon="trash-can"
          content="Discard announcement"
          onClick={() => {
            act('clear_authentication');
            setMessageText('');
          }}
        />
      </Section>
    </Section>
  );
};

const AuthenticationNoticeBox = (props, context) => {
  const { act, data } = useBackend<RequestsData>(context);
  const { authentication_data, is_admin_ghost_ai } = data;
  return (
    (!authentication_data.announcement_authenticated && !is_admin_ghost_ai && (
      <NoticeBox warning>
        {'Swipe your card to authenticate yourself'}
      </NoticeBox>
    )) || <NoticeBox info>{'Succesfully authenticated'}</NoticeBox>
  );
};
