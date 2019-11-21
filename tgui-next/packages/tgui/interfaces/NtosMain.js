import { Fragment } from 'inferno';
import { act } from '../byond';
import { Button, ColorBox, Section, Table } from '../components';

const PROGRAM_ICONS = {
  compconfig: 'cog',
  ntndownloader: 'download',
  filemanager: 'folder',
  smmonitor: 'radiation',
  alarmmonitor: 'bell',
  cardmod: 'id-card',
  ntnrc_client: 'comment-alt',
  nttransfer: 'exchange-alt',
  powermonitor: 'plug',
};

export const NtosMain = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  const {
    programs = [],
    has_light,
    light_on,
    comp_light_color,
  } = data;
  return (
    <Fragment>
      {!!has_light && (
        <Section>
          <Button
            width="144px"
            icon="lightbulb"
            selected={light_on}
            onClick={() => act(ref, 'PC_toggle_light')}>
            Flashlight: {light_on ? 'ON' : 'OFF'}
          </Button>
          <Button
            ml={1}
            onClick={() => act(ref, 'PC_light_color')}>
            Color:
            <ColorBox ml={1} color={comp_light_color} />
          </Button>
        </Section>
      )}
      <Section title="Programs">
        <Table>
          {programs.map(program => (
            <Table.Row key={program.name}>
              <Table.Cell>
                <Button
                  fluid
                  lineHeight="24px"
                  color="transparent"
                  icon={PROGRAM_ICONS[program.name] || 'window-maximize-o'}
                  content={program.desc}
                  onClick={() => act(ref, 'PC_runprogram', {
                    name: program.name,
                  })} />
              </Table.Cell>
              <Table.Cell collapsing width={3}>
                {!!program.running && (
                  <Button
                    lineHeight="24px"
                    color="transparent"
                    icon="times"
                    tooltip="Close program"
                    tooltipPosition="left"
                    onClick={() => act(ref, 'PC_killprogram', {
                      name: program.name,
                    })} />
                )}
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      </Section>
    </Fragment>
  );
};
