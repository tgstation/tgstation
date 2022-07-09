import { useBackend, useLocalState } from '../backend';
import { Box, Button, LabeledList, NumberInput, Dropdown, Section, Stack } from '../components';
import { Window } from '../layouts';
import { AtmosHandbookContent, atmosHandbookHooks } from './common/AtmosHandbook';
import { Gasmix, GasmixParser } from './common/GasmixParser';

type Chamber = {
  id: string;
  name: string;
  gasmix?: Gasmix;
  input_info?: { active: boolean; amount: number };
  output_info?: { active: boolean; amount: number };
};

export const AtmosControlConsole = (props, context) => {
  const { act, data } = useBackend<{
    chambers: Chamber[];
    maxInput: number;
    maxOutput: number;
    reconnecting: boolean;
    control: boolean;
  }>(context);
  const chambers = data.chambers || [];
  const [chamberId, setChamberId] = useLocalState(
    context,
    'chamberId',
    chambers[0]?.id
  );
  const selectedChamber =
    chambers.length === 1
      ? chambers[0]
      : chambers.find((chamber) => chamber.id === chamberId);
  const [setActiveGasId, setActiveReactionId] = atmosHandbookHooks(context);
  return (
    <Window width={550} height={350}>
      <Window.Content scrollable>
        {chambers.length > 1 && (
          <Section title="Chamber Selection">
            <Dropdown
              width="100%"
              options={chambers.map((chamber) => chamber.name)}
              selected={selectedChamber?.name}
              onSelected={(value) =>
                setChamberId(
                  chambers.find((chamber) => chamber.name === value)?.id ||
                    chambers[0].id
                )
              }
            />
          </Section>
        )}
        <Section
          title={selectedChamber ? selectedChamber.name : 'Chamber Reading'}
          buttons={
            !!data.reconnecting && (
              <Button
                icon="undo"
                content="Reconnect"
                onClick={() => act('reconnect')}
              />
            )
          }>
          {!!selectedChamber && !!selectedChamber.gasmix ? (
            <GasmixParser
              gasmix={selectedChamber.gasmix}
              gasesOnClick={setActiveGasId}
              reactionOnClick={setActiveReactionId}
            />
          ) : (
            <Box italic> {'No Sensors Detected!'}</Box>
          )}
        </Section>
        {!!selectedChamber && !!data.control && (
          <Section title="Chamber Controls">
            <Stack>
              <Stack.Item grow>
                {selectedChamber.input_info ? (
                  <LabeledList>
                    <LabeledList.Item label="Input Injector">
                      <Button
                        icon={
                          selectedChamber.input_info.active
                            ? 'power-off'
                            : 'times'
                        }
                        content={
                          selectedChamber.input_info.active
                            ? 'Injecting'
                            : 'Off'
                        }
                        selected={selectedChamber.input_info.active}
                        onClick={() =>
                          act('toggle_input', {
                            chamber: selectedChamber.id,
                          })
                        }
                      />
                    </LabeledList.Item>
                    <LabeledList.Item label="Input Rate">
                      <NumberInput
                        value={Number(selectedChamber.input_info.amount)}
                        unit="L/s"
                        width="63px"
                        minValue={0}
                        maxValue={data.maxInput}
                        // This takes an exceptionally long time to update
                        // due to being an async signal
                        suppressFlicker={2000}
                        onChange={(e, value) =>
                          act('adjust_input', {
                            chamber: selectedChamber.id,
                            rate: value,
                          })
                        }
                      />
                    </LabeledList.Item>
                  </LabeledList>
                ) : (
                  <Box italic> {'No Input Device Detected!'}</Box>
                )}
              </Stack.Item>
              <Stack.Item grow>
                {selectedChamber.output_info ? (
                  <LabeledList>
                    <LabeledList.Item label="Output Regulator">
                      <Button
                        icon={
                          selectedChamber.output_info.active
                            ? 'power-off'
                            : 'times'
                        }
                        content={
                          selectedChamber.output_info.active ? 'Open' : 'Closed'
                        }
                        selected={selectedChamber.output_info.active}
                        onClick={() =>
                          act('toggle_output', {
                            chamber: selectedChamber.id,
                          })
                        }
                      />
                    </LabeledList.Item>
                    <LabeledList.Item label="Output Pressure">
                      <NumberInput
                        value={Number(selectedChamber.output_info.amount)}
                        unit="kPa"
                        width="75px"
                        minValue={0}
                        maxValue={data.maxOutput}
                        step={10}
                        // This takes an exceptionally long time to update
                        // due to being an async signal
                        suppressFlicker={2000}
                        onChange={(e, value) =>
                          act('adjust_output', {
                            chamber: selectedChamber.id,
                            rate: value,
                          })
                        }
                      />
                    </LabeledList.Item>
                  </LabeledList>
                ) : (
                  <Box italic> {'No Output Device Detected !'} </Box>
                )}
              </Stack.Item>
            </Stack>
          </Section>
        )}
        <AtmosHandbookContent />
      </Window.Content>
    </Window>
  );
};
