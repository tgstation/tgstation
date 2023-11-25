/**
 * @file
 * @copyright 2021 Aleksej Komarov
 * @license MIT
 */

import { useLocalState } from '../backend';
import { Input, LabeledList, Section } from '../components';

export const meta = {
  title: 'Themes',
  render: () => <Story />,
};

const Story = (props, context) => {
  const [theme, setTheme] = useLocalState(context, 'kitchenSinkTheme');
  return (
    <Section>
      <LabeledList>
        <LabeledList.Item label="Use theme">
          <Input
            placeholder="theme_name"
            value={theme}
            onInput={(e, value) => setTheme(value)}
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
