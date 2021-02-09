import { map } from 'common/collections';
import { useBackend, useSharedState } from '../backend';
import { Button, Flex, LabeledList, NoticeBox, Section, Tabs } from '../components';
import { Window } from '../layouts';

export const NaniteProgramHub = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    detail_view,
    disk,
    has_disk,
    has_program,
    programs = {},
  } = data;
  const [
    selectedCategory,
    setSelectedCategory,
  ] = useSharedState(context, 'category');
  const programsInCategory = programs
    && programs[selectedCategory]
    || [];
  return (
    <Window
      width={500}
      height={700}>
      <Window.Content scrollable>
        <Section
          title="Program Disk"
          buttons={(
            <>
              <Button
                icon="eject"
                content="Eject"
                onClick={() => act('eject')} />
              <Button
                icon="minus-circle"
                content="Delete Program"
                onClick={() => act('clear')} />
            </>
          )}>
          {has_disk ? (
            has_program ? (
              <LabeledList>
                <LabeledList.Item label="Program Name">
                  {disk.name}
                </LabeledList.Item>
                <LabeledList.Item label="Description">
                  {disk.desc}
                </LabeledList.Item>
              </LabeledList>
            ) : (
              <NoticeBox>
                No Program Installed
              </NoticeBox>
            )
          ) : (
            <NoticeBox>
              Insert Disk
            </NoticeBox>
          )}
        </Section>
        <Section
          title="Programs"
          buttons={(
            <>
              <Button
                icon={detail_view ? 'info' : 'list'}
                content={detail_view ? 'Detailed' : 'Compact'}
                onClick={() => act('toggle_details')} />
              <Button
                icon="sync"
                content="Sync Research"
                onClick={() => act('refresh')} />
            </>
          )}>
          {programs !== null ? (
            <Flex>
              <Flex.Item minWidth="110px">
                <Tabs vertical>
                  {map((cat_contents, category) => {
                    const progs = cat_contents || [];
                    // Backend was sending stupid data that would have been
                    // annoying to fix
                    const tabLabel = category
                      .substring(0, category.length - 8);
                    return (
                      <Tabs.Tab
                        key={category}
                        selected={category === selectedCategory}
                        onClick={() => setSelectedCategory(category)}>
                        {tabLabel}
                      </Tabs.Tab>
                    );
                  })(programs)}
                </Tabs>
              </Flex.Item>
              <Flex.Item grow={1} basis={0}>
                {detail_view ? (
                  programsInCategory.map(program => (
                    <Section
                      key={program.id}
                      title={program.name}
                      level={2}
                      buttons={(
                        <Button
                          icon="download"
                          content="Download"
                          disabled={!has_disk}
                          onClick={() => act('download', {
                            program_id: program.id,
                          })} />
                      )}>
                      {program.desc}
                    </Section>
                  ))
                ) : (
                  <LabeledList>
                    {programsInCategory.map(program => (
                      <LabeledList.Item
                        key={program.id}
                        label={program.name}
                        buttons={(
                          <Button
                            icon="download"
                            content="Download"
                            disabled={!has_disk}
                            onClick={() => act('download', {
                              program_id: program.id,
                            })} />
                        )} />
                    ))}
                  </LabeledList>
                )}
              </Flex.Item>
            </Flex>
          ) : (
            <NoticeBox>
              No nanite programs are currently researched.
            </NoticeBox>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
