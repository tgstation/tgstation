import { toFixed } from 'common/math';
import { useBackend } from '../backend';
import { Box, Button, Flex, Icon, LabeledList, NoticeBox, Section, Stack, Table } from '../components';
import { Window } from '../layouts';

export const InsertedSkillchip = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    skillchip_ready,
    slot_use,
    slots_used,
    slots_max,
    implantable_reason,
    implantable,
    complexity,
    skill_name,
    skill_desc,
    skill_icon,
    working,
  } = data;

  if (!skillchip_ready) {
    return (
      (!working && (
        <NoticeBox
          info>
          Please insert a skillchip.
        </NoticeBox>
      ))
    );
  }

  return (
    <Section
      title="Inserted Skillchip"
      buttons={
        <>
          <Button
            icon="syringe"
            disabled={!implantable || !!working}
            color={implantable ? "good" : "default"}
            onClick={() => act("implant")}
            content="Implant"
            tooltip={implantable_reason} />
          <Button
            icon="eject"
            disabled={!!working}
            onClick={() => act("eject")}
            content="Eject" />
        </>
      }>
      <Stack fill align="center">
        <Stack.Item>
          <Icon m={1} size={3} name={skill_icon} />
        </Stack.Item>
        <Stack.Item grow basis={0}>
          <LabeledList>
            <LabeledList.Item
              label="Skillchip">
              <Box
                bold>{skill_name}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item
              label="Description">
              <Box
                italic>
                {skill_desc}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item
              label="Complexity">
              <Icon
                name="brain"
                width="15px"
                textAlign="center"
              /> {complexity}
            </LabeledList.Item>
            <LabeledList.Item
              label="Slot Size">
              <Box
                color={(slots_used + slot_use > slots_max) && "red"}>
                <Icon
                  name="save"
                  width="15px"
                  textAlign="center"
                /> {slot_use}
              </Box>
            </LabeledList.Item>
            {!!implantable_reason && (
              <LabeledList.Item
                label="Error"
                color={implantable ? "good" : "bad"}>
                {implantable_reason}
              </LabeledList.Item>
            )}
          </LabeledList>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

export const ImplantedSkillchips = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    slots_used,
    slots_max,
    complexity_used,
    complexity_max,
    working,
  } = data;

  const current = data.current || [];

  return (
    <Section
      title="Implanted Skillchips">
      {!current.length && "No skillchips detected."}
      {!!current.length && (
        <Table>
          <Table.Row
            header>
            <Table.Cell>
              Chip
            </Table.Cell>
            <Table.Cell
              textAlign="center">
              <Button
                color="transparent"
                icon="brain"
                tooltip="Complexity"
                tooltipPosition="top"
                content={complexity_used + "/" + complexity_max} />
            </Table.Cell>
            <Table.Cell
              textAlign="center">
              <Button
                color="transparent"
                icon="save"
                tooltip="Slot Size"
                tooltipPosition="top"
                content={slots_used + "/" + slots_max} />
            </Table.Cell>
            <Table.Cell
              textAlign="center">
              <Button
                color="transparent"
                icon="check"
                tooltip="Is Active"
                tooltipPosition="top" />
            </Table.Cell>
            <Table.Cell
              textAlign="center">
              <Button
                color="transparent"
                icon="hourglass-half"
                tooltip="Cooldown"
                tooltipPosition="top" />
            </Table.Cell>
            <Table.Cell
              textAlign="center">
              <Button
                color="transparent"
                icon="tasks"
                tooltip="Actions"
                tooltipPosition="top" />
            </Table.Cell>
          </Table.Row>
          {current.map(skill => (
            <Table.Row
              key={skill.ref}>
              <Table.Cell>
                <Icon
                  textAlign="center"
                  width="18px"
                  mr={1}
                  name={skill.icon} />
                {skill.name}
              </Table.Cell>
              <Table.Cell
                bold
                color={(!!skill.active && "good"
                ) || (
                  (skill.complexity + complexity_used > complexity_max) && "bad"
                ) || (
                  "grey"
                )}
                textAlign="center">
                {skill.complexity}
              </Table.Cell>
              <Table.Cell
                bold
                color="good"
                textAlign="center">
                {skill.slot_use}
              </Table.Cell>
              <Table.Cell
                textAlign="center">
                <Icon
                  name={skill.active ? "check" : "times"}
                  color={skill.active ? "good" : "bad"} />
              </Table.Cell>
              <Table.Cell
                textAlign="center">
                {(skill.cooldown > 0) && (
                  Math.ceil(skill.cooldown / 10) + "s"
                ) || ("0s")}
              </Table.Cell>
              <Table.Cell
                textAlign="center">
                <Button
                  onClick={() => act("remove", { "ref": skill.ref })}
                  icon={skill.removable ? "eject" : "trash"}
                  color={skill.removable ? "good" : "bad"}
                  tooltip={skill.removable ? "Extract" : "Destroy"}
                  tooltipPosition="left"
                  disabled={skill.cooldown || working} />
                <Button
                  onClick={() => act("toggle_activate", { "ref": skill.ref })}
                  icon={skill.active ? "check-square-o" : "square-o"}
                  color={skill.active ? "good" : "default"}
                  tooltip={(!!skill.active_error
                    && !skill.active
                    && skill.active_error) || (
                    skill.active && "Deactivate") || (
                    "Activate"
                  )}
                  tooltipPosition="left"
                  disabled={
                    skill.cooldown
                    || working
                    || (!skill.active
                      && (skill.complexity + complexity_used > complexity_max))
                  } />
              </Table.Cell>
            </Table.Row>))}
        </Table>
      )}
    </Section>
  );
};

export const TimeFormat = (props, context) => {
  const { value } = props;

  const seconds = toFixed(Math.floor((value/10) % 60)).padStart(2, "0");
  const minutes = toFixed(Math.floor((value/(10*60)) % 60)).padStart(2, "0");
  const hours = toFixed(Math.floor((value/(10*60*60)) % 24)).padStart(2, "0");
  const formattedValue = `${hours}:${minutes}:${seconds}`;
  return formattedValue;
};

export const SkillStation = (props, context) => {
  const { data } = useBackend(context);
  const {
    working,
    timeleft,
    error,
  } = data;
  return (
    <Window
      title="Skillsoft Station"
      width={500}
      height={500}>
      <Window.Content>
        {!!error && (
          <NoticeBox>
            {error}
          </NoticeBox>
        )}
        {!!working && (
          <NoticeBox
            danger>
            <Flex
              direction="column">
              <Flex.Item
                mb={0.5}>
                Operation in progress. Please do not leave the chamber.
              </Flex.Item>
              <Flex.Item>
                Time Left: <TimeFormat value={timeleft} />
              </Flex.Item>
            </Flex>
          </NoticeBox>
        )}
        <InsertedSkillchip />
        <ImplantedSkillchips />
      </Window.Content>
    </Window>
  );
};
