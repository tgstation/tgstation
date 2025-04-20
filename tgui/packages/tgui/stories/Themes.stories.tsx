/**
 * @file
 * @copyright 2021 Aleksej Komarov
 * @license MIT
 */

import { Input, LabeledList, Section } from 'tgui-core/components';

import { useLocalState } from '../backend';

export const meta = {
  title: 'Themes',
  render: () => <Story />,
};

function Story() {
  const [theme, setTheme] = useLocalState('kitchenSinkTheme', '');

  return (
    <Section>
      <LabeledList>
        <LabeledList.Item label="Use theme">
          <Input placeholder="theme_name" value={theme} onChange={setTheme} />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
}
