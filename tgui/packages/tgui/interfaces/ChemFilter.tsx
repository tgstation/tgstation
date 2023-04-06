import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Button, Section, Stack } from '../components';
import { Window } from '../layouts';

type Data = {
  left: string[];
  right: string[];
};

type Props = {
  title: string;
  list: string[];
  buttonColor: string;
};

export const ChemFilterPane = (props: Props, context) => {
  const { act } = useBackend(context);
  const { title, list, buttonColor } = props;
  const titleKey = title.toLowerCase();

  return (
    <Section
      title={title}
      minHeight="240px"
      buttons={
        <Button
          content="Add Reagent"
          icon="plus"
          color={buttonColor}
          onClick={() =>
            act('add', {
              which: titleKey,
            })
          }
        />
      }>
      {list.map((filter) => (
        <Fragment key={filter}>
          <Button
            fluid
            icon="minus"
            content={filter}
            onClick={() =>
              act('remove', {
                which: titleKey,
                reagent: filter,
              })
            }
          />
        </Fragment>
      ))}
    </Section>
  );
};

export const ChemFilter = (props, context) => {
  const { data } = useBackend<Data>(context);
  const { left = [], right = [] } = data;

  return (
    <Window width={500} height={300}>
      <Window.Content scrollable>
        <Stack>
          <Stack.Item grow>
            <ChemFilterPane title="Left" list={left} buttonColor="yellow" />
          </Stack.Item>
          <Stack.Item grow>
            <ChemFilterPane title="Right" list={right} buttonColor="red" />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
