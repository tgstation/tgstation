import { useBackend } from '../backend';
import { BlockQuote, Button, Collapsible, Dropdown, Input, LabeledList, Section, Stack, Tabs, Box, Table, NoticeBox, Tooltip, Icon } from '../components';
import { TableCell, TableRow } from '../components/Table';
import { NtosWindow } from '../layouts';

export const NtosScipaper = (props, context) => {
  return (
    <NtosWindow width={650} height={500}>
      <NtosWindow.Content scrollable>
        <NtosScipaperContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

const PaperPublishing = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    title,
    author,
    etAlia,
    abstract,
    fileList = [],
    expList = [],
    allowedTiers = [],
    allowedPartners = [],
    gains,
    selectedFile,
    selectedExperiment,
    tier,
    selectedPartner,
    coopIndex,
    fundingIndex,
  } = data;
  return (
    <>
      <Section title="Submission Form">
        <LabeledList grow>
          <LabeledList.Item label="Title">
            <Input
              fluid
              value={title}
              onChange={(e, value) =>
                act('rewrite', {
                  title: value,
                })
              }
            />
          </LabeledList.Item>
          <LabeledList.Item label="Principal Author">
            <Input
              fluid
              value={author}
              onChange={(e, value) =>
                act('rewrite', {
                  author: value,
                })
              }
            />
            <Button selected={etAlia} onClick={() => act('et_alia')}>
              {'Multiple Authors'}
            </Button>
          </LabeledList.Item>
          <LabeledList.Item label="Abstract">
            <Input
              fluid
              value={abstract}
              onChange={(e, value) =>
                act('rewrite', {
                  abstract: value,
                })
              }
            />
          </LabeledList.Item>
          <LabeledList.Item label="Selected File">
            <Stack>
              <Stack.Item>
                <Dropdown
                  width="35rem"
                  options={Object.keys(fileList)}
                  displayText={selectedFile ? selectedFile : '-'}
                  onSelected={(ordfile_name) =>
                    act('select_file', {
                      selected_uid: fileList[ordfile_name],
                    })
                  }
                />
              </Stack.Item>
              <Stack.Item align="center">
                <Tooltip
                  position="left"
                  content="The selected file containing experimental data for our paper. Must be present in the HDD to be accesible. Transfer files with the File Manager program.">
                  <Icon size={1.15} name="info-circle" />
                </Tooltip>
              </Stack.Item>
            </Stack>
          </LabeledList.Item>
          <LabeledList.Item label="Selected Experiment">
            <Stack>
              <Stack.Item>
                <Dropdown
                  width="35rem"
                  options={Object.keys(expList)}
                  displayText={selectedExperiment ? selectedExperiment : '-'}
                  onSelected={(experiment_name) =>
                    act('select_experiment', {
                      selected_expath: expList[experiment_name],
                    })
                  }
                />
              </Stack.Item>
              <Stack.Item align="center">
                <Tooltip
                  position="left"
                  content="The topic we want to publish our paper on. Different topics unlock different technologies and possible partners.">
                  <Icon size={1.15} name="info-circle" />
                </Tooltip>
              </Stack.Item>
            </Stack>
          </LabeledList.Item>
          <LabeledList.Item label="Selected Tier">
            <Stack>
              <Stack.Item>
                <Dropdown
                  width="35rem"
                  options={allowedTiers.map((number) => String(number))}
                  displayText={tier ? String(tier) : '-'}
                  onSelected={(new_tier) =>
                    act('select_tier', {
                      selected_tier: Number(new_tier),
                    })
                  }
                />
              </Stack.Item>
              <Stack.Item align="center">
                <Tooltip
                  position="left"
                  content="The tier we want to publish on. Higher tiers can confer better rewards but means our data will be judged more harshly.">
                  <Icon size={1.15} name="info-circle" />
                </Tooltip>
              </Stack.Item>
            </Stack>
          </LabeledList.Item>
          <LabeledList.Item label="Selected Partner">
            <Stack>
              <Stack.Item>
                <Dropdown
                  width="35rem"
                  options={Object.keys(allowedPartners)}
                  displayText={selectedPartner ? selectedPartner : '-'}
                  onSelected={(new_partner) =>
                    act('select_partner', {
                      selected_partner: allowedPartners[new_partner],
                    })
                  }
                />
              </Stack.Item>
              <Stack.Item align="center">
                <Tooltip
                  position="left"
                  content="Which organization to partner with. We can obtain research boosts in techs related to the partner's interests.">
                  <Icon size={1.15} name="info-circle" />
                </Tooltip>
              </Stack.Item>
            </Stack>
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section title="Expected Results" key="rewards">
        <Stack fill>
          <Stack.Item grow>
            <Tooltip
              position="top"
              content="How much will our relation improve with the particular partner. Cooperation will be used to unlock boosts.">
              <Icon size={1.15} name="info-circle" />
            </Tooltip>
            {' Cooperation: '}
            <BlockQuote>{gains[coopIndex - 1]}</BlockQuote>
          </Stack.Item>
          <Stack.Item grow>
            <Tooltip
              position="top"
              content="How much grant will we be endowed with upon the publication of this paper.">
              <Icon size={1.15} name="info-circle" />
            </Tooltip>
            {' Funding: '}
            <BlockQuote>{gains[fundingIndex - 1]}</BlockQuote>
          </Stack.Item>
        </Stack>
        <br />
        <Button
          icon="upload"
          textAlign="center"
          fluid
          onClick={() => act('publish')}
          content="Publish Paper"
        />
      </Section>
    </>
  );
};

