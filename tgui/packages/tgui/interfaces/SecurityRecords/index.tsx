import { useBackend } from 'tgui/backend';
import { Window } from 'tgui/layouts';
import { Box, Button, Icon, NoticeBox, Stack } from 'tgui-core/components';

import { SecurityRecordTabs } from './RecordTabs';
import { SecurityRecordView } from './RecordView';
import { SecurityRecordsData } from './types';

export const SecurityRecords = (props) => {
  const { data } = useBackend<SecurityRecordsData>();
  const { authenticated } = data;

  return (
    <Window title="Security Records" width={750} height={550}>
      <Window.Content>
        <Stack fill>{!authenticated ? <RestrictedView /> : <AuthView />}</Stack>
      </Window.Content>
    </Window>
  );
};

/** Unauthorized view. User can only log in with ID */
const RestrictedView = (props) => {
  const { act } = useBackend<SecurityRecordsData>();

  return (
    <Stack.Item grow>
      <Stack fill vertical>
        <Stack.Item grow />
        <Stack.Item align="center" grow={2}>
          <Icon color="average" name="exclamation-triangle" size={15} />
        </Stack.Item>
        <Stack.Item align="center" grow>
          <Box color="red" fontSize="18px" bold mt={5}>
            Nanotrasen SecurityHUB
          </Box>
        </Stack.Item>
        <Stack.Item>
          <NoticeBox align="right">
            You are not logged in.
            <Button ml={2} icon="lock-open" onClick={() => act('login')}>
              Login
            </Button>
          </NoticeBox>
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

/** Logged in view */
const AuthView = (props) => {
  const { act } = useBackend<SecurityRecordsData>();

  return (
    <>
      <Stack.Item grow>
        <SecurityRecordTabs />
      </Stack.Item>
      <Stack.Item grow={2}>
        <Stack fill vertical>
          <Stack.Item grow>
            <SecurityRecordView />
          </Stack.Item>
          <Stack.Item>
            <NoticeBox align="right" info>
              Secure Your Workspace.
              <Button
                align="right"
                icon="lock"
                color="good"
                ml={2}
                onClick={() => act('logout')}
              >
                Log Out
              </Button>
            </NoticeBox>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </>
  );
};
