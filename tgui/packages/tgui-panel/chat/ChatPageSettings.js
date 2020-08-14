/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { useDispatch, useSelector } from 'common/redux';
import { Button, Collapsible, Divider, Flex, Input, Section } from 'tgui/components';
import { removeChatPage, toggleAcceptedType, updateChatPage } from './actions';
import { MESSAGE_TYPES } from './constants';
import { selectCurrentChatPage } from './selectors';

export const ChatPageSettings = (props, context) => {
  const page = useSelector(context, selectCurrentChatPage);
  const dispatch = useDispatch(context);
  return (
    <Section fill>
      <Flex mx={-0.5} align="center">
        <Flex.Item mx={0.5} grow={1}>
          <Input
            fluid
            value={page.name}
            onChange={(e, value) => dispatch(updateChatPage({
              pageId: page.id,
              name: value,
            }))} />
        </Flex.Item>
        <Flex.Item mx={0.5}>
          <Button
            icon="times"
            color="red"
            onClick={() => dispatch(removeChatPage({
              pageId: page.id,
            }))}>
            Remove
          </Button>
        </Flex.Item>
      </Flex>
      <Divider />
      <Section title="Messages to display" level={2}>
        {MESSAGE_TYPES
          .filter(typeDef => !typeDef.important && !typeDef.admin)
          .map(typeDef => (
            <Button.Checkbox
              key={typeDef.type}
              checked={page.acceptedTypes[typeDef.type]}
              onClick={() => dispatch(toggleAcceptedType({
                pageId: page.id,
                type: typeDef.type,
              }))}>
              {typeDef.name}
            </Button.Checkbox>
          ))}
        <Collapsible
          mt={1}
          color="transparent"
          title="Admin stuff">
          {MESSAGE_TYPES
            .filter(typeDef => !typeDef.important && typeDef.admin)
            .map(typeDef => (
              <Button.Checkbox
                key={typeDef.type}
                checked={page.acceptedTypes[typeDef.type]}
                onClick={() => dispatch(toggleAcceptedType({
                  pageId: page.id,
                  type: typeDef.type,
                }))}>
                {typeDef.name}
              </Button.Checkbox>
            ))}
        </Collapsible>
      </Section>
    </Section>
  );
};
