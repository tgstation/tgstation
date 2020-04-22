import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, Collapsible, Grid, LabeledList, NoticeBox, NumberInput, Section } from '../components';
import { Window } from '../layouts';

export const NaniteDiskBox = (props, context) => {
  const { data } = useBackend(context);
  const {
    has_disk,
    has_program,
    disk,
  } = data;

  if (!has_disk) {
    return (
      <NoticeBox>
        No disk inserted
      </NoticeBox>
    );
  }

  if (!has_program) {
    return (
      <NoticeBox>
        Inserted disk has no program
      </NoticeBox>
    );
  }

  return (
    <NaniteInfoBox program={disk} />
  );
};

export const NaniteInfoBox = (props, context) => {
  const { program } = props;

  const {
    name,
    desc,
    activated,
    use_rate,
    can_trigger,
    trigger_cost,
    trigger_cooldown,
    activation_code,
    deactivation_code,
    kill_code,
    trigger_code,
    timer_restart,
    timer_shutdown,
    timer_trigger,
    timer_trigger_delay,
  } = program;

  const extra_settings = program.extra_settings || [];

  return (
    <Section
      title={name}
      level={2}
      buttons={(
        <Box
          inline
          bold
          color={activated ? 'good' : 'bad'}>
          {activated ? 'Activated' : 'Deactivated'}
        </Box>
      )}>
      <Grid>
        <Grid.Column mr={1}>
          {desc}
        </Grid.Column>
        <Grid.Column size={0.5}>
          <LabeledList>
            <LabeledList.Item label="Use Rate">
              {use_rate}
            </LabeledList.Item>
            {!!can_trigger && (
              <Fragment>
                <LabeledList.Item label="Trigger Cost">
                  {trigger_cost}
                </LabeledList.Item>
                <LabeledList.Item label="Trigger Cooldown">
                  {trigger_cooldown}
                </LabeledList.Item>
              </Fragment>
            )}
          </LabeledList>
        </Grid.Column>
      </Grid>
      <Grid>
        <Grid.Column>
          <Section
            title="Codes"
            level={3}
            mr={1}>
            <LabeledList>
              <LabeledList.Item label="Activation">
                {activation_code}
              </LabeledList.Item>
              <LabeledList.Item label="Deactivation">
                {deactivation_code}
              </LabeledList.Item>
              <LabeledList.Item label="Kill">
                {kill_code}
              </LabeledList.Item>
              {!!can_trigger && (
                <LabeledList.Item label="Trigger">
                  {trigger_code}
                </LabeledList.Item>
              )}
            </LabeledList>
          </Section>
        </Grid.Column>
        <Grid.Column>
          <Section
            title="Delays"
            level={3}
            mr={1}>
            <LabeledList>
              <LabeledList.Item label="Restart">
                {timer_restart} s
              </LabeledList.Item>
              <LabeledList.Item label="Shutdown">
                {timer_shutdown} s
              </LabeledList.Item>
              {!!can_trigger && (
                <Fragment>
                  <LabeledList.Item label="Trigger">
                    {timer_trigger} s
                  </LabeledList.Item>
                  <LabeledList.Item label="Trigger Delay">
                    {timer_trigger_delay} s
                  </LabeledList.Item>
                </Fragment>
              )}
            </LabeledList>
          </Section>
        </Grid.Column>
      </Grid>
      <Section
        title="Extra Settings"
        level={3}>
        <LabeledList>
          {extra_settings.map(setting => {
            const naniteTypesDisplayMap = {
              number: <Fragment>{setting.value}{setting.unit}</Fragment>,
              text: setting.value,
              type: setting.value,
              boolean: (setting.value ? setting.true_text : setting.false_text),
            };
            return (
              <LabeledList.Item key={setting.name} label={setting.name}>
                {naniteTypesDisplayMap[setting.type]}
              </LabeledList.Item>
            );
          })}
        </LabeledList>
      </Section>
    </Section>
  );
};

export const NaniteCloudBackupList = (props, context) => {
  const { act, data } = useBackend(context);
  const cloud_backups = data.cloud_backups || [];
  return (
    cloud_backups.map(backup => (
      <Button
        fluid
        key={backup.cloud_id}
        content={"Backup #" + backup.cloud_id}
        textAlign="center"
        onClick={() => act('set_view', {
          view: backup.cloud_id,
        })} />
    ))
  );
};

export const NaniteCloudBackupDetails = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    current_view,
    disk,
    has_program,
    cloud_backup,
  } = data;

  const can_rule = (disk && disk.can_rule) || false;

  if (!cloud_backup) {
    return (
      <NoticeBox>
        ERROR: Backup not found
      </NoticeBox>
    );
  }

  const cloud_programs = data.cloud_programs || [];

  return (
    <Section
      title={"Backup #" + current_view}
      level={2}
      buttons={(
        !!has_program && (
          <Button
            icon="upload"
            content="Upload From Disk"
            color="good"
            onClick={() => act('upload_program')} />
        )
      )}>
      {cloud_programs.map(program => {
        const rules = program.rules || [];
        return (
          <Collapsible
            key={program.name}
            title={program.name}
            buttons={(
              <Button
                icon="minus-circle"
                color="bad"
                onClick={() => act('remove_program', {
                  program_id: program.id,
                })} />
            )}>
            <Section>
              <NaniteInfoBox program={program} />
              {!!can_rule && (
                <Section
                  mt={-2}
                  title="Rules"
                  level={2}
                  buttons={(
                    <Button
                      icon="plus"
                      content="Add Rule from Disk"
                      color="good"
                      onClick={() => act('add_rule', {
                        program_id: program.id,
                      })} />
                  )}>
                  {program.has_rules ? (
                    rules.map(rule => (
                      <Fragment key={rule.display}>
                        <Button
                          icon="minus-circle"
                          color="bad"
                          onClick={() => act('remove_rule', {
                            program_id: program.id,
                            rule_id: rule.id,
                          })} />
                        {rule.display}
                      </Fragment>
                    ))
                  ) : (
                    <Box color="bad">
                      No Active Rules
                    </Box>
                  )}
                </Section>
              )}
            </Section>
          </Collapsible>
        );
      })}
    </Section>
  );
};

export const NaniteCloudControl = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    has_disk,
    current_view,
    new_backup_id,
  } = data;

  return (
    <Window resizable>
      <Window.Content scrollable>
        <Section
          title="Program Disk"
          buttons={(
            <Button
              icon="eject"
              content="Eject"
              disabled={!has_disk}
              onClick={() => act('eject')} />
          )}>
          <NaniteDiskBox />
        </Section>
        <Section
          title="Cloud Storage"
          buttons={(
            current_view ? (
              <Button
                icon="arrow-left"
                content="Return"
                onClick={() => act('set_view', {
                  view: 0,
                })} />
            ) : (
              <Fragment>
                {"New Backup: "}
                <NumberInput
                  value={new_backup_id}
                  minValue={1}
                  maxValue={100}
                  stepPixelSize={4}
                  width="39px"
                  onChange={(e, value) => act('update_new_backup_value', {
                    value: value,
                  })} />
                <Button
                  icon="plus"
                  onClick={() => act('create_backup')} />
              </Fragment>
            )
          )}>
          {!data.current_view ? (
            <NaniteCloudBackupList />
          ) : (
            <NaniteCloudBackupDetails />
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
