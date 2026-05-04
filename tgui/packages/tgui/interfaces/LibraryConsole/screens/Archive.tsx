import { useBackend } from 'tgui/backend';
import { NoticeBox, Stack } from 'tgui-core/components';

import { PageSelect } from '../components/PageSelect';
import { SearchAndDisplay } from '../components/Search';
import type { LibraryConsoleData } from '../types';

export function Archive(props) {
  const { act, data } = useBackend<LibraryConsoleData>();
  const { can_connect, can_db_request, page_count, our_page } = data;

  if (!can_connect) {
    return (
      <NoticeBox>
        Unable to retrieve book listings. Please contact your system
        administrator for assistance.
      </NoticeBox>
    );
  }

  return (
    <Stack vertical justify="space-between" fill>
      <Stack.Item grow>
        <SearchAndDisplay />
      </Stack.Item>
      <Stack.Item align="center">
        <PageSelect
          minimum_page_count={1}
          page_count={page_count}
          current_page={our_page}
          disabled={!can_db_request}
          call_on_change={(value) =>
            act('switch_page', {
              page: value,
            })
          }
        />
      </Stack.Item>
    </Stack>
  );
}
