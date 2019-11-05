import { Fragment } from 'inferno';
import { act } from '../byond';
import { Button, LabeledList, NumberInput, Section, NoticeBox, Input, Table } from '../components';

export const NaniteRemote = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  const {
    code,
    locked,
    mode,
    program_name,
    relay_code,
    comms,
    message,
    saved_settings = [],
  } = data;

  const modes = [
    "Off",
    "Local",
    "Targeted",
    "Area",
    "Relay",
  ];

  if (locked) {
    return (
      <NoticeBox>
        This interface is locked.
      </NoticeBox>
    );
  }

  return (
    <Fragment>
      <Section
        title="Nanite Control"
        buttons={(
          <Button
            icon="lock"
            content="Lock Interface"
            onClick={() => act(ref, "lock")}
          />
        )}
      >

        <LabeledList>
          <LabeledList.Item label="Name">
            <Input
              value={program_name}
              maxLength={14}
              width="130px"
              onChange={(e, value) => act(ref, "update_name", {name: value})}
            />
            <Button
              icon="save"
              content="Save"
              onClick={() => act(ref, "save")}
            />
          </LabeledList.Item>
          <LabeledList.Item label={comms ? "Comm Code" : "Signal Code"} >
            <NumberInput
              value={code}
              minValue={0}
              maxValue={9999}
              width="47px"
              step={1}
              stepPixelSize={2}
              onChange={(e, value) => act(ref, "set_code", {code: value})}
            />
          </LabeledList.Item>
          {!!comms && (
            <LabeledList.Item label="Message">
              <Input
                value={message}
                width="270px"
                onChange={(e, value) => act(ref, "set_message", {value: value})}
              />
            </LabeledList.Item>
          )}
          {mode === "Relay" && (
            <LabeledList.Item label="Relay Code">
              <NumberInput
                value={relay_code}
                minValue={0}
                maxValue={9999}
                width="47px"
                step={1}
                stepPixelSize={2}
                onChange={(e, value) => act(ref, "set_relay_code", {code: value})}
              />
            </LabeledList.Item>
          )}
          <LabeledList.Item
            label="Signal Mode"
          >
            {modes.map(key => (
              <Button
                key={key}
                content={key}
                selected={mode === key}
                onClick={() => act(ref, "select_mode", {mode: key})}
              />
            ))}
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section title="Saved Settings">
        {saved_settings.length > 0 ? (

          <Table width="100%">
            <Table.Row bold>
              <Table.Cell width="35%">
              Name
              </Table.Cell>
              <Table.Cell width="20%">
              Mode
              </Table.Cell>
              <Table.Cell>
              Code
              </Table.Cell>
              <Table.Cell>
              Relay
              </Table.Cell>
            </Table.Row>
            {saved_settings.map(setting => (
              <Table.Row
                key={setting.id}
                className="candystripe"
              >
                <Table.Cell bold color="label">
                  {setting.name}:
                </Table.Cell>
                <Table.Cell>
                  {setting.mode}
                </Table.Cell>
                <Table.Cell>
                  {setting.code}
                </Table.Cell>
                <Table.Cell>
                  {setting.mode === "Relay" && setting.relay_code}
                </Table.Cell>
                <Table.Cell textAlign="right">
                  <Button
                    icon="upload"
                    color="good"
                    onClick={() => act(ref, "load", {save_id: setting.id})}
                  />
                  <Button
                    icon="minus"
                    color="bad"
                    onClick={() => act(ref, "remove_save", {save_id: setting.id})}
                  />
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        ) : (
          <NoticeBox>
          No settings currently saved
          </NoticeBox>
        )}
      </Section>
    </Fragment>
  );
};
