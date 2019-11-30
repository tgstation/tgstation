import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Button, Grid, Section } from '../components';

export const ChemFilterPane = props => {
  const { act } = useBackend(props);
  const { title, list } = props;
  const titleKey = title.toLowerCase();
  return (
    <Section
      title={title}
      minHeight={40}
      ml={0.5}
      mr={0.5}
      buttons={(
        <Button
          icon="plus"
          onClick={() => act('add', {
            which: titleKey,
          })} />
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

export const ChemFilter = props => {
  const { state } = props;
  const { data } = useBackend(props);
  const {
    left = [],
    right = [],
  } = data;
  return (
    <Grid>
      <Grid.Column>
        <ChemFilterPane
          title="Left"
          list={left}
          state={state} />
      </Grid.Column>
      <Grid.Column>
        <ChemFilterPane
          title="Right"
          list={right}
          state={state} />
      </Grid.Column>
    </Grid>
  );
};
