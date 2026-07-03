import { Button, Section, Stack } from 'tgui-core/components';
import { useEmotes } from './hooks';

export const EmotePanel = (props, context) => {
  const TGUI_PANEL_EMOTE_TYPE_DEFAULT = 1;
  const TGUI_PANEL_EMOTE_TYPE_CUSTOM = 2;
  const TGUI_PANEL_EMOTE_TYPE_ME = 3;

  const emotes = useEmotes(context);

  const emoteList = [];
  for (const name in emotes.list) {
    const type = emotes.list[name]?.type;
    switch (type) {
      case TGUI_PANEL_EMOTE_TYPE_DEFAULT:
        emoteList.push({ type, name, key: emotes.list[name].key });
        break;
      case TGUI_PANEL_EMOTE_TYPE_CUSTOM:
        emoteList.push({
          type,
          name,
          key: emotes.list[name].key,
          message_override: emotes.list[name].message_override,
        });
        break;
      case TGUI_PANEL_EMOTE_TYPE_ME:
        emoteList.push({ type, name, message: emotes.list[name].message });
        break;
      default:
        continue;
    }
  }

  const emoteCreate = () => Byond.sendMessage('emotes/create');
  const emoteExecute = (name) => Byond.sendMessage('emotes/execute', { name });
  const emoteContextAction = (name) =>
    Byond.sendMessage('emotes/contextAction', { name });

  return (
    <Section>
      <Stack wrap align="center">
        {emoteList
          .sort((a, b) => {
            return a.name.localeCompare(b.name);
          })
          .map((emote) => {
            let color = 'blue';
            let tooltip = '';
            switch (emote.type) {
              case TGUI_PANEL_EMOTE_TYPE_DEFAULT:
                tooltip = `*${emote.key}`;
                break;
              case TGUI_PANEL_EMOTE_TYPE_CUSTOM:
                color = 'purple';
                tooltip = `*${emote.key} | "${emote.message_override}"`;
                break;
              case TGUI_PANEL_EMOTE_TYPE_ME:
                color = 'orange';
                tooltip = `"${emote.message}"`;
                break;
              default:
                tooltip = 'ОШИБКА: НЕИЗВЕСТНЫЙ ТИП ЭМОЦИИ';
                break;
            }
            return (
              <Stack.Item key={emote.name}>
                <Button
                  color={color}
                  tooltip={tooltip}
                  onClick={() => emoteExecute(emote.name)}
                  onContextMenu={(e) => {
                    e.preventDefault();
                    emoteContextAction(emote.name);
                  }}
                >
                  {emote.name}
                </Button>
              </Stack.Item>
            );
          })}
        <Stack.Item>
          <Button icon="plus" color="green" onClick={() => emoteCreate()} />
        </Stack.Item>
      </Stack>
    </Section>
  );
};
