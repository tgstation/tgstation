/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { useDispatch, useSelector } from 'tgui/backend';
import { Button, Collapsible, Divider, Input, Section, Stack } from 'tgui/components';
import { removeChatPage, toggleAcceptedType, updateChatPage } from './actions';
import { MESSAGE_TYPES } from './constants';
import { selectCurrentChatPage } from './selectors';

export const ChatPageSettings = (props) => {
  const page = useSelector(selectCurrentChatPage);
  const dispatch = useDispatch();
  return (
    <Section>
      <Stack align="center">
        <Stack.Item grow={1}>
          <Input
            fluid
            value={page.name}
            onChange={(e, value) =>
              dispatch(
                updateChatPage({
                  pageId: page.id,
                  name: value,
                })
              )
            }
          />
        </Stack.Item>
        <Stack.Item>
          <Button
            icon="times"
            color="red"
            onClick={() =>
              dispatch(
                removeChatPage({
                  pageId: page.id,
                })
              )
            }>
            Remove
          </Button>
        </Stack.Item>
      </Stack>
      <Divider />
      <Section title="Messages to display" level={2}>
        {MESSAGE_TYPES.filter(
          (typeDef) => !typeDef.important && !typeDef.admin
        ).map((typeDef) => (
          <Button.Checkbox
            key={typeDef.type}
            checked={page.acceptedTypes[typeDef.type]}
            onClick={() =>
              dispatch(
                toggleAcceptedType({
                  pageId: page.id,
                  type: typeDef.type,
                })
              )
            }>
            {typeDef.name}
          </Button.Checkbox>
        ))}
        <Collapsible mt={1} color="transparent" title="Admin stuff">
          {MESSAGE_TYPES.filter(
            (typeDef) => !typeDef.important && typeDef.admin
          ).map((typeDef) => (
            <Button.Checkbox
              key={typeDef.type}
              checked={page.acceptedTypes[typeDef.type]}
              onClick={() =>
                dispatch(
                  toggleAcceptedType({
                    pageId: page.id,
                    type: typeDef.type,
                  })
                )
              }>
              {typeDef.name}
            </Button.Checkbox>
          ))}
        </Collapsible>
      </Section>
    </Section>
  );
};
