import { useBackend } from '../backend';
import { NoticeBox, Section } from '../components';
import { Window } from '../layouts';

type Data = {
  uppertext: string;
  messages: { key: string }[];
  tguitheme: string;
};

export const Terminal = (props, context) => {
  const { data } = useBackend<Data>(context);
  const { messages = [], uppertext } = data;

  return (
    <Window theme={data.tguitheme} title="Terminal" width={480} height={520}>
      <Window.Content scrollable>
        <NoticeBox textAlign="left">{uppertext}</NoticeBox>
        {messages.map((message) => {
          return (
            <Section
              key={message.key}
              dangerouslySetInnerHTML={{ __html: message }}
            />
          );
        })}
      </Window.Content>
    </Window>
  );
};
