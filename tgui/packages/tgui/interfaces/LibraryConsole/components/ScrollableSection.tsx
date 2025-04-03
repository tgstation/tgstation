import { ReactNode } from 'react';
import { Section, Stack } from 'tgui-core/components';

type Props = {
  contents: ReactNode;
  header: ReactNode;
};

export function ScrollableSection(props: Props) {
  const { contents, header } = props;

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section fontSize="20px" textAlign="center" color="label">
          {header}
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable>
          {contents}
        </Section>
      </Stack.Item>
    </Stack>
  );
}
