import { toFixed } from 'common/math';
import { useBackend } from '../backend';
import { Button, Box, Section, NoticeBox, TimeDisplay, Flex, Icon } from '../components';
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
    max_skills,
    skillchip_ready,
    skill_name,
    skill_desc,
    skill_icon,
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
        </Flex.Item>
        <Flex.Item align="center">
          <Button onClick={() => act("implant")}>Implant</Button>
          <Button onClick={() => act("eject")}>Eject</Button>
        </Flex.Item>
      </Flex>);
  }
  return (
    <Window
      title="Skillsoft Station (name pending)"
      width={400}
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
          fill
          title="Current skillchips"
          buttons={<Fragment>{current.length}/{max_skills}</Fragment>}>
          <Flex direction="column">
            {current.map((skill, index) => (
              <Flex.Item key={skill}>
                <Flex spacing={1} align="baseline">
                  <FlexItem>
                    <Icon name={skill.icon} />
                  </FlexItem>
                  <Flex.Item>
                    {skill.name}
                  </Flex.Item>
                  {!working && (
                    <Flex.Item >
                      <Button
                        onClick={() => act("remove", { "slot": index+1 })}
                        icon="trash"
                        tooltip="Extract chip" />
                    </Flex.Item>)}
                </Flex>
              </Flex.Item>))}
          </Flex>
        </Section>
      </Window.Content>
    </Window>
  );
};