const PaperBrowser = (props, context) => {
  const { act, data } = useBackend(context);
  const { publishedPapers, coopIndex, fundingIndex } = data;
  if (publishedPapers.length === 0) {
    return <NoticeBox> No Published Papers! </NoticeBox>;
  } else {
    return publishedPapers.map((paper) => (
      <Collapsible
        key={String(paper['experimentName'] + paper['tier'])}
        title={paper['title']}>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Topic">
              {paper['experimentName'] + ' - ' + paper['tier']}
            </LabeledList.Item>
            <LabeledList.Item label="Author">
              {paper['author'] + (paper.etAlia ? ' et al.' : '')}
            </LabeledList.Item>
            <LabeledList.Item label="Partner">
              {paper['partner']}
            </LabeledList.Item>
            <LabeledList.Item label="Yield">
              <LabeledList>
                <LabeledList.Item label="Cooperation">
                  {paper['gains'][coopIndex - 1]}
                </LabeledList.Item>
                <LabeledList.Item label="Funding">
                  {paper['gains'][fundingIndex - 1]}
                </LabeledList.Item>
              </LabeledList>
            </LabeledList.Item>
            <LabeledList.Item label="Abstract">
              {paper['abstract']}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Collapsible>
    ));
  }
};
const ExperimentBrowser = (props, context) => {
  const { act, data } = useBackend(context);
  const { experimentInformation = [] } = data;
  return experimentInformation.map((experiment) => (
    <Section title={experiment.name} key={experiment.name}>
      {experiment.description}
      <br />
      <LabeledList>
        {Object.keys(experiment.target).map((tier) => (
          <LabeledList.Item
            key={tier}
            label={
              'Optimal ' +
              experiment.prefix +
              ' Amount - Tier ' +
              String(Number(tier) + 1)
            }>
            {experiment.target[tier] + ' ' + experiment.suffix}
          </LabeledList.Item>
        ))}
      </LabeledList>
    </Section>
  ));
};

const PartnersBrowser = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    partnersInformation,
    coopIndex,
    fundingIndex,
    purchaseableBoosts = [],
    relations = [],
    visibleNodes = [],
  } = data;
  return partnersInformation.map((partner) => (
    <Section title={partner.name} key={partner.path}>
      <Collapsible title={'Relations: ' + relations[partner.path]}>
        <LabeledList>
          <LabeledList.Item label="Description">
            {partner.flufftext}
          </LabeledList.Item>
          <LabeledList.Item label="Relations">
            {relations[partner.path]}
          </LabeledList.Item>
          <LabeledList.Item label="Cooperation Bonus">
            {partner.multipliers[coopIndex - 1] + 'x'}
          </LabeledList.Item>
          <LabeledList.Item label="Funding Bonus">
            {partner.multipliers[fundingIndex - 1] + 'x'}
          </LabeledList.Item>
          <LabeledList.Item label="Accepted Experiments">
            {partner.acceptedExperiments.map((experiment_name) => (
              <Box key={experiment_name}>{experiment_name}</Box>
            ))}
          </LabeledList.Item>
          <LabeledList.Item label="Technology Sharing">
            <Table>
              {partner.boostedNodes.map((node) => (
                <TableRow key={node.id}>
                  <TableCell>
                    {visibleNodes.includes(node.id)
                      ? node.name
                      : 'Unknown Technology'}
                  </TableCell>
                  <TableCell>
                    <Button
                      fluid
                      tooltipPosition="left"
                      textAlign="center"
                      disabled={
                        !purchaseableBoosts[partner.path].includes(node.id)
                      }
                      content="Purchase"
                      tooltip={'Discount: ' + node.discount}
                      onClick={() =>
                        act('purchase_boost', {
                          purchased_boost: node.id,
                          boost_seller: partner.path,
                        })
                      }
                    />
                  </TableCell>
                </TableRow>
              ))}
            </Table>
          </LabeledList.Item>
        </LabeledList>
      </Collapsible>
    </Section>
  ));
};

export const NtosScipaperContent = (props, context) => {
  const { act, data } = useBackend(context);
  const { currentTab, has_techweb } = data;
  return (
    <>
      {!has_techweb && (
        <Section title="No techweb detected!" key="rewards">
          Please sync this application to a valid techweb to upload progress!
        </Section>
      )}
      <Tabs key="navigation">
        <Tabs.Tab
          selected={currentTab === 1}
          onClick={() =>
            act('change_tab', {
              new_tab: 1,
            })
          }>
          {'Publish Papers'}
        </Tabs.Tab>
        <Tabs.Tab
          selected={currentTab === 2}
          onClick={() =>
            act('change_tab', {
              new_tab: 2,
            })
          }>
          {'View Previous Publications'}
        </Tabs.Tab>
        <Tabs.Tab
          selected={currentTab === 3}
          onClick={() =>
            act('change_tab', {
              new_tab: 3,
            })
          }>
          {'View Available Experiments'}
        </Tabs.Tab>
        <Tabs.Tab
          selected={currentTab === 4}
          onClick={() =>
            act('change_tab', {
              new_tab: 4,
            })
          }>
          {'View Scientific Partners'}
        </Tabs.Tab>
      </Tabs>
      {currentTab === 1 && <PaperPublishing />}
      {currentTab === 2 && <PaperBrowser />}
      {currentTab === 3 && <ExperimentBrowser />}
      {currentTab === 4 && <PartnersBrowser />}
    </>
  );
};
