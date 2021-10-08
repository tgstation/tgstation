import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Button, Input, Section, Stack } from '../components';
import { Window } from '../layouts';

export const ChemFilterPane = (props, context) => {
  const { act } = useBackend(context);
  const { title, list, reagentName, onReagentInput } = props;
  const titleKey = title.toLowerCase();
  return (
    <Section
      title={title}
      minHeight="240px"
      buttons={(
        <>
          <Input
            placeholder="Reagent"
            width="140px"
            onInput={(e, value) => onReagentInput(value)} />
          <Button
            ml={1}
            icon="plus"
            onClick={() => act('add', {
              which: titleKey,
              name: reagentName,
            })} />
        </>
      )}>
      {list.map(filter => (
        <Fragment key={filter}>
          <Button
            fluid
            icon="minus"
            content={filter}
            onClick={() => act('remove', {
              which: titleKey,
              reagent: filter,
            })} />
        </Fragment>
      ))}
    </Section>
  );
};

export const ChemFilter = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    left = [],
    right = [],
  } = data;
  const [leftName, setLeftName] = useLocalState(context, 'leftName', '');
  const [rightName, setRightName] = useLocalState(context, 'rightName', '');
  return (
    <Window
      width={500}
      height={300}>
      <Window.Content scrollable>
        <Stack>
          <Stack.Item grow>
            <ChemFilterPane
              title="Left"
              list={left}
              reagentName={leftName}
              onReagentInput={value => setLeftName(value)} />
          </Stack.Item>
          <Stack.Item grow>
            <ChemFilterPane
              title="Right"
              list={right}
              reagentName={rightName}
              onReagentInput={value => setRightName(value)} />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
