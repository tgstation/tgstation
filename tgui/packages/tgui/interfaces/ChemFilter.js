import { Component, Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Button, Grid, Section, Input } from '../components';

export const ChemFilterPane = props => {
  const { act } = useBackend(props);
  const { title, list, reagentName, onReagentInput } = props;
  const titleKey = title.toLowerCase();
  return (
    <Section
      title={title}
      minHeight={40}
      ml={0.5}
      mr={0.5}
      buttons={(
        <Fragment>
          <Input
            placeholder="Reagent"
            width="140px"
            onInput={(e, value) => onReagentInput(value)} />
          <Button
            icon="plus"
            onClick={() => act('add', {
              which: titleKey,
              name: reagentName,
            })} />
        </Fragment>
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

export class ChemFilter extends Component {
  constructor() {
    super();
    this.state = {
      leftReagentName: '',
      rightReagentName: '',
    };
  }

  setLeftReagentName(leftReagentName) {
    this.setState({
      leftReagentName,
    });
  }

  setRightReagentName(rightReagentName) {
    this.setState({
      rightReagentName,
    });
  }

  render() {
    const { state } = this.props;
    const { data } = state;
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
            reagentName={this.state.leftReagentName}
            onReagentInput={value => this.setLeftReagentName(value)}
            state={state} />
        </Grid.Column>
        <Grid.Column>
          <ChemFilterPane
            title="Right"
            list={right}
            reagentName={this.state.rightReagentName}
            onReagentInput={value => this.setRightReagentName(value)}
            state={state} />
        </Grid.Column>
      </Grid>
    );
  }
}
