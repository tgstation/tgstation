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
  btitle: string;
  bcolor: string;
};

export const ChemFilterPane = (props: Props, context) => {
  const { act } = useBackend(context);
  const { title, list, btitle, bcolor } = props;
  const titleKey = title.toLowerCase();

  return (
    <Section
      title={title}
      minHeight="240px"
      buttons={
        <Button
          content={btitle}
          width="150px"
          color={bcolor}
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
            <ChemFilterPane
              title="Left"
              list={left}
              btitle="Add Left Reagent"
              bcolor="yellow"
            />
          </Stack.Item>
          <Stack.Item grow>
            <ChemFilterPane
              title="Right"
              list={right}
              btitle="Add Right Reagent"
              bcolor="red"
            />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
