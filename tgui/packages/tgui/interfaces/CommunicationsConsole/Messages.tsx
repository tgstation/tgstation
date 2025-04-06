import { ReactNode } from 'react';
import { Box, Button, Section } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { sanitizeText } from '../../sanitize';
import { CommsConsoleData, ShuttleState } from './types';

export function PageMessages(props) {
  const { act, data } = useBackend<CommsConsoleData>();
  const { messages = [] } = data;

  const children: ReactNode[] = [];

  children.push(
    <Section>
      <Button
        icon="chevron-left"
        onClick={() => act('setState', { state: ShuttleState.MAIN })}
      >
        Back
      </Button>
    </Section>,
  );

  const messageElements: ReactNode[] = [];

  for (const [messageIndex, message] of Object.entries(messages)) {
    let answers;

    if (message.possibleAnswers.length > 0) {
      answers = (
        <Box mt={1}>
          {message.possibleAnswers.map((answer, answerIndex) => (
            <Button
              color={message.answered === answerIndex + 1 ? 'good' : undefined}
              key={answerIndex}
              onClick={
                message.answered
                  ? undefined
                  : () =>
                      act('answerMessage', {
                        message: parseInt(messageIndex, 10) + 1,
                        answer: answerIndex + 1,
                      })
              }
            >
              {answer}
            </Button>
          ))}
        </Box>
      );
    }

    const textHtml = {
      __html: sanitizeText(message.content),
    };

    messageElements.push(
      <Section
        title={message.title}
        key={messageIndex}
        buttons={
          <Button.Confirm
            icon="trash"
            color="red"
            onClick={() =>
              act('deleteMessage', {
                message: messageIndex + 1,
              })
            }
          >
            Delete
          </Button.Confirm>
        }
      >
        <Box dangerouslySetInnerHTML={textHtml} />

        {answers}
      </Section>,
    );
  }

  children.push(messageElements.reverse());

  return children;
}
