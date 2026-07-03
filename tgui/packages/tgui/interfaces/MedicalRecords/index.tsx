import { useBackend } from 'tgui/backend';
import { Window } from 'tgui/layouts';
import { Box, Button, Icon, NoticeBox, Stack } from 'tgui-core/components';

import { MedicalRecordTabs } from './RecordTabs';
import { MedicalRecordView } from './RecordView';
import type { MedicalRecordData } from './types';

export const MedicalRecords = (props) => {
  const { data } = useBackend<MedicalRecordData>();
  const { authenticated } = data;

  return (
    <Window title="Medical Records" width={750} height={550}>
      <Window.Content>
        <Stack fill>
          {!authenticated ? <UnauthorizedView /> : <AuthView />}
        </Stack>
      </Window.Content>
    </Window>
  );
};

const UnauthorizedView = (props) => {
  const { act } = useBackend<MedicalRecordData>();

  return (
    <Stack.Item grow>
      <Stack fill vertical>
        <Stack.Item grow />
        <Stack.Item align="center" grow={2}>
          <Icon color="teal" name="staff-snake" size={15} />
        </Stack.Item>
        <Stack.Item align="center" grow>
          <Box color="good" fontSize="18px" bold mt={5}>
            Nanotrasen HealthPRO
          </Box>
        </Stack.Item>
        <Stack.Item>
          <NoticeBox align="right">
            Вы не вошли.
            <Button ml={2} icon="lock-open" onClick={() => act('login')}>
              Войти
            </Button>
          </NoticeBox>
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

const AuthView = (props) => {
  const { act } = useBackend<MedicalRecordData>();

  return (
    <>
      <Stack.Item grow>
        <MedicalRecordTabs />
      </Stack.Item>
      <Stack.Item grow={2}>
        <Stack fill vertical>
          <Stack.Item grow>
            <MedicalRecordView />
          </Stack.Item>
          <Stack.Item>
            <NoticeBox align="right" info>
              Обеспечивайте безопасность рабочего места.
              <Button
                align="right"
                icon="lock"
                color="good"
                ml={2}
                onClick={() => act('logout')}
              >
                Выйти
              </Button>
            </NoticeBox>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </>
  );
};
