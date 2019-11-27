import { map } from 'common/collections';
import { Fragment } from 'inferno';
import { act } from '../byond';
import { Button, LabeledList, Section, Tabs } from '../components';

export const ShuttleManipulator = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
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
            <table>
              {shuttles.map(shuttle => (
                <tr key={shuttle.id}>
                  <td>
                    <Button
                      content="JMP"
                      key={shuttle.id}
                      onClick={() => act(ref, 'jump_to', {type: "mobile", id: shuttle.id})}
                    />
                  </td>
                  <td>
                    <Button
                      content="Fly"
                      key={shuttle.id}
                      disabled={!shuttle.can_fly}
                      onClick={() => act(ref, 'fly', {id: shuttle.id})}
                    />
                  </td>
                  <td>
                    {shuttle.name}
                  </td>
                  <td>
                    {shuttle.id}
                  </td>
                  <td>
                    {shuttle.status}
                  </td>
                  <td>
                    {shuttle.mode}
                    {!!shuttle.timer && (
                      <Fragment>
                        ({shuttle.timeleft})
                        <Button
                          content="Fast Travel"
                          key={shuttle.id}
                          disabled={!shuttle.can_fast_travel}
                          onClick={() => act(ref, 'fast_travel', {id: shuttle.id})}
                        />
                      </Fragment>
                    )}
                  </td>
                </tr>
              ))}
            </table>
          </Section>
        )}
      </Tabs.Tab>
      <Tabs.Tab
        key="templates"
        label="Templates"
      >
        {() => (
          <Section>
            <Tabs>
              {map((template, templateId) => {
                const templates = template.templates || [];
                return (
                  <Tabs.Tab
                    key={templateId}
                    label={template.port_id}
                  >
                    {templates.map(actualTemplate => {
                      const isSelected = (actualTemplate.shuttle_id === selected.shuttle_id);
                      return ( // Whoever made the structure being sent is an asshole
                        <Section
                          title={actualTemplate.name}
                          level={2}
                          key={actualTemplate.shuttle_id}
                          buttons={(
                            <Button
                              content={isSelected ? 'Selected' : 'Select'}
                              selected={isSelected}
                              onClick={() => act(ref, 'select_template', {shuttle_id: actualTemplate.shuttle_id})} />
                          )}>
                          {(!!actualTemplate.description || !!actualTemplate.admin_notes) && (
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
        label="Modification"
      >
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
                          onClick={() => act(ref, 'jump_to', {type: "mobile", id: existingShuttle.id})}
                        />
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
                  onClick={() => act(ref, 'preview', {shuttle_id: selected.shuttle_id})} />
                <Button
                  content="Load"
                  color="bad"
                  onClick={() => act(ref, 'load', {shuttle_id: selected.shuttle_id})} />
              </Section>
            </Fragment>
          ) : "No shuttle selected"}
        </Section>
      </Tabs.Tab>
    </Tabs>
  );
};
