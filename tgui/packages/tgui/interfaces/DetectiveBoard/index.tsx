import { useBackend } from '../../backend';
import { Box, Button, Icon, Stack } from '../../components';
import { Window } from '../../layouts';
import { BoardTabs } from './BoardTabs';
import { DataCase } from './DataTypes';
import { Evidence } from './Evidence';

type Data = {
  cases: DataCase[];
  current_case: number;
};

export const DetectiveBoard = (props) => {
  const { act, data } = useBackend<Data>();
  const { cases, current_case } = data;
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
                        key={'evidence' + index}
                        evidence={evidence}
                        case_ref={item.ref}
                        act={act}
                      />
                    ))}
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
};
