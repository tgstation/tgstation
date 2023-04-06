import { Button, Section, Stack } from '../components';
import { useBackend, useLocalState } from '../backend';

import { Window } from '../layouts';

type Data = {
  items: string[];
};

export const MultiSelectInput = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { items = [] } = data;

  const [selections, setSelections] = useLocalState<string[]>(
    context,
    'selections',
    []
  );

  const selectItem = (name: string) => {
    let newSelections: string[] = [];

    if (selections.includes(name)) {
      newSelections = selections.filter((item) => item !== name);
    } else {
      newSelections = [...selections, name];
    }

    setSelections(newSelections);
  };

  return (
    <Window width={425} height={176}>
      <Window.Content>
        <Section fill>
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
