import { KEY } from 'common/keys';
import { Handlers } from '.';
import { TguiSay } from '../TguiSay';

/** Increments the chat history counter, looping through entries */
export const handleArrowKeys: Handlers['arrowKeys'] = function (
  this: TguiSay,
  direction
) {
  const { channelIterator, chatHistory, innerRef } = this.fields;
  const { setSize } = this.handlers;
  const currentValue = innerRef.current?.value;

  if (direction === KEY.Up) {
    if (chatHistory.isAtLatest() && currentValue) {
      // Save current message to temp history if at the most recent message
      chatHistory.saveTemp(currentValue);
    }
    // Try to get the previous message, fall back to the current value if none
    const prevMessage = chatHistory.getOlderMessage();

    if (prevMessage) {
      this.setState({
        buttonContent: chatHistory.getIndex(),
        size: prevMessage.length,
        value: prevMessage,
      });
      setSize(prevMessage.length);
    }
  } else {
    const nextMessage =
      chatHistory.getNewerMessage() || chatHistory.getTemp() || '';
    const index = chatHistory.getIndex() - 1;
    const content = index <= 0 ? channelIterator.current() : index;

    this.setState({
      buttonContent: content,
      value: nextMessage,
    });
    setSize(nextMessage.length);
  }
};
