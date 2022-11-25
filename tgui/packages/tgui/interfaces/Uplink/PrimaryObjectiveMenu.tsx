import { Component, Fragment } from 'inferno';
import { Box, Dimmer, Flex, NoticeBox, Section, Stack } from '../../components';
import { ObjectiveElement } from './ObjectiveMenu';
import { calculateProgression, getReputation, Rank, ranks } from './calculateReputationLevel';

type PrimaryObjectiveMenuProps = {
  primary_objectives,
  final_objective,
};

export class PrimaryObjectiveMenu extends Component<
  PrimaryObjectiveMenuProps
> {
  render() {
    const {
      primary_objectives,
      final_objective,
    } = this.props;
    const boxrep = getReputation(Infinity);
    return (
      <Section>
        <Fragment>
        <Section>
          <Box mt={3} mb={3} bold fontSize={1.2} align="center" color="white">
            {'Agent, your Primary Objectives are as follows. Complete these at all costs.'}
          </Box>
          <Box mt={3} mb={3} bold fontSize={1.2} align="center" color="white">
            {'Completing on Secondary Objectives may allow you to aquire additional equipment.'}
          </Box>
        </Section>
          {final_objective &&(
            <Fragment>
              <Dimmer>
                <Box color="red" fontFamily={"Bahnschrift"} fontSize={3} align={"top"} as="span">
                  PRIORITY MESSAGE<br/>
                  SOURCE: xxx.xxx.xxx.224:41394<br/><br/>
                  \\Debrief in progress.<br/>
                  \\Final Objective confirmed complete. <br/>
                  \\Your work is done here, agent.<br/><br/>
                  CONNECTION CLOSED_
                  
                </Box>
              </Dimmer>
            </Fragment>
          )}
        <Section>
          {primary_objectives.map((prim_obj, index) => (
            <ObjectiveElement
              name={"Objective " + (index + 1)}
              description={prim_obj}
              reputation={index == primary_objectives.length - 1 ? {gradient:'reputation-good'} : {gradient:'reputation-very-good'}}
              telecrystalReward={0}
              telecrystalPenalty={0}
              progressionReward={0}
              objectiveState={""}
              originalProgression={""}
              finalObjective={1}
              canAbort={""}
              grow={0}
            />
          ))}
        </Section>
        </Fragment>
      </Section>
    );
  }
}