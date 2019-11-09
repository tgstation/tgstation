import { Fragment } from 'inferno';
import { act } from '../byond';
import { Button, Section, Grid } from '../components';


export const ChemFilterPane = props => {
  const {state} = props;
  const {ref} = state.config;
  const {title, list} = props;
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
          onClick={() => act(ref, "add", {which: titleKey})}
        />
      )}
    >
      {list.map(filter => (
        <Fragment key={filter}>
          <Button
            fluid
            icon="minus"
            content={filter}
            onClick={() => act(ref, "remove", {which: titleKey, reagent: filter})}
          />
        </Fragment>
      ))}
    </Section>
  );
};

export const ChemFilter = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  const {
    left = [],
    right = [],
  } = data;
  return (
    <Grid style={{ width: "100%" }}>
      <Grid.Item style={{ width: "50%" }}>
        <ChemFilterPane
          title="Left"
          list={left}
          state={state}
        />
      </Grid.Item>
      <Grid.Item style={{ width: "50%" }}>
        <ChemFilterPane
          title="Right"
          list={right}
          state={state}
        />
      </Grid.Item>
    </Grid>
  );
};
