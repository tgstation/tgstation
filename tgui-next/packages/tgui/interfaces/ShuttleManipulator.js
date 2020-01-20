import { map } from 'common/collections';
import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Button, LabeledList, Section, Table, Tabs } from '../components';

export const ShuttleManipulator = props => {
  const { act, data } = useBackend(props);
  const shuttles = data.shuttles || [];
  const templateObject = data.templates || {};
  const selected = data.selected || {};
  const existingShuttle = data.existing_shuttle || {};
  return (
    <Tabs>
      <Tabs.Tab
        key="status"
        label="Status">
        {() => (
          <Section>
            <Table>
              {shuttles.map(shuttle => (
                <Table.Row key={shuttle.id}>
                  <Table.Cell>
                    <Button
                      content="JMP"
                      key={shuttle.id}
                      onClick={() => act('jump_to', {
                        type: 'mobile',
                        id: shuttle.id,
                      })} />
                  </Table.Cell>
                  <Table.Cell>
                    <Button
                      content="Fly"
                      key={shuttle.id}
                      disabled={!shuttle.can_fly}
                      onClick={() => act('fly', {
                        id: shuttle.id,
                      })} />
                  </Table.Cell>
                  <Table.Cell>
                    {shuttle.name}
                  </Table.Cell>
                  <Table.Cell>
                    {shuttle.id}
                  </Table.Cell>
                  <Table.Cell>
                    {shuttle.status}
                  </Table.Cell>
                  <Table.Cell>
                    {shuttle.mode}
                    {!!shuttle.timer && (
                      <Fragment>
                        ({shuttle.timeleft})
                        <Button
                          content="Fast Travel"
                          key={shuttle.id}
                          disabled={!shuttle.can_fast_travel}
                          onClick={() => act('fast_travel', {
                            id: shuttle.id,
                          })} />
                      </Fragment>
                    )}
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          </Section>
        )}
      </Tabs.Tab>
      <Tabs.Tab
        key="templates"
        label="Templates">
        {() => (
          <Section>
            <Tabs>
              {map((template, templateId) => {
                const templates = template.templates || [];
                return (
                  <Tabs.Tab
                    key={templateId}
                    label={template.port_id}>
                    {templates.map(actualTemplate => {
                      const isSelected = (
                        actualTemplate.shuttle_id === selected.shuttle_id
                      );
                      // Whoever made the structure being sent is an asshole
                      return (
                        <Section
                          title={actualTemplate.name}
                          level={2}
                          key={actualTemplate.shuttle_id}
                          buttons={(
                            <Button
                              content={isSelected ? 'Selected' : 'Select'}
                              selected={isSelected}
                              onClick={() => act('select_template', {
                                shuttle_id: actualTemplate.shuttle_id,
                              })} />
                          )}>
                          {(!!actualTemplate.description
                            || !!actualTemplate.admin_notes
                          ) && (
                            <LabeledList>
                              {!!actualTemplate.description && (
                                <LabeledList.Item label="Description">
                                  {actualTemplate.description}
                                </LabeledList.Item>
                              )}
                              {!!actualTemplate.admin_notes && (
                                <LabeledList.Item label="Admin Notes">
                                  {actualTemplate.admin_notes}
                                </LabeledList.Item>
                              )}
                            </LabeledList>
                          )}
                        </Section>
                      );
                    })}
                  </Tabs.Tab>
                );
              })(templateObject)}
            </Tabs>
          </Section>
        )}
      </Tabs.Tab>
      <Tabs.Tab
        key="modification"
        label="Modification">
        <Section>
          {selected ? (
            <Fragment>
              <Section
                level={2}
                title={selected.name}>
                {(!!selected.description || !!selected.admin_notes) && (
                  <LabeledList>
                    {!!selected.description && (
                      <LabeledList.Item label="Description">
                        {selected.description}
                      </LabeledList.Item>
                    )}
                    {!!selected.admin_notes && (
                      <LabeledList.Item label="Admin Notes">
                        {selected.admin_notes}
                      </LabeledList.Item>
                    )}
                  </LabeledList>
                )}
              </Section>
              {existingShuttle ? (
                <Section
                  level={2}
                  title={'Existing Shuttle: ' + existingShuttle.name}>
                  <LabeledList>
                    <LabeledList.Item
                      label="Status"
                      buttons={(
                        <Button
                          content="Jump To"
                          onClick={() => act('jump_to', {
                            type: 'mobile',
                            id: existingShuttle.id,
                          })} />
                      )}>
                      {existingShuttle.status}
                      {!!existingShuttle.timer && (
                        <Fragment>
                          ({existingShuttle.timeleft})
                        </Fragment>
                      )}
                    </LabeledList.Item>
                  </LabeledList>
                </Section>
              ) : (
                <Section
                  level={2}
                  title="Existing Shuttle: None" />
              )}
              <Section
                level={2}
                title="Status">
                <Button
                  content="Preview"
                  onClick={() => act('preview', {
                    shuttle_id: selected.shuttle_id,
                  })} />
                <Button
                  content="Load"
                  color="bad"
                  onClick={() => act('load', {
                    shuttle_id: selected.shuttle_id,
                  })} />
              </Section>
            </Fragment>
          ) : 'No shuttle selected'}
        </Section>
      </Tabs.Tab>
    </Tabs>
  );
};
