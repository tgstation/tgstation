import { useBackend } from '../backend';
import { NoticeBox, Section } from '../components';
import { Window } from '../layouts';

export const Terminal = (_, context) => {
	const { data } = useBackend(context);
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

const Messages = (props) => {
	const { messages } = props;

	return messages.map((message) => {
		return <Section key={message.key}>{message}</Section>;
	});
};
