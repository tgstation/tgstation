import { useBackend } from '../../backend';
import { Button, Image, Section } from '../../components';
import { Window } from '../../layouts';

export const ConstructionForklift = (props: any) => {
  const { act, data } = useBackend<ForkliftData>();
  const { materials, modules, cooldowns, hologram_count, active_module_data } =
    data;

  let build_select: JSX.Element | undefined;
  if (active_module_data !== undefined) {
    build_select = (
      <BuildTargetSelect
        selected={active_module_data.current_selected_typepath}
        available_builds={active_module_data.available_builds}
      />
    );
  }

  const set_active_module = (module: string) => {
    act('set-active', { new_module_ref: module });
  };
  let module_select = (
    <ModuleSelect modules={modules} set_active_module={set_active_module} />
  );

  return (
    <Window title="Forklift Management Console">
      <Window.Content>
        {module_select}
        {build_select}
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

const ModuleSelect = (props: {
  modules: ModuleData;
  set_active_module: (module: string) => void;
}) => {
  const { modules, set_active_module } = props;

  return (
    <Section title="Select Module">
      {Object.entries(modules.available).map(([module_ref, module_data]) => (
        <ItemSelect
          key={module_ref}
          name={module_data.name}
          is_selected={module_ref === modules.active}
          display_src={module_data.display_src}
          item={module_ref}
          select_item={set_active_module}
        />
      ))}
    </Section>
  );
};

const BuildTargetSelect = (props: {
  selected: string;
  available_builds: BuildData;
}) => {
  const { selected, available_builds } = props;
  const { act } = useBackend();
  const select_item = (typepath: string) => {
    ModuleAction('select-build-target', { typepath: typepath });
  };

  return (
    <Section
      title="Construction Target"
      buttons={
        <>
          <Button
            icon="arrow-up"
            tooltip="Reset Direction"
            onClick={() => ModuleAction('rotate', { direction: 'north' })}
          />
          <Button
            icon="rotate-right"
            tooltip="Rotate Clockwise"
            onClick={() => ModuleAction('rotate', { direction: 'cw' })}
          />
          <Button
            icon="rotate-left"
            tooltip="Rotate Counter-Clockwise"
            onClick={() => ModuleAction('rotate', { direction: 'ccw' })}
          />
          <Button
            icon="refresh"
            tooltip="Flip"
            onClick={() => ModuleAction('rotate', { direction: 'flip' })}
          />
        </>
      }
    >
      {Object.entries(props.available_builds).map(([typepath, build_data]) => (
        <ItemSelect
          key={typepath}
          name={build_data.name}
          is_selected={typepath === selected}
          display_src={build_data.display_src}
          item={typepath}
          select_item={select_item}
        />
      ))}
    </Section>
  );
};

const ItemSelect = (props: {
  name: string;
  item: string;
  is_selected: boolean;
  display_src: string;
  select_item: (item: string) => void;
}) => {
  const style = {
    border: props.is_selected ? '2px solid blue' : 'none',
    borderRadius: '2px',
    boxSizing: 'border-box',
    margin: '5px',
    padding: '1px',
    display: 'inline-block',
    cursor: 'pointer',
    maxWidth: '32px',
    maxHeight: '32px',
  };

  return (
    <Image
      src={props.display_src}
      // @ts-ignore
      title={props.name}
      style={style}
      onClick={() => props.select_item(props.item)}
    />
  );
};
