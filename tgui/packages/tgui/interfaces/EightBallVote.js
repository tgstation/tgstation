import { useBackend } from '../backend';
import { Box, Button, Grid, Section, NoticeBox } from '../components';
import { toTitleCase } from 'common/string';

export const EightBallVote = props => {
  const { act, data } = useBackend(props);

  const {
    question,
    shaking,
    answers = [],
  } = data;

  if (!shaking) {
    return (
      <NoticeBox>
        No question is currently being asked.
      </NoticeBox>
    );
  }

  return (
    <Section>
      <Box
        bold
        textAlign="center"
        fontSize="16px"
        m={1}>
        &quot;{question}&quot;
      </Box>
      <Grid>
        {answers.map(answer => (
          <Grid.Column key={answer.answer}>
            <Button
              fluid
              bold
              content={toTitleCase(answer.answer)}
              selected={answer.selected}
              fontSize="16px"
              lineHeight="24px"
              textAlign="center"
              mb={1}
              onClick={() => act('vote', {
                answer: answer.answer,
              })} />
            <Box
              bold
              textAlign="center"
              fontSize="30px">
              {answer.amount}
            </Box>
          </Grid.Column>
        ))}
      </Grid>
    </Section>
  );
};
