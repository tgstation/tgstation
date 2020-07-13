import { useBackend } from '../backend';
import { Box, Button, LabeledList, ProgressBar, Section } from '../components';
import { Window } from '../layouts';
const skillgreen = {
  color: 'lightgreen',
  fontWeight: 'bold',
};
const skillyellow = {
  color: '#FFDB58',
  fontWeight: 'bold',
};
export const SkillPanel = (props, context) => {
  const { act, data } = useBackend(context);
  const skills = data.skills || [];
  return (
    <Window resizable>
      <Window.Content scrollable>
        <Section title={skills.playername}>
          <LabeledList>
            {skills.map(skill => (
              <LabeledList.Item key={skill.name} label={skill.name}>
                <span style={skillyellow}>
                  {skill.desc}
                </span>
                <br />
                <Level skill_lvl_num={skill.lvlnum} skill_lvl={skill.lvl} />
                <br />
                Total Experience: [{skill.exp} XP]
                <br />
                XP To Next Level: 
                {skill.exp_req !== 0 ? (
                  <span>
                    [{skill.exp_prog} / {skill.exp_req}]
                  </span>
                ) : (
                  <span style={skillgreen}> 
                    [MAXXED]
                  </span>
                )}
                <br />
                Overall Skill Progress: [{skill.exp} / {skill.max_exp}]
                <ProgressBar
                  value={skill.exp_percent}
                  color="good" />
                <br />
                <Button
                  content="Adjust Exp"
                  onClick={() => act('adj_exp', {
                    skill: skill.path,
                  })} />
                <Button
                  content="Set Exp"
                  onClick={() => act('set_exp', {
                    skill: skill.path,
                  })} />
                <Button
                  content="Set Level"
                  onClick={() => act('set_lvl', {
                    skill: skill.path,
                  })} />
                <br />
                <br />
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
const Level = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    skill_lvl_num,
    skill_lvl,
  } = props;
  let textstyle="font-weight:bold; color:hsl("+skill_lvl_num*50+", 50%, 50%)";
  return (
    <span>Level: [<span style={textstyle}>{skill_lvl}</span>]</span>
  );
};
const XPToNextLevel = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    xp_req,
    xp_prog,
  } = props;
  if (xp_req === 0) {
    return (
      <span style={skillgreen}> 
        to next level: MAXXED
      </span>
    );
  }
  return (
    <span>XP to next level: [{xp_prog} / {xp_req}]</span>
  );
};
