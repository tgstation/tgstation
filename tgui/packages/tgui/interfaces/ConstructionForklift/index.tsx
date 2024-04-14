import { useBackend } from '../../backend';
import { Image, NoticeBox, Section } from '../../components';
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

  if(active_module_data !== undefined) {
    return (
      <Window title="Forklift Management Console">
        <Window.Content>
          <BuildTargetSelect selected={active_module_data.current_selected_typepath} available_builds={active_module_data.available_builds} />
        </Window.Content>
      </Window>
    );
  }

  return (
    <Window title="Forklift Management Console">
      <Window.Content>
        <NoticeBox danger>TODO!</NoticeBox>
      </Window.Content>
    </Window>
  );
};

const ModuleAction = (action: string, params: object) => {
  const { act } = useBackend();
  const act_params = {
    ...params,
    action: action,
  };
  act('module-action', act_params);
};

const BuildTargetSelect = (props: {
  selected: string,
  available_builds: BuildData,
}) => {
  const { selected, available_builds } = props;
  const { act } = useBackend();
  const select_item = (typepath: string) => {
    ModuleAction('select-build-target', { typepath: typepath });
  };

  return (
    <Section title="Select Construction Target">
      {Object.entries(props.available_builds).map(([typepath, build_data]) => (
        <BuildableItem
          key={typepath}
          name={build_data.name}
          is_selected={typepath === selected}
          display_src={build_data.display_src}
          typepath={typepath}
          select_item={select_item}
          />
      ))}
    </Section>
  );
};

const BuildableItem = (props: {
  name: string;
  typepath: string;
  is_selected: boolean;
  display_src: string;
  select_item: (typepath: string) => void;
}) => {
  const style = {
    border: props.is_selected ? '2px solid blue' : 'none',
    borderRadius: '2px',
    boxSizing: 'border-box',
    margin: '5px',
    padding: '1px',
  };

  return (
    <Image
      src={props.display_src}
      tooltip={props.name}
      style={style}
      onClick={() => props.select_item(props.typepath)}
      />
  );
};
