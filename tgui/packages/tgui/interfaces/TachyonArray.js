import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Button, Section, Tabs, LabeledList } from '../components';

export const TachyonArray = props => {
  const { act, data } = useBackend(props);
  const {
    records,
  } = data;
  return (
    <Section title="Stored Records">
      <Tabs vertical>
        {records.map(record => {
          return (
            <Tabs.Tab
              key={record.name}
              label={record.name}>
              <Section
                title={record.name}
                buttons={(
                  <Fragment>
                    <Button.Confirm
                      icon="times"
                      content="Delete"
                      color="bad"
                      onClick={() => act('delete_record')} />
                    <Button
                      icon="print"
                      content="Print"
                      onClick={() => act('print_record')} />
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
                    {record.theoretical_epicenter_radius
                      ? " (Theoretical: [record.theoretical_epicenter_radius])"
                      : ""}
                  </LabeledList.Item>
                  <LabeledList.Item label="Outer Radius">
                    {record.factual_outer_radius}
                    {record.theoretical_outer_radius
                      ? " (Theoretical: [record.theoretical_outer_radius])"
                      : ""}
                  </LabeledList.Item>
                  <LabeledList.Item label="Shockwave Radius">
                    {record.factual_shockwave_radius}
                    {record.theoretical_shockwave_radius
                      ? " (Theoretical: [record.theoretical_shockwave_radius])"
                      : ""}
                  </LabeledList.Item>
                </LabeledList>
              </Section>
            </Tabs.Tab>
          );
        },
        )}
      </Tabs>
    </Section>
  );
};
