/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { useDispatch, useSelector } from 'tgui/backend';
import { Box, Button, Flex, Tabs } from 'tgui-core/components';

import { openChatSettings } from '../settings/actions';
import { addChatPage, changeChatPage } from './actions';
import { selectChatPages, selectCurrentChatPage } from './selectors';

const UnreadCountWidget = ({ value }) => (
  <Box className="UnreadCount">{Math.min(value, 99)}</Box>
);

export const ChatTabs = (props) => {
  const pages = useSelector(selectChatPages);
  const currentPage = useSelector(selectCurrentChatPage);
  const dispatch = useDispatch();
  return (
    <Flex align="center">
      <Flex.Item>
        <Tabs textAlign="center">
          {pages.map((page) => (
            <Tabs.Tab
              key={page.id}
              selected={page === currentPage}
              onClick={() =>
                dispatch(
                  changeChatPage({
                    pageId: page.id,
                  }),
                )
              }
            >
              {page.name}
              {!page.hideUnreadCount && page.unreadCount > 0 && (
                <UnreadCountWidget value={page.unreadCount} />
              )}
            </Tabs.Tab>
          ))}
        </Tabs>
      </Flex.Item>
      <Flex.Item ml={1}>
        <Button
          color="transparent"
          icon="plus"
          onClick={() => {
            dispatch(addChatPage());
            dispatch(openChatSettings());
          }}
        />
      </Flex.Item>
    </Flex>
  );
};
