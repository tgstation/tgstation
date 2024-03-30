import { useBackend } from '../../backend';
import { NoticeBox } from '../../components';
import { Window } from '../../layouts';

export const ConstructionForklift = () => {
  const { act, data } = useBackend<ConstructionForkliftData>();

  return (
    <Window>
      <Window.Content>
        <NoticeBox>TODO</NoticeBox>
      </Window.Content>
    </Window>
  );
};
