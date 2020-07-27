import { Box, Tabs } from 'tgui/components';
import { useDispatch, useSelector } from 'tgui/store';
import { changeChatPage } from './actions';
import { selectChatPages, selectCurrentChatPage } from './selectors';

export const ChatTabs = (props, context) => {
  const pages = useSelector(context, selectChatPages);
  const currentPage = useSelector(context, selectCurrentChatPage);
  const dispatch = useDispatch(context);
  return (
    <Tabs textAlign="center">
      {pages.map(page => (
        <Tabs.Tab
          key={page.id}
          selected={page === currentPage}
          rightSlot={(
            <Box fontSize="0.9em">
              {page.count}
            </Box>
          )}
          onClick={() => dispatch(changeChatPage(page))}>
          {page.name}
        </Tabs.Tab>
      ))}
    </Tabs>
  );
};
