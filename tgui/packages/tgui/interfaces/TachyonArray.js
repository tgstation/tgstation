import { Fragment } from 'inferno';
import { useBackend, useSharedState } from '../backend';
import { Button, Flex, LabeledList, NoticeBox, Section, Tabs } from '../components';
import { Window } from '../layouts';

export const TachyonArray = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    records = [],
  } = data;
  return (
    <Window resizable>
      <Window.Content scrollable>
        {!records.length ? (
          <NoticeBox>
            No Records
          </NoticeBox>
        ) : (
          <TachyonArrayContent />
        )}
      </Window.Content>
    </Window>
  );
};

export const TachyonArrayContent = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    records = [],
  } = data;
  const [
    activeRecordName,
    setActiveRecordName,
  ] = useSharedState(context, 'record', records[0]?.name);
  const activeRecord = records.find(record => {
    return record.name === activeRecordName;
  });
  return (
    <Section>
      <Flex>
        <Flex.Item>
          <Tabs vertical>
            {records.map(record => (
              <Tabs.Tab
                icon="file"
                key={record.name}
                selected={record.name === activeRecordName}
                onClick={() => setActiveRecordName(record.name)}>
                {record.name}
              </Tabs.Tab>
            ))}
          </Tabs>
        </Flex.Item>
        {activeRecord ? (
          <Flex.Item>
            <Section
              level="2"
              title={activeRecord.name}
              buttons={(
                <Fragment>
                  <Button.Confirm
                    icon="trash"
                    content="Delete"
                    color="bad"
                    onClick={() => act('delete_record', {
                      'ref': activeRecord.ref,
                    })} />
                  <Button
                    icon="print"
                    content="Print"
                    onClick={() => act('print_record', {
                      'ref': activeRecord.ref,
                    })} />
                </Fragment>
              )}>
              <LabeledList>
                <LabeledList.Item label="Timestamp">
                  {activeRecord.timestamp}
                </LabeledList.Item>
                <LabeledList.Item label="Coordinates">
                  {activeRecord.coordinates}
                </LabeledList.Item>
                <LabeledList.Item label="Displacement">
                  {activeRecord.displacement} seconds
                </LabeledList.Item>
                <LabeledList.Item label="Epicenter Radius">
                  {activeRecord.factual_epicenter_radius}
                  {activeRecord.theory_epicenter_radius
                  && " (Theoretical: "
                  + activeRecord.theory_epicenter_radius + ")"}
                </LabeledList.Item>
                <LabeledList.Item label="Outer Radius">
                  {activeRecord.factual_outer_radius}
                  {activeRecord.theory_outer_radius
                  && " (Theoretical: "
                  + activeRecord.theory_outer_radius + ")"}
                </LabeledList.Item>
                <LabeledList.Item label="Shockwave Radius">
                  {activeRecord.factual_shockwave_radius}
                  {activeRecord.theory_shockwave_radius
                  && " (Theoretical: "
                  + activeRecord.theory_shockwave_radius + ")"}
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Flex.Item>
        ) : (
          <Flex.Item grow={1} basis={0}>
            <NoticeBox>
              No Record Selected
            </NoticeBox>
          </Flex.Item>
        )}
      </Flex>
    </Section>
  );
};
