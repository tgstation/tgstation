import { useBackend } from '../backend';
import { NoticeBox } from '../components';
import { Window } from '../layouts';

export const Terminal = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window theme={data.tguitheme} title="Terminal" width={600} height={600}>
      <Window.Content scrollable>
        <NoticeBox textAlign="left">
          {data.uppertext}
        </NoticeBox>
        {data.text}
      </Window.Content>
    </Window>
  );
};
