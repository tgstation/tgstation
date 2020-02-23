import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Button, LabeledList, NoticeBox, Section, Box, ProgressBar } from '../components';

export const Cloning = props => {
  const { act, data } = useBackend(props);
  const {
    menu,
    disk,
    has_disk,
    has_disk_dna,
    has_selected_dna,
    selected_dna,
    cloning_pods = [],
    dna_list = [],
  } = data;
  return (
    <Fragment>
      <Fragment>
        <Section
          title="Cloning DNA Disk"
          buttons={(
            <Fragment>
              {has_disk ? (
                <Button
                  icon="eject"
                  content="Eject"
                  onClick={() => act('eject')} />
              ) : null}
              {has_disk_dna ? (
                <Button
                  icon="plus-circle"
                  content="Save to Storage"
                  onClick={() => act('save_dna')} />
              ) : null}
            </Fragment>
          )}>
          {has_disk ? (
            has_disk_dna ? (
              <LabeledList>
                <LabeledList.Item label="Name">
                  {disk.name}
                </LabeledList.Item>
                <LabeledList.Item label="Species">
                  {disk.species}
                </LabeledList.Item>
                <LabeledList.Item label="Sequence">
                  {disk.sequence}
                </LabeledList.Item>
              </LabeledList>
            ) : (
              <NoticeBox>
              No DNA Record detected.
              </NoticeBox>
            )
          ) : (
            <NoticeBox>
              Insert Disk
            </NoticeBox>
          )}
        </Section>

        <Section
          title="Selected DNA Record">
          {has_selected_dna ? (
            <Section
              title={selected_dna.name}
              buttons={(
                <Button
                  icon={'minus-circle'}
                  color="bad"
                  content={'Deselect'}
                  onClick={() => act('deselect_dna')} />
              )}>
              <LabeledList>
                <LabeledList.Item label="DNA Sequence">
                  {selected_dna.sequence}
                </LabeledList.Item>
                <LabeledList.Item label="Species">
                  {selected_dna.species}
                </LabeledList.Item>
              </LabeledList>
            </Section>
          ) : (
            <NoticeBox>
              No DNA record selected.
            </NoticeBox>
          )}
        </Section>
      </Fragment>
      {(menu === 1) ? (
        <Section
          title="Cloning Pods"
          buttons={(
            <Button
              icon={'list'}
              content={'View DNA Records'}
              onClick={() => act('toggle_menu')} />
          )}>
          {cloning_pods.map(pod => (
            <Section
              key={pod.index}
              title={"Pod #" + (pod.index)}
              buttons={(
                <Button
                  icon={'minus-circle'}
                  color="bad"
                  content={'Unlink Pod'}
                  onClick={() => act('unlink_pod', {
                    index: pod.index,
                  })} />
              )}>
              {pod.operational ? (
                pod.cloning ? (
                  <Fragment>
                    <NoticeBox>
                      Cloning in Progress
                    </NoticeBox>
                    <LabeledList>
                      <LabeledList.Item label="DNA Sequence">
                        {pod.cloning_dna.sequence}
                      </LabeledList.Item>
                      <LabeledList.Item label="Name">
                        {pod.cloning_dna.name}
                      </LabeledList.Item>
                      <LabeledList.Item label="Species">
                        {pod.cloning_dna.species}
                      </LabeledList.Item>
                      <LabeledList.Item label="Progress">
                        <ProgressBar
                          value={pod.progress}
                          minValue={0}
                          maxValue={100}
                          color="green" />
                      </LabeledList.Item>
                      <LabeledList.Item label="Abort">
                        <Button
                          icon={'minus-circle'}
                          color="bad"
                          content={'Abort Cloning Process'}
                          onClick={() => act('cancel_clone', {
                            index: pod.index,
                          })} />
                      </LabeledList.Item>
                    </LabeledList>
                  </Fragment>
                ) : (
                  <Fragment>
                    <NoticeBox>
                      Pod available
                    </NoticeBox>
                    <Button
                      icon={'list'}
                      content={'Clone selected record'}
                      disabled={!has_selected_dna}
                      onClick={() => act('clone_selected', {
                        index: pod.index,
                      })} />
                    {has_disk ? (
                      <Button
                        icon={'list'}
                        content={'Clone from disk'}
                        onClick={() => act('clone_disk', {
                          index: pod.index,
                        })} />
                    ) : null}
                  </Fragment>
                )
              ) : (
                <NoticeBox>
                  Pod offline
                </NoticeBox>
              )}
            </Section>
          ))}
        </Section>
      ) : (
        <Section
          title="DNA Records"
          buttons={(
            <Button
              icon={'list'}
              content={'View Cloning Pods'}
              onClick={() => act('toggle_menu')} />
          )}>
          {dna_list.map(dna_record => (
            <Section
              key={dna_record.index}
              title={dna_record.name}
              buttons={(
                <Button
                  icon={'minus-circle'}
                  color="bad"
                  content={'Delete Record'}
                  onClick={() => act('delete_dna', {
                    index: dna_record.index,
                  })} />
              )}>
              <LabeledList>
                <LabeledList.Item label="DNA Sequence">
                  {dna_record.sequence}
                </LabeledList.Item>
                <LabeledList.Item label="Species">
                  {dna_record.species}
                </LabeledList.Item>
                <LabeledList.Item label="Select">
                  <Button
                    icon={'list'}
                    content={'Select this DNA'}
                    onClick={() => act('select_dna', {
                      select: dna_record.index,
                    })} />
                </LabeledList.Item>
              </LabeledList>
            </Section>
          ))}
        </Section>
      )}
    </Fragment>
  );
};
