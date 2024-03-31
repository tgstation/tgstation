import { useBackend } from '../../backend';
import { NoticeBox } from '../../components';
import { Window } from '../../layouts';

export const ConstructionForkliftModule_Default = () => {
  const { act, data } = useBackend<ForkliftModuleData>();

  const activeBuildTarget = data.available_builds.find(
    (buildTarget) => buildTarget.type === data.currently_selected_typepath,
  );

  return (
    <Window title={data.name}>
      <Window.Content>
        <NoticeBox danger>TODO</NoticeBox>
      </Window.Content>
    </Window>
  );
};
