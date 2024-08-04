import { Component } from 'react';

import { useBackend } from '../../backend';
import { Box, Button, Icon, Stack } from '../../components';
import { Window } from '../../layouts';
import { Connection, Connections, Position } from '../common/Connections';
import { BoardTabs } from './BoardTabs';
import { Case } from './DataTypes';
import { Evidence } from './Evidence';

const EVIDENCE_WIDTH = 250;
const Y_OFFSET = 10;
const X_OFFSET = -20;

type BoardProps = {
  cases: Case[];
  current_case: number;
};

type BoardState = {
  locations: { [key: string]: Position } | Position[];
  mouseX: number;
  mouseY: number;
};

export class DetectiveBoard extends Component<BoardProps, BoardState> {
  state: BoardState;

  constructor(props: BoardProps) {
    super(props);
    this.state = {
      locations: [],
      mouseX: 0,
      mouseY: 0,
    };
    this.handleEvidenceMoving = this.handleEvidenceMoving.bind(this);
  }

  handleEvidenceMoving(evidence: Evidence) {
    if (evidence.state.dragPos) {
      this.setLocation(
        evidence.state.dragPos.x,
        evidence.state.dragPos.y,
        evidence.props.evidence.ref,
      );
    }
  }

  setLocation(x: number, y: number, ref: string) {
    const { locations } = this.state;
    locations[ref] = { x: x + EVIDENCE_WIDTH / 2 + X_OFFSET, y: y + Y_OFFSET };
    this.setState({
      locations: locations,
    });
  }

  render() {
    const { act, data } = useBackend<BoardProps>();
    const { cases, current_case } = data;
    const { locations } = this.state;
    const connections: Connection[] = [];
    // Causes a lot of lags
    /* if (cases.length > 0) {
      for (const evidence of cases[current_case - 1].evidences) {
        this.setLocation(evidence.x, evidence.y, evidence.ref);
      }
      for (const evidence of cases[current_case - 1].evidences) {
        for (const connection of evidence.connections) {
          connections.push({
            color: 'red',
            from: locations[evidence.ref],
            to: locations[connection.ref],
          });
        }
      }
    } */

    return (
      <Window width={1200} height={800}>
        <Window.Content>
          {cases.length > 0 ? (
            <>
              <BoardTabs />
              {cases?.map(
                (item, i) =>
                  current_case - 1 === i && (
                    <Box key={'case' + i} className="Board__Content">
                      {item?.evidences?.map((evidence, index) => (
                        <Evidence
                          key={index}
                          {...item}
                          evidence={evidence}
                          case_ref={item.ref}
                          act={act}
                          onMoving={this.handleEvidenceMoving}
                        />
                      ))}
                      <Connections connections={connections} zLayer={1} />
                    </Box>
                  ),
              )}
            </>
          ) : (
            <Stack fill>
              <Stack.Item grow>
                <Stack fill vertical>
                  <Stack.Item grow />
                  <Stack.Item align="center" grow={2}>
                    <Icon color="average" name="search" size={15} />
                  </Stack.Item>
                  <Stack.Item align="center">
                    <Box color="red" fontSize="18px" bold mt={5}>
                      You have no cases! Create the first one
                    </Box>
                  </Stack.Item>
                  <Stack.Item align="center" grow={3}>
                    <Button
                      icon="plus"
                      content="Create case"
                      onClick={() => act('add_case')}
                    />
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            </Stack>
          )}
        </Window.Content>
      </Window>
    );
  }
}
