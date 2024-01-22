import { toTitleCase } from 'common/string';

import { useBackend } from '../backend';
import {
  Button,
  Icon,
  Image,
  NoticeBox,
  Section,
  Stack,
  Table,
} from '../components';
import { Window } from '../layouts';
import { Material } from './Fabrication/Types';

type IconData = {
  id: string;
  icon: string;
};

type Alloy = {
  name: string;
  id: string;
};

type ProcessingConsoleProps = {
  materials: Material[];
  materialIcons: IconData[];
  selectedMaterial: string | null;
  alloys: Alloy[];
  alloyIcons: IconData[];
  selectedAlloy: string | null;
  state: boolean;
};

export const ProcessingConsole = (props: any) => {
  const { act, data } = useBackend<ProcessingConsoleProps>();
  const { state } = data;

  return (
    <Window title="Processing Unit Console" width={535} height={485}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item grow basis={0}>
            <Stack fill>
              <Stack.Item grow basis={0}>
                <Section fill scrollable textAlign="center" title="Materials">
                  <MaterialSelection />
                </Section>
              </Stack.Item>
              <Stack.Item grow basis={0}>
                <Section fill scrollable title="Alloys" textAlign="center">
                  <AlloySelection />
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <Button
              color={state ? 'bad' : 'good'}
              textAlign="center"
              py={1}
              fluid
              bold
              onClick={() => act('toggle')}
            >
              {state ? 'Deactivate' : 'Activate'}
            </Button>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const MaterialSelection = (props: any) => {
  const { act, data } = useBackend<ProcessingConsoleProps>();
  const { materials, materialIcons, selectedMaterial } = data;

  return materials.length > 0 ? (
    <Table>
      {materials.map((material) => (
        <DisplayRow
          key={material.name}
          name={material.name}
          icon={materialIcons.find((icon) => icon.id === material.ref)?.icon}
          selected={selectedMaterial === material.name}
          onSelect={() => act('setMaterial', { value: material.ref })}
        />
      ))}
    </Table>
  ) : (
    <NoticeBox danger>No material recipes found!</NoticeBox>
  );
};

const AlloySelection = (props: any) => {
  const { act, data } = useBackend<ProcessingConsoleProps>();
  const { alloys, alloyIcons, selectedAlloy } = data;

  return alloys.length > 0 ? (
    <Table>
      {alloys.map((alloy) => (
        <DisplayRow
          key={alloy.id}
          name={alloy.name}
          icon={alloyIcons.find((icon) => icon.id === alloy.id)?.icon}
          selected={selectedAlloy === alloy.id}
          onSelect={() => act('setAlloy', { value: alloy.id })}
        />
      ))}
    </Table>
  ) : (
    <NoticeBox danger>No alloy recipes found!</NoticeBox>
  );
};

type DisplayRowProps = {
  name: string;
  icon: string | undefined;
  selected: boolean;
  onSelect: () => void;
};

const DisplayRow = (props: DisplayRowProps) => {
  const { name, icon, selected, onSelect } = props;

  return (
    <Table.Row collapsing className="candystripe">
      <Table.Cell collapsing pl={1}>
        {icon ? (
          <Image
            m={1}
            width="24px"
            height="24px"
            verticalAlign="middle"
            src={`data:image/jpeg;base64,${icon}`}
          />
        ) : (
          <Icon name="circle-question" />
        )}
      </Table.Cell>
      <Table.Cell textAlign="left">{toTitleCase(name)}</Table.Cell>
      <Table.Cell collapsing pr={1}>
        <Button.Checkbox
          color="transparent"
          checked={selected}
          onClick={() => onSelect()}
        />
      </Table.Cell>
    </Table.Row>
  );
};
