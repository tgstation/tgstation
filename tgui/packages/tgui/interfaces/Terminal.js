import { useBackend } from '../backend';
import { NoticeBox } from '../components';
import { Window } from '../layouts';
import { sanitizeText } from '../sanitize';

export const Terminal = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window theme={data.tguitheme} title="Terminal" width={600} height={600}>
      <Window.Content scrollable>
        <NoticeBox textAlign="left">
          {sanitizeText(data.uppertext)}
        </NoticeBox>
        {sanitizeText(data.text)}
      </Window.Content>
    </Window>
  );
};
