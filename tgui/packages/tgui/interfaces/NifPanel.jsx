import { useBackend, useLocalState } from '../backend';
import { BlockQuote, Box, Button, Collapsible, Dropdown, Flex, Icon, Input, LabeledList, ProgressBar, Section, Table } from '../components';
import { TableCell, TableRow } from '../components/Table';
import { Window } from '../layouts';

export const NifPanel = (props) => {
  const { act, data } = useBackend();
  const {
    linked_mob_name,
    loaded_nifsofts,
    max_nifsofts,
    max_power,
    current_theme,
  } = data;
  const [settingsOpen, setSettingsOpen] = useLocalState('settingsOpen', false);

  return (
    <Window
      title={'Nanite Implant Framework'}
      width={500}
      height={400}
      resizable
      theme={current_theme}>
      <Window.Content>
        <Section
          title={`Welcome to your NIF, ${linked_mob_name}`}
          buttons={
            <Button
              icon="cogs"
              tooltip="NIF Settings"
              tooltiptooltipPosition="bottom-end"
              selected={settingsOpen}
              onClick={() => setSettingsOpen(!settingsOpen)}
            />
          }>
          {(settingsOpen && <NifSettings />) || <NifStats />}
          {(!settingsOpen && (
            <Section
              title={`NIFSoft Programs (${
                max_nifsofts - loaded_nifsofts.length
              } Slots Remaining)`}
              right>
              {(loaded_nifsofts.length && (
                <Flex direction="column">
                  {loaded_nifsofts.map((nifsoft) => (
                    <Flex.Item key={nifsoft.name}>
                      <Collapsible
                        title={
                          <>
                            {<Icon name={nifsoft.ui_icon} />}
                            {nifsoft.name + '  '}
                          </>
                        }
                        buttons={
                          <Button
                            icon="play"
                            color="green"
                            onClick={() =>
                              act('activate_nifsoft', {
                                activated_nifsoft: nifsoft.reference,
                              })
                            }
                          />
                        }>
                        <Table>
                          <TableRow>
                            <TableCell>
                              <Button
                                icon="bolt"
                                color="yellow"
                                tooltip="What percent of the power is used when activating the NIFSoft"
                              />
                              {nifsoft.activation_cost === 0
                                ? ' No activation cost'
                                : ' ' +
                                (nifsoft.activation_cost / max_power) * 100 +
                                '% per activation'}
                            </TableCell>
                            <TableCell>
                              <Button
                                icon="battery-half"
                                color="orange"
                                tooltip="The power that the NIFSoft uses while active"
                                disabled={nifsoft.active_cost === 0}
                              />
                              {nifsoft.active_cost === 0
                                ? ' No active drain'
                                : ' ' +
                                (nifsoft.active_cost / max_power) * 100 +
                                '% consumed while active'}
                            </TableCell>
                            <TableCell>
                              <Button
                                icon="exclamation"
                                color={nifsoft.active ? 'green' : 'red'}
                                disabled={!nifsoft.active_mode}
                                tooltip="Shows whether or not a program is currently active or not"
                              />
                              {nifsoft.active
                                ? ' The NIFSoft is active!'
                                : ' The NIFSoft is inactive!'}
                            </TableCell>
                          </TableRow>
                        </Table>
                        <br />
                        <BlockQuote preserveWhitespace>
                          {nifsoft.desc}
                        </BlockQuote>
                        {nifsoft.able_to_keep ? (
                          <box>
                            <br />
                            <Button
                              icon="floppy-disk"
                              content={
                                nifsoft.keep_installed
                                  ? 'The NIFSoft will stay saved'
                                  : "The NIFSoft won't stay saved"
                              }
                              color={nifsoft.keep_installed ? 'green' : 'red'}
                              fluid
                              tooltip="Toggle if the NIFSoft will stay saved between shifts"
                              onClick={() =>
                                act('toggle_keeping_nifsoft', {
                                  nifsoft_to_keep: nifsoft.reference,
                                })
                              }
                            />
                          </box>
                        ) : (
                          <> </>
                        )}
                        <box>
                          <br />
                          <Button.Confirm
                            icon="trash"
                            content="Uninstall"
                            color="red"
                            fluid
                            tooltip="Uninstall the selected NIFSoft"
                            confirmContent="Are you sure?"
                            confirmIcon="question"
                            onClick={() =>
                              act('uninstall_nifsoft', {
                                nifsoft_to_remove: nifsoft.reference,
                              })
                            }
                          />
                        </box>
                      </Collapsible>
                    </Flex.Item>
                  ))}
                </Flex>
              )) || (
                <Box>
                  {' '}
                  <center>
                    <b>There are no NIFSofts currently installed</b>
                  </center>{' '}
                </Box>
              )}
            </Section>
          )) || (
            <Section title={'Product Info'}>
              <NifProductNotes />
            </Section>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};

const NifSettings = (props) => {
  const { act, data } = useBackend();
  const {
    nutrition_drain,
    ui_themes,
    current_theme,
    nutrition_level,
    blood_drain,
    minimum_blood_level,
    blood_level,
    stored_points,
  } = data;
  return (
    <LabeledList>
      <LabeledList.Item label="NIF Theme">
        <Dropdown
          width="100%"
          selected={current_theme}
          options={ui_themes}
          onSelected={(value) => act('change_theme', { target_theme: value })}
        />
      </LabeledList.Item>
      <LabeledList.Item label="NIF Flavor Text">
        <Input
          onChange={(e, value) =>
            act('change_examine_text', { new_text: value })
          }
          width="100%"
        />
      </LabeledList.Item>
      <LabeledList.Item label="Nutrition Drain">
        <Button
          fluid
          content={
            nutrition_drain === 0
              ? 'Nutrition Drain Disabled'
              : 'Nutrition Drain Enabled'
          }
          tooltip="Toggles the ability for the NIF to use your food as an energy source. Enabling this may result in increased hunger."
          onClick={() => act('toggle_nutrition_drain')}
          disabled={nutrition_level < 26}
        />
      </LabeledList.Item>
      <LabeledList.Item label="Blood Drain">
        <Button
          fluid
          content={
            blood_drain === 0 ? 'Blood Drain Disabled' : 'Blood Drain Enabled'
          }
          tooltip="Toggles the ability for the NIF to drain blood from you. This will automatically shut off once you get close to an unsafe blood level"
          onClick={() => act('toggle_blood_drain')}
          disabled={blood_level < minimum_blood_level}
        />
      </LabeledList.Item>
      <LabeledList.Item
        label="Rewards Points"
        buttons={
          <Button
            icon="info"
            tooltip="Rewards points are an alternative currency gained by purchasing NIFSofts, rewards points carry between shifts."
          />
        }>
        {stored_points}
      </LabeledList.Item>
    </LabeledList>
  );
};

const NifProductNotes = (props) => {
  const { act, data } = useBackend();
  const { product_notes } = data;
  return <BlockQuote>{product_notes}</BlockQuote>;
};

const NifStats = (props) => {
  const { act, data } = useBackend();
  const {
    max_power,
    power_level,
    durability,
    power_usage,
    nutrition_drain,
    blood_drain,
    max_durability,
  } = data;

  return (
    <Box>
      <LabeledList>
        <LabeledList.Item label="NIF Condition">
          <ProgressBar
            value={durability}
            minValue={0}
            maxValue={max_durability}
            ranges={{
              good: [max_durability * 0.66, max_durability],
              average: [max_durability * 0.33, max_durability * 0.66],
              bad: [0, max_durability * 0.33],
            }}
            alertAfter={max_durability * 0.25}
          />
        </LabeledList.Item>
        <LabeledList.Item label="NIF Power">
          <ProgressBar
            value={power_level}
            minValue={0}
            maxValue={max_power}
            ranges={{
              good: [max_power * 0.66, max_power],
              average: [max_power * 0.33, max_power * 0.66],
              bad: [0, max_power * 0.33],
            }}
            alertAfter={max_power * 0.1}>
            {(power_level / max_power) * 100 +
              '%' +
              ' (' +
              (power_usage / max_power) * 100 +
              '% Usage)'}
          </ProgressBar>
        </LabeledList.Item>
        {nutrition_drain === 1 && (
          <LabeledList.Item label="User Nutrition">
            <NifNutritionBar />
          </LabeledList.Item>
        )}
        {blood_drain === 1 && (
          <LabeledList.Item label="User Blood Level">
            <NifBloodBar />
          </LabeledList.Item>
        )}
      </LabeledList>
    </Box>
  );
};

const NifNutritionBar = (props) => {
  const { act, data } = useBackend();
  const { nutrition_level } = data;
  return (
    <ProgressBar
      value={nutrition_level}
      minValue={0}
      maxValue={550}
      ranges={{
        good: [250, Infinity],
        average: [150, 250],
        bad: [0, 150],
      }}
    />
  );
};

const NifBloodBar = (props) => {
  const { act, data } = useBackend();
  const { blood_level, minimum_blood_level, max_blood_level } = data;
  return (
    <ProgressBar
      value={blood_level}
      minValue={0}
      maxValue={max_blood_level}
      ranges={{
        good: [minimum_blood_level, Infinity],
        average: [336, minimum_blood_level],
        bad: [0, 336],
      }}
    />
  );
};
