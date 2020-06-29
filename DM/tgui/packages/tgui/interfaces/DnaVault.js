import { useBackend } from '../backend';
import { Box, Button, Grid, LabeledList, ProgressBar, Section } from '../components';
import { Window } from '../layouts';

export const DnaVault = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    completed,
    used,
    choiceA,
    choiceB,
    dna,
    dna_max,
    plants,
    plants_max,
    animals,
    animals_max,
  } = data;
  return (
    <Window>
      <Window.Content>
        <Section title="DNA Vault Database">
          <LabeledList>
            <LabeledList.Item label="Human DNA">
              <ProgressBar
                value={dna / dna_max}>
                {dna + ' / ' + dna_max + ' Samples'}
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label="Plant DNA">
              <ProgressBar
                value={plants / plants_max}>
                {plants + ' / ' + plants_max + ' Samples'}
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label="Animal DNA">
              <ProgressBar
                value={animals / animals}>
                {animals + ' / ' + animals_max + ' Samples'}
              </ProgressBar>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        {!!(completed && !used) && (
          <Section title="Personal Gene Therapy">
            <Box
              bold
              textAlign="center"
              mb={1}>
              Applicable Gene Therapy Treatments
            </Box>
            <Grid>
              <Grid.Column>
                <Button
                  fluid
                  bold
                  content={choiceA}
                  textAlign="center"
                  onClick={() => act('gene', {
                    choice: choiceA,
                  })} />
              </Grid.Column>
              <Grid.Column>
                <Button
                  fluid
                  bold
                  content={choiceB}
                  textAlign="center"
                  onClick={() => act('gene', {
                    choice: choiceB,
                  })} />
              </Grid.Column>
            </Grid>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
