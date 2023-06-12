import { useBackend } from '../backend';
import { Button, Flex } from '../components';
import { NtosWindow } from '../layouts';

type Data = {
  PC_device_theme: string;
  themes: ThemeInfo[];
};

type ThemeInfo = {
  theme_name: string;
  theme_ref: string;
};

export const NtosThemeConfigure = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { PC_device_theme, themes } = data;
  return (
    <NtosWindow width={400} height={600}>
      <NtosWindow.Content scrollable>
        <Flex
          height="70%"
          grow
          direction="column"
          textAlign="center"
          align-items="center">
          {themes.map((theme) => (
            <Flex.Item key={theme} width="100%" grow={1}>
              <Button.Checkbox
                checked={theme.theme_ref === PC_device_theme}
                width="75%"
                lineHeight="50px"
                content={theme.theme_name}
                onClick={() =>
                  act('PRG_change_theme', {
                    selected_theme: theme.theme_name,
                  })
                }
              />
            </Flex.Item>
          ))}
        </Flex>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
