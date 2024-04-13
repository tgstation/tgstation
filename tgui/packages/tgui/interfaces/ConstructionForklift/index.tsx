import { useBackend } from '../../backend';
import { NoticeBox } from '../../components';
import { Window } from '../../layouts';

export const ConstructionForklift = (props: any) => {
  const { act, data } = useBackend<ForkliftData>();
  const {
    materials,
    modules,
    cooldowns,
    hologram_count,
    active_module_data,
  } = data;

  return (
    <Window title="Forklift Management Console">
      <Window.Content>
        <NoticeBox danger>TODO!</NoticeBox>
      </Window.Content>
    </Window>
  );
};
