import { map } from 'common/collections';
import { classes } from 'common/react';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Input, LabeledList, NumberInput, Section } from '../components';
import { Window } from '../layouts';

export const ChemReactionChamber = (props, context) => {
  const { act, data } = useBackend(context);
  const [
    reagentName,
    setReagentName,
  ] = useLocalState(context, 'reagentName', '');
  const [
    reagentQuantity,
    setReagentQuantity,
  ] = useLocalState(context, 'reagentQuantity', 1);
  const emptying = data.emptying;
  const reagents = data.reagents || [];
  return (
    <Window
      width={250}
      height={225}
      resizable>
      <Window.Content scrollable>
        <Section
          title="Reagents"
          buttons={(
            <Box
              inline
              bold
              color={emptying ? "bad" : "good"}>
              {emptying ? "Emptying" : "Filling"}
            </Box>
          )}>
          <LabeledList>
            <tr className="LabledList__row">
              <td
                colSpan="2"
                className="LabeledList__cell">
                <Input
                  fluid
                  value=""
                  placeholder="Reagent Name"
                  onInput={(e, value) => setReagentName(value)} />
              </td>
              <td
                className={classes([
                  "LabeledList__buttons",
                  "LabeledList__cell",
                ])}>
                <NumberInput
                  value={reagentQuantity}
                  minValue={1}
                  maxValue={100}
                  step={1}
                  stepPixelSize={3}
                  width="39px"
                  onDrag={(e, value) => setReagentQuantity(value)} />
                <Box inline mr={1} />
                <Button
                  icon="plus"
                  onClick={() => act('add', {
                    chem: reagentName,
                    amount: reagentQuantity,
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
                    onClick={() => act('remove', {
                      chem: reagent,
                    })} />
                )}>
                {amount}
              </LabeledList.Item>
            ))(reagents)}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
