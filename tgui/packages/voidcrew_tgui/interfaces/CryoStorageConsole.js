import { useBackend } from '../../tgui/backend';
import { Button, LabeledList, Section, Table, Divider } from '../../tgui/components';
import { TableCell } from '../../tgui/components/Table';
import { Window } from '../../tgui/layouts';

export const CryoStorageConsole = (props, context) => {
  return (
    <Window width={450} height={620} resizable>
      <Window.Content scrollable>
        <CryoStorageConsoleContent />
      </Window.Content>
    </Window>
  );
};

export const CryoStorageConsoleContent = (props, context) => {
  const { act, data } = useBackend(context);
  const { jobs = [], memo, awakening, cooldown = 1 } = data;
  return (
    <Section title={'Cryo Management'}>
      <LabeledList>
        <LabeledList.Item label="Awakening Settings">
          <Button
            content={awakening ? 'Disable' : 'Enable'}
            icon="bed"
            color={awakening ? 'bad' : 'good'}
            onClick={() => act('toggleAwakening')}
          />
          <Button.Input
            content="Set Memo"
            currentValue={memo}
            onCommit={(e, value) =>
              act('setMemo', {
                newName: value,
              })
            }
          />
        </LabeledList.Item>
      </LabeledList>
      <Divider />
      {cooldown > 0 && (
        <div className="NoticeBox">{'On Cooldown: ' + cooldown / 10 + 's'}</div>
      )}
      <Table>
        <Table.Row header>
          <Table.Cell>Job Name</Table.Cell>
          <Table.Cell>Slots</Table.Cell>
        </Table.Row>
        {jobs.map((job) => (
          <Table.Row key={job.name}>
            <Table.Cell>{job.name}</Table.Cell>
            <TableCell>
              <Button
                content="+"
                disabled={cooldown > 0 || job.slots >= job.max}
                onClick={() =>
                  act('adjustJobSlot', {
                    toAdjust: job.ref,
                    delta: 1,
                  })
                }
              />
              {job.slots}
              <Button
                content="-"
                disabled={cooldown > 0 || job.slots <= 0}
                onClick={() =>
                  act('adjustJobSlot', {
                    toAdjust: job.ref,
                    delta: -1,
                  })
                }
              />
            </TableCell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};
