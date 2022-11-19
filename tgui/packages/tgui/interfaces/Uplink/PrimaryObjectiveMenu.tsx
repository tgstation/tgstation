import { Component, Fragment } from 'inferno';
import { Box, Flex, NoticeBox, Section, Stack } from '../../components';

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
    return (
      <Fragment>
        {!!final_objective &&(
          <Fragment>
            <Box
              width={"100%"}
              hight={"100%"}
              position="absolute"
              className="UplinkObjective__EmptyObjective" />
            <NoticeBox
              position="absolute"
              width={"100%"}
              fontSize="30px"
              textAlign="center">
              ALL OBJECTIVES MARKED COMPLETE 
            </NoticeBox>
          </Fragment>
        )}
        <Flex direction={'column'}>
          <Flex.Item>
            <Stack>
              <Stack.Item
                grow={1}
                fill>
                <Box mt={3} mb={3} bold fontSize={1.2} align="center" color="orange">
                {'Agent, your Primary Objectives are as follows. Complete these at all costs.'}
                </Box>
              </Stack.Item>
            </Stack>
          </Flex.Item>
          <Flex.Item>
            {primary_objectives.map((objective, index) => (
              <Section
                title={"Objective " + (index + 1)}
                color={final_objective?"grey":"white"}>
              {objective}
              </Section>
            ))}
          </Flex.Item>
        </Flex>
      </Fragment>
    );
  }
}
