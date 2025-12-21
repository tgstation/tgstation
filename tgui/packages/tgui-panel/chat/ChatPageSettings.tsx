/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import {
  Button,
  Collapsible,
  Divider,
  Input,
  Section,
  Stack,
} from 'tgui-core/components';
import { MESSAGE_TYPES } from './constants';
import { useChatPages } from './use-chat-pages';

export function ChatPageSettings(props) {
  const {
    page,
    moveChatLeft,
    moveChatRight,
    updateChatPage,
    removeChatPage,
    toggleAcceptedType,
  } = useChatPages();

  return (
    <Section>
      <Stack align="center">
        {!page.isMain && (
          <Stack.Item>
            <Button
              color="blue"
              icon="angles-left"
              tooltip="Reorder tab to the left"
              onClick={moveChatLeft}
            />
          </Stack.Item>
        )}
        <Stack.Item grow ml={0.5}>
          <Input
            fluid
            value={page.name}
            onBlur={(value) =>
              updateChatPage({
                name: value,
              })
            }
          />
        </Stack.Item>
        {!page.isMain && (
          <Stack.Item ml={0.5}>
            <Button
              color="blue"
              icon="angles-right"
              tooltip="Reorder tab to the right"
              onClick={moveChatRight}
            />
          </Stack.Item>
        )}
        <Stack.Item>
          <Button.Checkbox
            checked={page.hideUnreadCount}
            icon={page.hideUnreadCount ? 'bell-slash' : 'bell'}
            tooltip="Disables unread counter"
            onClick={() =>
              updateChatPage({
                hideUnreadCount: !page.hideUnreadCount,
              })
            }
          >
            Mute
          </Button.Checkbox>
        </Stack.Item>
        {!page.isMain && (
          <Stack.Item>
            <Button color="red" icon="times" onClick={removeChatPage}>
              Remove
            </Button>
          </Stack.Item>
        )}
      </Stack>
      <Divider />
      <Section title="Messages to display">
        {MESSAGE_TYPES.filter(
          (typeDef) => !typeDef.important && !typeDef.admin,
        ).map((typeDef) => (
          <Button.Checkbox
            key={typeDef.type}
            checked={page.acceptedTypes[typeDef.type]}
            onClick={() => toggleAcceptedType(typeDef.type)}
          >
            {typeDef.name}
          </Button.Checkbox>
        ))}
        <Collapsible mt={1} color="transparent" title="Admin stuff">
          {MESSAGE_TYPES.filter(
            (typeDef) => !typeDef.important && typeDef.admin,
          ).map((typeDef) => (
            <Button.Checkbox
              key={typeDef.type}
              checked={page.acceptedTypes[typeDef.type]}
              onClick={() => toggleAcceptedType(typeDef.type)}
            >
              {typeDef.name}
            </Button.Checkbox>
          ))}
        </Collapsible>
      </Section>
    </Section>
  );
}
