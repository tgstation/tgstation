import { useBackend, useSharedState } from '../backend';
import { Button, LabeledList, NoticeBox, Section, Tabs } from '../components';
import { Window } from '../layouts';

export const Microscope = (props, context) => {
  const { act, data } = useBackend(context);
  const [tab, setTab] = useSharedState(context, 'tab', 1);
  const {
    has_dish,
    cell_lines = [],
    viruses = [],
  } = data;
  return (
    <Window resizable>
      <Window.Content scrollable>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Dish Sample">
              <Button
                icon="eject"
                content="Eject"
                disabled={!has_dish}
                onClick={() => act('eject_petridish')} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Tabs>
          <Tabs.Tab
            icon="microscope"
            lineHeight="23px"
            selected={tab === 1}
            onClick={() => setTab(1)}>
            Micro-Organisms ({cell_lines.length})
          </Tabs.Tab>
          <Tabs.Tab
            icon="microscope"
            lineHeight="23px"
            selected={tab === 2}
            onClick={() => setTab(2)}>
            Viruses ({viruses.length})
          </Tabs.Tab>
        </Tabs>
        {tab === 1 && (
          <Organisms cell_lines={cell_lines} />
        )}
        {tab === 2 && (
          <Viruses viruses={viruses} />
        )}
      </Window.Content>
    </Window>
  );
};

const Organisms = (props, context) => {
  const { cell_lines } = props;
  const { act, data } = useBackend(context);
  if (!cell_lines.length) {
    return (
      <NoticeBox>
        No micro-organisms found
      </NoticeBox>
    );
  }
  return cell_lines.map(cell_line => {
    return (
      <Section
        key={cell_line.desc}
        title={cell_line.desc}>
        <LabeledList>
          <LabeledList.Item label="Growth Rate">
            {cell_line.growth_rate}
          </LabeledList.Item>
          <LabeledList.Item label="Virus Suspectibility">
            {cell_line.suspectibility}
          </LabeledList.Item>
          <LabeledList.Item label="Required Reagents">
            {cell_line.requireds}
          </LabeledList.Item>
          <LabeledList.Item label="Supplementary Reagents">
            {cell_line.supplementaries}
          </LabeledList.Item>
          <LabeledList.Item label="Suppresive reagents">
            {cell_line.suppressives}
          </LabeledList.Item>
        </LabeledList>
      </Section>
    );
  });
};

const Viruses = (props, context) => {
  const { viruses } = props;
  const { act } = useBackend(context);
  if (!viruses.length) {
    return (
      <NoticeBox>
        No viruses found
      </NoticeBox>
    );
  }
  return viruses.map(virus => {
    return (
      <Section
        key={virus.desc}
        title={virus.desc} />
    );
  });
};
