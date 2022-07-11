import { useBackend } from '../backend';
import { Button, ColorBox, Stack, Section, Table } from '../components';
import { NtosWindow } from '../layouts';

export const NtosMain = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    device_theme,
    show_imprint,
    programs = [],
    has_light,
    light_on,
    comp_light_color,
    removable_media = [],
    cardholder,
    login = [],
    proposed_login = [],
    disk,
    disk_name,
    disk_programs = [],
    pai,
  } = data;
  return (
    <NtosWindow
      title={
        (device_theme === 'syndicate' && 'Syndix Main Menu') || 'NtOS Main Menu'
      }
      theme={device_theme}
      width={400}
      height={500}>
      <NtosWindow.Content scrollable>
        {Boolean(has_light || removable_media.length) && (
          <Section>
            <Stack>
              {!!has_light && (
                <Stack.Item grow>
                  <Button
                    width="144px"
                    icon="lightbulb"
                    selected={light_on}
                    onClick={() => act('PC_toggle_light')}>
                    Flashlight: {light_on ? 'ON' : 'OFF'}
                  </Button>
                  <Button ml={1} onClick={() => act('PC_light_color')}>
                    Color:
                    <ColorBox ml={1} color={comp_light_color} />
                  </Button>
                </Stack.Item>
              )}
              {removable_media.map((device) => (
                <Stack.Item key={device}>
                  <Button
                    fluid
                    icon="eject"
                    content={device}
                    onClick={() => act('PC_Eject_Disk', { name: device })}
                    disabled={!device}
                  />
                </Stack.Item>
              ))}
            </Stack>
          </Section>
        )}
        {!!(cardholder && show_imprint) && (
          <Section
            title="User Login"
            buttons={
              <>
                <Button
                  icon="eject"
                  content="Eject ID"
                  disabled={!proposed_login.IDName}
                  onClick={() => act('PC_Eject_Disk', { name: 'ID' })}
                />
                <Button
                  icon="dna"
                  content="Imprint ID"
                  disabled={
                    !proposed_login.IDName ||
                    (proposed_login.IDName === login.IDName &&
                      proposed_login.IDJob === login.IDJob)
                  }
                  onClick={() => act('PC_Imprint_ID', { name: 'ID' })}
                />
              </>
            }>
            <Table>
              <Table.Row>
                ID Name: {login.IDName} ({proposed_login.IDName})
              </Table.Row>
              <Table.Row>
                Assignment: {login.IDJob} ({proposed_login.IDJob})
              </Table.Row>
            </Table>
          </Section>
        )}
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
                    onClick={() =>
                      act('PC_Pai_Interact', {
                        option: 'eject',
                      })
                    }
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
                    onClick={() =>
                      act('PC_Pai_Interact', {
                        option: 'interact',
                      })
                    }
                  />
                </Table.Cell>
              </Table.Row>
            </Table>
          </Section>
        )}
        <Section title="Programs">
          <Table>
            {programs.map((program) => (
              <Table.Row key={program.name}>
                <Table.Cell>
                  <Button
                    fluid
                    color={program.alert ? 'yellow' : 'transparent'}
                    icon={program.icon}
                    content={program.desc}
                    onClick={() =>
                      act('PC_runprogram', {
                        name: program.name,
                        is_disk: false,
                      })
                    }
                  />
                </Table.Cell>
                <Table.Cell collapsing width="18px">
                  {!!program.running && (
                    <Button
                      color="transparent"
                      icon="times"
                      tooltip="Close program"
                      tooltipPosition="left"
                      onClick={() =>
                        act('PC_killprogram', {
                          name: program.name,
                        })
                      }
                    />
                  )}
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
        {!!disk && (
          <Section
            // pain
            title={
              disk_name
                ? disk_name.substring(0, disk_name.length - 5)
                : 'No Job Disk Inserted'
            }
            buttons={
              <Button
                icon="eject"
                content="Eject Disk"
                disabled={!disk_name}
                onClick={() => act('PC_Eject_Disk', { name: 'remove_disk' })}
              />
            }>
            <Table>
              {disk_programs.map((program) => (
                <Table.Row key={program.name}>
                  <Table.Cell>
                    <Button
                      fluid
                      color={program.alert ? 'yellow' : 'transparent'}
                      icon={program.icon}
                      content={program.desc}
                      onClick={() =>
                        act('PC_runprogram', {
                          name: program.name,
                          is_disk: true,
                        })
                      }
                    />
                  </Table.Cell>
                  <Table.Cell collapsing width="18px">
                    {!!program.running && (
                      <Button
                        color="transparent"
                        icon="times"
                        tooltip="Close program"
                        tooltipPosition="left"
                        onClick={() =>
                          act('PC_killprogram', {
                            name: program.name,
                          })
                        }
                      />
                    )}
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          </Section>
        )}
      </NtosWindow.Content>
    </NtosWindow>
  );
};
