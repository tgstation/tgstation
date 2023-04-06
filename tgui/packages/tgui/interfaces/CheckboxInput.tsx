import { Button, Section, Stack } from '../components';
import { useBackend, useLocalState } from '../backend';

import { Window } from '../layouts';

type Data = {
  items: string[];
  message: string;
  title: string;
};

export const CheckboxInput = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { items = [], message, title } = data;

  const [selections, setSelections] = useLocalState<string[]>(
    context,
    'selections',
    []
  );

  const selectItem = (name: string) => {
    const newSelections = selections.includes(name)
      ? selections.filter((item) => item !== name)
      : [...selections, name];

    setSelections(newSelections);
  };

  return (
    <Window title={title} width={425} height={176}>
      <Window.Content>
        <Section fill>
          {message}
          <Stack vertical>
            {items.map((item, index) => (
              <Stack.Item key={index}>
                <Button.Checkbox
                  checked={selections.includes(item)}
                  onClick={selectItem(item)}>
                  {item}
                </Button.Checkbox>
              </Stack.Item>
            ))}
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
