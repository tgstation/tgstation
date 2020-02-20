import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Button, Section, NoticeBox, Tabs, LabeledList } from '../components';

export const TachyonArray = props => {
  const { act, data } = useBackend(props);
  const {
    records,
  } = data;
  return (
    <Section>
      {!records.length ? (
        <NoticeBox textAlign="center">
          No records available
        </NoticeBox>
      ) : (
        <Tabs vertical>
          {records.map(record => {
            return (
              <Tabs.Tab
                icon="file"
                key={record.name}
                label={record.name}>
                <Section
                  level="2"
                  title={record.name}
                  buttons={(
                    <Fragment>
                      <Button
                        icon="times"
                        content="Delete"
                        color="bad"
                        onClick={() => act('delete_record', {
                          'ref': record.ref,
                        })} />
                      <Button
                        icon="print"
                        content="Print"
                        onClick={() => act('print_record', {
                          'ref': record.ref,
                        })} />
                    </Fragment>
                  )}>
                  <LabeledList>
                    <LabeledList.Item label="Timestamp">
                      {record.timestamp}
                    </LabeledList.Item>
                    <LabeledList.Item label="Coordinates">
                      {record.coordinates}
                    </LabeledList.Item>
                    <LabeledList.Item label="Displacement">
                      {record.displacement} seconds
                    </LabeledList.Item>
                    <LabeledList.Item label="Epicenter Radius">
                      {record.factual_epicenter_radius}
                      {record.theory_epicenter_radius
                        ? " (Theoretical: [record.theory_epicenter_radius])"
                        : "" }
                    </LabeledList.Item>
                    <LabeledList.Item label="Outer Radius">
                      {record.factual_outer_radius}
                      {record.theory_outer_radius
                        ? " (Theoretical: [record.theory_outer_radius])"
                        : "" }
                    </LabeledList.Item>
                    <LabeledList.Item label="Shockwave Radius">
                      {record.factual_shockwave_radius}
                      {record.theory_shockwave_radius
                        ? " (Theoretical: [record.theory_shockwave_radius])"
                        : "" }
                    </LabeledList.Item>
                  </LabeledList>
                </Section>
              </Tabs.Tab>
            );
          },
          )}
        </Tabs>
      )}
    </Section>
  );
};
