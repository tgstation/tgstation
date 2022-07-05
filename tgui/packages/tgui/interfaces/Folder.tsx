import { useBackend } from '../backend';
import { Box, Button, Section, Stack } from '../components';
import { Window } from '../layouts';

type Data = {
  theme: string;
  bg_color: string;
  folder_name: string;
  contents: string[];
  contents_ref: string;
};

export const Folder = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { theme, bg_color, folder_name, contents, contents_ref } = data;

  return (
    <Window
      title={folder_name || 'Folder'}
      theme={theme}
      width={400}
      height={500}>
      <Window.Content backgroundColor={bg_color || '#7f7f7f'} scrollable>
        {!contents.length && (
          <Section>
            <Box color="lightgrey" align="center">
              This folder is empty!
            </Box>
          </Section>
        )}
        {contents.map((item, index) => (
          <Stack
            key={contents_ref[index]}
            color="black"
            backgroundColor="white"
            style={{ padding: '2px 2px 0 2px' }}>
            <Stack.Item align="center" grow>
              <Box align="center">{item}</Box>
            </Stack.Item>
            <Stack.Item>
              {
                <Button
                  icon="search"
                  onClick={() => act('examine', { ref: contents_ref[index] })}
                />
              }
              <Button
                icon="eject"
                onClick={() => act('remove', { ref: contents_ref[index] })}
              />
            </Stack.Item>
          </Stack>
        ))}
      </Window.Content>
    </Window>
  );
};
