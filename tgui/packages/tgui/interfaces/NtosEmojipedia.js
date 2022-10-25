import { useBackend } from '../backend';
import { Box, Section } from '../components';
import { NtosWindow } from '../layouts';

export const NtosEmojipedia = (props, context) => {
  const { act, data } = useBackend(context);
  const { emoji_list } = data;

  return (
    <NtosWindow width={600} height={800}>
      <NtosWindow.Content scrollable>
        <Section textAlign="center">
          <i>EmojiPedia 2.0 - All You Could Ever Need!</i>
        </Section>
        {emoji_list.map((emoji) => (
          <Section key={emoji.name}>
            <Box
              as="img"
              m={0}
              src={`data:image/jpeg;base64,${emoji.icon64}`}
              height="100%"
              style={{
                '-ms-interpolation-mode': 'nearest-neighbor',
              }}
            />
            {emoji.name}
          </Section>
        ))}
      </NtosWindow.Content>
    </NtosWindow>
  );
};
