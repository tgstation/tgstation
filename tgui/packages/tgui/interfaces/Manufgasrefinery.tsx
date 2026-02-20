import { Box, Button, Section, Stack, Divider } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type GasRecipe = {
  plasma_required: BooleanLike,
  required_material: string,
  produced_gas_id: string,
  produced_mols: number,
}
type Data = {
  recipe: GasRecipe;
  plasma_mols_needed: number;
  last_failure_reason: string;
};

export const Manufgasrefinery = (props) => {
  const { act, data } = useBackend<Data>();
  const { recipe, plasma_mols_needed, last_failure_reason } = data;

  return (
    <Window width={480} height={285} theme="retro">
      <Window.Content>
        <Section flexGrow={true}>
          <Stack vertical>
            <Stack.Item>
                <Stack>
                  <Stack.Item grow={1}>
                    <Stack
                      width="100%"
                      height="100%"
                      className="NuclearBomb__displayBox"
                      style={{boxSizing: "border-box", padding: "0.5em 1em"}}
                      fontSize="medium"
                    >
                      <Stack.Item align="center" width="100%">
                        <Divider/>
                        PIPED PLASMA: {recipe.plasma_required ? `${plasma_mols_needed}  MOL/SHEET` : "NOT NEEDED"}
                        <Divider/>
                        MATERIAL: {recipe.required_material}
                        <Divider/>
                        PRODUCED MOLS: {recipe.produced_mols}
                        <Divider/>
                      </Stack.Item>
                    </Stack>
                  </Stack.Item>
                  <Stack.Item width="35%">
                    <Stack vertical>
                      <Box
                        width="100%"
                        className="NuclearBomb__displayBox"
                        textAlign="center"
                      >
                        {recipe.produced_gas_id}
                      </Box>
                      <Stack.Divider />
                      <Stack vertical pt="0.7em">
                        <Stack.Item grow={1}>
                          <Button
                            width="100%"
                            height="100%"
                            textAlign="center"
                            icon="arrow-up"
                            iconSize={1.5}
                            className="NuclearBomb__Button NuclearBomb__Button--keypad"
                            onClick={() => act('change_sel', { adjustment: -1 })}
                          >
                          </Button>
                        </Stack.Item>
                        <Stack.Item grow={1}>
                          <Button
                            width="100%"
                            height="100%"
                            textAlign="center"
                            icon="arrow-down"
                            iconSize={1.5}
                            className="NuclearBomb__Button NuclearBomb__Button--keypad"
                            onClick={() => act('change_sel', { adjustment: 1 })}
                          >
                          </Button>
                        </Stack.Item>
                      </Stack>
                   </Stack>
                </Stack.Item>
              </Stack>
            </Stack.Item>
         <Divider/>
            <Stack.Item>
              <Box
                width="100%"
                className="NuclearBomb__displayBox"
                textAlign="center"
                color={last_failure_reason !== null ? "red" : "green"}
              >
                {last_failure_reason !== null ? `LAST FAIL: ${last_failure_reason}` : "OK"}
              </Box>
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
