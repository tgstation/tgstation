import { useState } from 'react';
import { Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { Clients, UserInfo } from './BaseInfo';
import { Subject } from './Subject';
import type { WhoData } from './types';

export function Who(props) {
  const { data } = useBackend<WhoData>();
  const [subjectRef, setSubjectRef] = useState();

  return (
    <Window title="Who's there?" width={550} height={650}>
      <Window.Content>
        {!!data.modalOpen && (
          <Subject subjectRef={subjectRef} setSubjectRef={setSubjectRef} />
        )}
        <Stack fill vertical>
          <Stack.Item grow>
            <Clients setSubjectRef={setSubjectRef} />
          </Stack.Item>
          <Stack.Item>
            <UserInfo />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}
