import { useBackend } from '../../backend';
import { Button, Dropdown, Section, Stack } from '../../components';
import { Window } from '../../layouts';

export const ConstructionForklift = (props: any) => {
  const { act, data } = useBackend<ConstructionForkliftData>();

  const setActiveModule = (module_ref_string: string) => {
    act('set-active', {
      new_module_ref: module_ref_string,
    });
  };

  const selector = (
    <ModuleSelector
      activeRef={data.modules.active_ref}
      available={data.modules.available}
      setActive={setActiveModule}
    />
  );

  return (
    <Window title="Forklift Management Console">
      <Window.Content>
        {`Active: ${data.modules.active_ref}`}
        {selector}
        <Button icon="wrench" onClick={() => act('interact-module')}>
          {`Configure ${GetActiveModuleName(
            data.modules.available,
            data.modules.active_ref,
          )}`}
        </Button>
      </Window.Content>
    </Window>
  );
};

const GetActiveModuleName = (available: AvailableModules, active: string) => {
  for (const [module_ref, module_name] of Object.entries(available)) {
    if (module_ref === active) {
      return module_name;
    }
  }
  return undefined;
};

const ModuleSelector = (props: {
  activeRef: string;
  available: AvailableModules;
  setActive: (module_ref: string) => void;
}) => {
  let activeModuleName = GetActiveModuleName(props.available, props.activeRef);

  let handleSetActive = (module_name: string) => {
    let module_ref: string | undefined;
    // iterate over the available modules, and find the ref based on the module name
    for (const [ref, name] of Object.entries(props.available)) {
      if (name === module_name) {
        module_ref = ref;
        break;
      }
    }
    if (module_ref === undefined) {
      throw new Error('Module not found');
    }

    props.setActive(module_ref);
  };

  return (
    <Dropdown
      options={Object.values(props.available)}
      selected={activeModuleName}
      onSelected={handleSetActive}
    />
  );
};

const BuildPathSelector = (props: {
  available: BuildTarget[];
  selected: BuildTarget;
  setSelected: (path: string) => void;
}) => {
  let handleSetSelected = (path: string) => {
    props.setSelected(path);
  };

  const buttonStyle = {
    width: '100%',
    textAlign: 'left',
    borderRadius: '5px',
  };

  return (
    <Section title="Build Target">
      <Stack fill vertical>
        {props.available.map((buildTarget) => (
          <Button
            key={buildTarget.type}
            onClick={() => handleSetSelected(buildTarget.type)}
            selected={props.selected.type === buildTarget.type}
            style={buttonStyle}
          >
            {buildTarget.name}
          </Button>
        ))}
      </Stack>
    </Section>
  );
};
