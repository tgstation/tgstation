import { useBackend, useLocalState } from '../backend';
import { Box, Button, Flex, Icon, LabeledList, NoticeBox, ProgressBar, Section, Tabs } from '../components';
import { NtosWindow } from '../layouts';

export const NtosNetDownloader = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    PC_device_theme,
    disk_size,
    disk_used,
    downloadcompletion,
    downloading,
    downloadname,
    downloadsize,
    error,
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
      width={600}
      height={600}
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
            {downloading && (
              <LabeledList.Item label="Downloading">
                <ProgressBar
                  color="green"
                  minValue={0}
                  maxValue={downloadsize}
                  value={downloadcompletion}>
                  {`File: ${downloadname}, ${downloadcompletion * 10}% complete`}
                </ProgressBar>
              </LabeledList.Item>
            ) || (
              <LabeledList.Item label="Disk usage">
                <ProgressBar
                  value={disk_used}
                  minValue={0}
                  maxValue={disk_size}>
                  {`${disk_used} GQ / ${disk_size} GQ`}
                </ProgressBar>
              </LabeledList.Item>
            )}
          </LabeledList>
        </Section>
        <Flex>
          <Flex.Item minWidth="105px" shrink={0} basis={0}>
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
            {items.map(program => (
                <Program
                  key={program.filename}
                  program={program} />
              ))}
          </Flex.Item>
        </Flex>
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
    <Section>
      <Flex align="baseline">
        <Flex.Item grow={1}>
          <Icon name={program.icon} /> <Box inline bold>{program.filedesc}</Box>
        </Flex.Item>
        <Flex.Item shrink={0} width="48px" textAlign="right" color="label" nowrap>
          {program.size} GQ
        </Flex.Item>
        <Flex.Item shrink={0} width="132px" textAlign="right">
          {(downloading && program.filename === downloadname) && (
            <Button
              bold
              color="good"
              icon="spinner"
              iconSpin={1}
              content="Downloading" />
          ) || (
            (!program.installed && program.compatibility && program.access && program.size < disk_free) && (
              <Button
                bold
                icon="download"
                content="Download"
                disabled={downloading}
                onClick={() => act('PRG_downloadfile', {
                  filename: program.filename,
                })} />
            ) || (
              <Button
                bold
                icon={program.installed ? 'check' : 'times'}
                color={program.installed ? 'good' : !program.compatibility ? 'grey' : 'bad'}
                content={program.installed ? 'Installed' : !program.compatibility ? 'Incompatible' : !program.access ? 'No Access' : 'No Space'} />
            )
          )}
        </Flex.Item>
      </Flex>
      <Box mt={1} italic color="label">
        {program.fileinfo}
      </Box>
      {!program.verifiedsource && (
        <NoticeBox mt={3} mb={0} danger fontSize="12px">
          Unverified source. Please note that Nanotrasen does not recommend download of software from non-official servers.
        </NoticeBox>
      )}
    </Section>
  );
};
