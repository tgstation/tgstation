import { useBackend, useSharedState } from '../../backend';
import { Icon, Stack, Tabs } from '../../components';
import { RequestsData, RequestTabs } from './Types';
import { MessageViewTab } from './MessageViewTab';
import { MessageWriteTab } from './MessageWriteTab';
import { AnnouncementTab } from './AnnouncementTab';

export const RequestMainScreen = (props, context) => {
  const { act, data } = useBackend<RequestsData>(context);
  const { can_send_announcements } = data;
  const [tab, setTab] = useSharedState(context, 'tab', 1);
  return (
    <Stack.Item grow>
      <Stack vertical fill>
        <Stack.Item>
          <Tabs textAlign="center" fluid>
            <Tabs.Tab
              selected={tab === RequestTabs.MESSAGE_VIEW}
              onClick={() => {
                setTab(RequestTabs.MESSAGE_VIEW);
                act('clear_new_message_priority');
              }}>
              View Messages <Icon name={'envelope-open'} />
            </Tabs.Tab>
            <Tabs.Tab
              selected={tab === RequestTabs.MESSAGE_WRITE}
              onClick={() => {
                if (tab === RequestTabs.MESSAGE_VIEW) {
                  act('clear_new_message_priority');
                }
                setTab(RequestTabs.MESSAGE_WRITE);
              }}>
              Write Message <Icon name="pencil" />
            </Tabs.Tab>
            {!!can_send_announcements && (
              <Tabs.Tab
                selected={tab === RequestTabs.ANNOUNCE}
                onClick={() => {
                  if (tab === RequestTabs.MESSAGE_VIEW) {
                    act('clear_new_message_priority');
                  }
                  setTab(RequestTabs.ANNOUNCE);
                }}>
                Make Announcement <Icon name="bullhorn" />
              </Tabs.Tab>
            )}
          </Tabs>
        </Stack.Item>
        <Stack.Item grow={1}>
          {tab === RequestTabs.MESSAGE_VIEW && <MessageViewTab />}
          {tab === RequestTabs.MESSAGE_WRITE && <MessageWriteTab />}
          {!!can_send_announcements && tab === RequestTabs.ANNOUNCE && (
            <AnnouncementTab />
          )}
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};
