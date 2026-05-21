import {
  Box,
  Button,
  Divider,
  Flex,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { toTitleCase } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  answers: Answer[];
  question: string;
  shaking: BooleanLike;
};

type Answer = {
  amount: number;
  answer: string;
  selected: BooleanLike;
};

export function EightBallVote(props) {
  const { data } = useBackend<Data>();
  const { shaking } = data;

  const idealHeight = shaking ? 265 : 70;
  return (
    <Window width={300} height={idealHeight}>
      <Window.Content pb={'2.5em'}>
        {!shaking ? (
          <NoticeBox danger textAlign={'center'}>
            No question is currently being asked.
          </NoticeBox>
        ) : (
          <>
            <NoticeBox success textAlign={'center'}>
              A question is currently being asked!
            </NoticeBox>
            <EightBallVoteQuestion />
          </>
        )}
      </Window.Content>
    </Window>
  );
}

function EightBallVoteQuestion(props) {
  const { act, data } = useBackend<Data>();
  const { shaking, question, answers = [] } = data;

  return (
    <Section height="100%">
      <Flex bold align="start" textAlign="center" fontSize="16px" m={1}>
        <Flex.Item>&quot;</Flex.Item>
        <Flex.Item grow>{question}</Flex.Item>
        <Flex.Item>&quot;</Flex.Item>
      </Flex>

      <Divider />

      <Stack>
        {answers.map((answer) => (
          <Stack.Item grow key={answer.answer}>
            <Button
              fluid
              bold
              disabled={!shaking}
              selected={answer.selected}
              fontSize="16px"
              lineHeight="24px"
              textAlign="center"
              mb={1}
              onClick={() =>
                act('vote', {
                  answer: answer.answer,
                })
              }
            >
              {toTitleCase(answer.answer)}
            </Button>
            <Box bold textAlign="center" fontSize="30px">
              {answer.amount}
            </Box>
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
}
