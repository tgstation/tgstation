import { useBackend } from '../backend';
import { Button, Box, Section, NoticeBox, TimeDisplay, Flex, Icon, Table } from '../components';
import { Window } from '../layouts';
import { Fragment } from 'inferno';
import { FlexItem } from '../components/Flex';

export const SkillStation = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    working,
    timeleft,
    error,
    current = [],
    slots_used,
    slots_max,
    skillchip_ready,
    implantable,
    implantable_reason,
    skill_name,
    skill_desc,
    skill_icon,
    skill_cost,
  } = data;
  let skillchip_section_content;
  if (!skillchip_ready) {
    // I guess could use something better
    skillchip_section_content = "Insert a skillchip to continue.";
  } else {
    skillchip_section_content = (
      <Flex spacing={1}>
        <FlexItem>
          <Icon mt={2} mr={1} size={3} name={skill_icon} />
        </FlexItem>
        <Flex.Item>
          <Box bold mb={1}>{skill_name}</Box>
          <Box italic mb={1}>{skill_desc}</Box>
          <Box>Complexity: {skill_cost}</Box>
          {!!implantable_reason && (
            <Box
              color={implantable ? "good" : "bad"}>
              {implantable_reason}
            </Box>)}
        </Flex.Item>
        <Flex.Item align="center">
          <Button
            disabled={!implantable}
            onClick={() => act("implant")}>Implant
          </Button>
          <Button onClick={() => act("eject")}>Eject</Button>
        </Flex.Item>
      </Flex>);
  }
  return (
    <Window
      title="Skillsoft Station"
      width={500}
      height={300}
      resizable >
      <Window.Content>
        {!!error && (<NoticeBox>{error}</NoticeBox>)}
        {!!working && (
          <NoticeBox>
            <Box>Operation in progress. Please do not leave the chamber.</Box>
            <Box>Time Left : <TimeDisplay auto="down" value={timeleft} /></Box>
          </NoticeBox>)}
        {!working && (<Section>{skillchip_section_content}</Section>)}
        <Section
          title="Current skillchips"
          buttons={<Fragment>{slots_used}/{slots_max}</Fragment>}>
          {!current.length && "No skillchips detected."}
          {!!current.length && (
            <Table>
              <Table.Row header>
                <Table.Cell>Chip</Table.Cell>
                <Table.Cell>Complexity</Table.Cell>
                <Table.Cell>Status</Table.Cell>
                <Table.Cell>Actions</Table.Cell>
              </Table.Row>
              {current.map(skill => (
                <Table.Row key={skill}>
                  <Table.Cell>
                    <Icon mr={1} name={skill.icon} />
                    {skill.name}
                  </Table.Cell>
                  <Table.Cell>
                    {skill.cost}
                  </Table.Cell>
                  <Table.Cell>
                    {!skill.active && (
                      <Icon name="exclamation-triangle" color="bad" />
                    )}
                    {!!skill.active && (
                      <Icon name="check" color="good" />
                    )}
                  </Table.Cell>
                  <Table.Cell>
                    {!working && (
                      <Button
                        onClick={() => act("remove", { "ref": skill.ref })}
                        icon="trash"
                        content="Extract" />)}
                  </Table.Cell>
                </Table.Row>))}
            </Table>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
