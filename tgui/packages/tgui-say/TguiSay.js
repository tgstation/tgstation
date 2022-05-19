
import { Stack, Input } from '../tgui/components';
import { InputButtons } from '../tgui/interfaces/common/InputButtons';
import { Window } from '../tgui/layouts';

export const TguiSay = () => {
  return (
    <Window width={325} height={200}>
      <Window.Content>
        <Stack vertical>
          <Stack.Item>
            <Input />
          </Stack.Item>
          <InputButtons input="" />
        </Stack>
      </Window.Content>
    </Window>
  );
};

