import { Button, TextArea, Section, BlockQuote, NoticeBox } from '../components';
import { Window } from '../layouts';
import { useBackend } from '../backend';

export const Interview = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    welcome_message,
    questions,
    read_only,
    queue_pos,
    is_admin,
    status,
    connected,
  } = data;

  const rendered_status = status => {
    switch (status) {
      case "interview_approved":
        return (<NoticeBox success>This interview was approved.</NoticeBox>);
      case "interview_denied":
        return (<NoticeBox danger>This interview was denied.</NoticeBox>);
      default:
        return (<NoticeBox info>
          Your answers have been submitted. You are position {queue_pos} in
          queue.</NoticeBox>);
    }
  };

  return (
    <Window
      width={500}
      height={600}
      noClose={!is_admin}>
      <Window.Content scrollable>
        {(!read_only && (
          <Section title="Welcome!">
            <p>
              {welcome_message}
            </p>
          </Section>)) || rendered_status(status)}
        <Section
          title="Questionnaire"
          buttons={(
            <span>
              <Button
                content={read_only ? "Submitted" : "Submit"}
                onClick={() => act('submit')}
                disabled={read_only} />
              {!!is_admin && status === "interview_pending" && (
                <span>
                  <Button content="Admin PM"
                    enabled={connected} onClick={() => act('adminpm')} />
                  <Button content="Approve"
                    color="good" onClick={() => act('approve')} />
                  <Button content="Deny"
                    color="bad" onClick={() => act('deny')} />
                </span>
              )}
            </span>
          )}>
          {!read_only && (
            <p>
              Please answer the following questions,
              and press submit when you are satisfied with your answers.
              <br /><br />
              <b>You will not be able to edit your answers after submitting.</b>
            </p>)}
          {questions.map(({ qidx, question, response }) => (
            <Section key={qidx} title={`Question ${qidx}`}>
              <p>{question}</p>
              {(read_only && (
                <BlockQuote>{response || "No response."}</BlockQuote>)) || (
                <TextArea
                  value={response}
                  fluid
                  height={10}
                  maxLength={500}
                  placeholder="Write your response here, max of 500 characters."
                  onChange={(e, input) => input !== response
                    && act('update_answer', {
                      qidx: qidx,
                      answer: input,
                    })} />)}
            </Section>)
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
