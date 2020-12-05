import { useBackend } from '../backend';
import { Button, LabeledList, NumberInput, Section } from '../components';
import { Window } from '../layouts';

export const Crystallizer = (props, context) => {
  const { act, data } = useBackend(context);
  const recipeTypes = data.recipe_types || [];
  return (
    <Window
      width={390}
      height={221}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Power">
              <Button
                icon={data.on ? 'power-off' : 'times'}
                content={data.on ? 'On' : 'Off'}
                selected={data.on}
                onClick={() => act('power')} />
            </LabeledList.Item>
            <LabeledList.Item label="Recipe">
              {recipeTypes.map(recipe => (
                <Button
                  key={recipe.id}
                  selected={recipe.selected}
                  content={recipe.name}
                  onClick={() => act('recipe', {
                    mode: recipe.id,
                  })} />
              ))}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
