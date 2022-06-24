import { useBackend } from '../backend';
import { NoticeBox, Section } from '../components';
import { Window } from '../layouts';

export const Terminal = (_, context) => {
  const { act, data } = useBackend(context);
  const { uppertext, messages } = data;
  return (
    <Window theme={data.tguitheme} title="Terminal" width={480} height={520}>
      <Window.Content scrollable>
        <NoticeBox textAlign="left">{uppertext}</NoticeBox>
        <Messages messages={messages} />
      </Window.Content>
    </Window>
  );
};

const Messages = (props, context) => {
  const { messages } = props;
  const { act } = useBackend(context);
  return messages.map((message) => {
    return <Section key={message.key}>{message}</Section>;
  });
};
