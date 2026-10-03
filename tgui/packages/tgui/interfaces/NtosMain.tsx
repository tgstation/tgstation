import { Button, ColorBox, Section, Stack, Table } from 'tgui-core/components';

import { NtosWindow } from '../layouts';
import { useNtos } from './NtosCore';

export enum alert_relevancies {
  ALERT_RELEVANCY_SAFE,
  ALERT_RELEVANCY_WARN,
  ALERT_RELEVANCY_PERTINENT,
}

export const NtosMain = (props) => {
  const { system, api } = useNtos();
  const {
    alert_style,
    alert_color,
    alert_name,
    device_theme,
    show_imprint,
    programs = [],
    has_light,
    is_light_on,
    light_color,
    removable_media = [],
    login,
    proposed_login,
    pai,
  } = system;
  const {
    run_program,
    eject_disk,
    switch_light_color,
    toggle_light,
    imprint_id,
    interact_pai,
  } = api;

  const filtered_programs = programs.filter(
    (program) => program.header_program,
  );

  return (
    <NtosWindow
      title={
        (device_theme === 'syndicate' && 'Syndix Main Menu') || 'NtOS Main Menu'
      }
      width={400}
      height={500}
      z
    >
      <NtosWindow.Content scrollable>
        {Boolean(
          removable_media.length ||
            programs.some((program) => program.header_program),
        ) && (
          <Section>
            <Stack>
              {filtered_programs.map((app) => (
                <Stack.Item key={app.name}>
                  <Button
                    content={app.desc}
                    icon={app.icon}
                    onClick={() => run_program(app.name)}
                  />
                </Stack.Item>
              ))}
              <Stack.Item right={0}>
                <Button
                  className={
                    alert_style === alert_relevancies.ALERT_RELEVANCY_PERTINENT
                      ? 'alertIndicator alertBlink'
                      : 'alertIndicator'
                  }
                  textColor={
                    alert_style === alert_relevancies.ALERT_RELEVANCY_SAFE
                      ? alert_color
                      : '#000000'
                  }
                  backgroundColor={
                    alert_style === alert_relevancies.ALERT_RELEVANCY_SAFE
                      ? '#0000000'
                      : alert_color
                  }
                  tooltip="The current alert level. Indicator becomes more intense when there is a threat, moreso if your department is responsible for handling it."
                >
                  {alert_name}
                </Button>
              </Stack.Item>
            </Stack>
            <Stack>
              {removable_media.map((device) => (
                <Stack.Item key={device} mt={1}>
                  <Button
                    fluid
                    icon="eject"
                    content={device}
                    onClick={() => eject_disk(device)}
                    disabled={!device}
                  />
                </Stack.Item>
              ))}
            </Stack>
          </Section>
        )}
        <Section
          title="Details"
          buttons={
            <>
              {!!has_light && (
                <>
                  <Button onClick={() => switch_light_color()}>
                    <ColorBox color={light_color} />
                  </Button>
                  <Button
                    icon="lightbulb"
                    color={is_light_on ? 'good' : 'bad'}
                    selected={is_light_on}
                    onClick={() => toggle_light()}
                  />
                </>
              )}
              <Button
                icon="eject"
                content="Eject ID"
                disabled={!proposed_login.is_id_inserted}
                onClick={() => eject_disk('ID')}
              />
              {!!show_imprint && (
                <Button
                  icon="dna"
                  content="Imprint ID"
                  disabled={
                    !proposed_login.id_name ||
                    (proposed_login.id_name === login.id_name &&
                      proposed_login.id_job === login.id_job)
                  }
                  onClick={() => imprint_id()}
                />
              )}
            </>
          }
        >
          <Table>
            <Table.Row>
              ID Name:{' '}
              {show_imprint
                ? login.id_name +
                  ' ' +
                  (proposed_login.id_name ? `(${proposed_login.id_name})` : '')
                : (proposed_login.id_name ?? '')}
            </Table.Row>
            <Table.Row>
              Assignment:{' '}
              {show_imprint
                ? login.id_job +
                  ' ' +
                  (proposed_login.id_job ? `(${proposed_login.id_job})` : '')
                : (proposed_login.id_job ?? '')}
            </Table.Row>
          </Table>
        </Section>
        {!!pai && (
          <Section title="pAI">
            <Table>
              <Table.Row>
                <Table.Cell>
                  <Button
                    fluid
                    icon="eject"
                    color="transparent"
                    content="Eject pAI"
                    onClick={() => interact_pai('eject')}
                  />
                </Table.Cell>
              </Table.Row>
              <Table.Row>
                <Table.Cell>
                  <Button
                    fluid
                    icon="cat"
                    color="transparent"
                    content="Configure pAI"
                    onClick={() => interact_pai('interact')}
                  />
                </Table.Cell>
              </Table.Row>
            </Table>
          </Section>
        )}
        <ProgramsTable />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

const ProgramsTable = (props) => {
  const { system, api } = useNtos();
  const { programs = [] } = system;
  const { kill_program, run_program } = api;

  // add the program filename to this list to have it excluded from the main menu program list table
  const filtered_programs = programs.filter(
    (program) => !program.header_program,
  );

  return (
    <Section title="Programs">
      <Table>
        {filtered_programs.map((program) => (
          <Table.Row key={program.name}>
            <Table.Cell>
              <Button
                fluid
                color={program.alert ? 'yellow' : 'transparent'}
                icon={program.icon}
                content={program.desc}
                onClick={() => run_program(program.name)}
              />
            </Table.Cell>
            <Table.Cell collapsing width="18px">
              {!!program.idle && (
                <Button
                  color="transparent"
                  icon="times"
                  tooltip="Close program"
                  tooltipPosition="left"
                  onClick={() => kill_program(program.name)}
                />
              )}
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};
