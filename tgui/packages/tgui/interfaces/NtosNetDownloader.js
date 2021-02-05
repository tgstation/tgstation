import { useBackend, useLocalState } from '../backend';
import { Box, Button, Flex, Icon, LabeledList, NoticeBox, ProgressBar, Section, Tabs } from '../components';
import { NtosWindow } from '../layouts';

export const NtosNetDownloader = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    PC_device_theme,
    disk_size,
    disk_used,
    downloadable_programs = [],
    error,
    hacked_programs = [],
    hackedavailable,
    categories = [],
  } = data;
  const [
    selectedCategory,
    setSelectedCategory,
  ] = useLocalState(context, 'category', categories[0]?.name);
  const items = categories
    .find(category => category.name === selectedCategory)
    ?.items
    || [];
  return (
    <NtosWindow
      theme={PC_device_theme}
      width={512}
      height={735}
      resizable>
      <NtosWindow.Content scrollable>
        {!!error && (
          <NoticeBox>
            <Box mb={1}>
              {error}
            </Box>
            <Button
              content="Reset"
              onClick={() => act('PRG_reseterror')} />
          </NoticeBox>
        )}
        <Section>
          <LabeledList>
            <LabeledList.Item label="Disk usage">
              <ProgressBar
                value={disk_used}
                minValue={0}
                maxValue={disk_size}>
                {`${disk_used} GQ / ${disk_size} GQ`}
              </ProgressBar>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Flex>
          <Flex.Item minWidth="110px" shrink={0} basis={0}>
          <Tabs vertical>
              {categories.map(category => (
                <Tabs.Tab
                  key={category.name}
                  selected={category.name === selectedCategory}
                  onClick={() => setSelectedCategory(category.name)}>
                  {category.name}
                </Tabs.Tab>
              ))}
            </Tabs>
          </Flex.Item>
          <Flex.Item grow={1} basis={0}>
            <Section>
              {items.map(program => (
                  <Program
                    key={program.filename}
                    program={program} />
                ))}
            </Section>
          </Flex.Item>
        </Flex>
        {!!hackedavailable && (
          <Section title="UNKNOWN Software Repository">
            <NoticeBox mb={1}>
              Please note that Nanotrasen does not recommend download
              of software from non-official servers.
            </NoticeBox>
            {items.map(program => (
              <Program
                key={program.filename}
                program={program} />
            ))}
          </Section>
        )}
      </NtosWindow.Content>
    </NtosWindow>
  );
};

const Program = (props, context) => {
  const { program } = props;
  const { act, data } = useBackend(context);
  const {
    disk_size,
    disk_used,
    downloadcompletion,
    downloading,
    downloadname,
    downloadsize,
  } = data;
  const disk_free = disk_size - disk_used;
  return (
    <Box mb={3}>
      <Flex align="baseline">
        <Flex.Item bold grow={1}>
          {program.filedesc}
        </Flex.Item>
        <Flex.Item shrink={0} width="48px" textAlign="right" color="label" nowrap>
          {program.size} GQ
        </Flex.Item>
        <Flex.Item ml={2} shrink={0} width="128px" textAlign="center">
          {(downloading && program.filename === downloadname) && (
            <ProgressBar
              color="green"
              minValue={0}
              maxValue={downloadsize}
              value={downloadcompletion} />
          ) || (
            (!program.installed && program.compatibility && program.access && program.size < disk_free) && (
              <Button
                fluid
                bold
                icon="download"
                content="Download"
                disabled={downloading}
                onClick={() => act('PRG_downloadfile', {
                  filename: program.filename,
                })} />
            ) || (
              <Button
                fluid
                bold
                icon={program.installed ? 'check' : 'times'}
                color={program.installed ? 'green' : 'red'}
                content={program.installed ? 'Installed' : !program.compatibility ? 'Incompatible' : !program.access ? 'No Access' : 'Need Space'} />
            )
          )}
        </Flex.Item>
      </Flex>
      <Box mt={1} italic color="label" fontSize="12px">
        {program.fileinfo}
      </Box>
    </Box>
  );
};
