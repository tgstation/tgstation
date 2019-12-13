import { Component } from 'inferno';
import { act } from '../byond';
import { Box, Button, LabeledList, NumberInput, Section, Input } from '../components';
import { map } from 'common/collections';
import { classes } from 'common/react';


export class ChemReactionChamber extends Component {
  constructor() {
    super();
    this.state = {
      reagentName: "",
      reagentQuantity: 1,
    };
  }

  setReagentName(reagentName) {
    this.setState({
      reagentName,
    });
  }

  setReagentQuantity(reagentQuantity) {
    this.setState({
      reagentQuantity,
    });
  }

  render() {
    const { state } = this.props;
    const { config, data } = state;
    const { ref } = config;
    const emptying = data.emptying;
    const reagents = data.reagents || [];
    return (
      <Section
        title="Reagents"
        buttons={(
          <Box
            inline
            bold
            color={emptying ? "bad" : "good"} >
            {emptying ? "Emptying" : "Filling"}
          </Box>
        )} >
        <LabeledList>
          <tr className="LabledList__row">
            <td
              colSpan="2"
              className="LabeledList__cell" >
              <Input
                fluid
                value=""
                placeholder="Reagent Name"
                onInput={(e, value) => this.setReagentName(value)} />
            </td>
            <td
              className={classes([
                "LabeledList__buttons",
                "LabeledList__cell",
              ])} >
              <NumberInput
                value={this.state.reagentQuantity}
                minValue={1}
                maxValue={100}
                step={1}
                stepPixelSize={3}
                width="39px"
                onDrag={(e, value) => this.setReagentQuantity(value)} />
              <Box inline mr={1} />
              <Button
                icon="plus"
                onClick={() => act(ref, 'add', {
                  chem: this.state.reagentName,
                  amount: this.state.reagentQuantity,
                })} />
            </td>
          </tr>
          {map((amount, reagent) => (
            <LabeledList.Item
              key={reagent}
              label={reagent}
              buttons={(
                <Button
                  icon="minus"
                  color="bad"
                  onClick={() => act(ref, 'remove', {
                    chem: reagent,
                  })} />
              )}>
              {amount}
            </LabeledList.Item>
          ))(reagents)}
        </LabeledList>
      </Section>
    );
  }
}
