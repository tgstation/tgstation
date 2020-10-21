import { Button, Section, NoticeBox, Tabs, Box, Input, Flex, ProgressBar } from '../components';
import { Experiment } from './ExperimentConfigure';
import { Window } from '../layouts';
import { useBackend, useLocalState } from '../backend';

export const Techweb = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    nodes,
    node_cache,
    experiments,
    points,
    points_last_tick,
    web_org,
    sec_protocols,
  } = data;
  const [
    tabIndex,
    setTabIndex,
  ] = useLocalState(context, 'tabIndex', 1);
  const [
    searchText,
    setSearchText,
  ] = useLocalState(context, 'searchText');

  let displayedNodes = [];
  switch (tabIndex) {
    case 0:
      displayedNodes = nodes.filter(x => x.researched);
      break;
    case 1:
      displayedNodes = nodes.filter(x => x.available);
      break;
    case 2:
      displayedNodes = nodes.filter(x => x.visible);
      break;
  }

  displayedNodes.sort((a, b) => {
    const an = node_cache[a.id];
    const bn = node_cache[b.id];
    return an.name.localeCompare(bn.name);
  });

  if (searchText?.trim() !== '') {
    displayedNodes = displayedNodes.filter(x => {
      const n = node_cache[x.id];
      return n.name.toLowerCase().includes(searchText)
        || n.description.toLowerCase().includes(searchText);
    });
  }

  return (
    <Window
      width={640}
      height={880}>
      <Window.Content>
        <Section title={`${web_org} Research and Development Network`}
          buttons={
            `${points && points["General Research"] || 0} points (+${points_last_tick && points_last_tick["General Research"] || 0}/t)`
          }>
          <Flex justify={"space-between"}>
            <Flex.Item>
              <Tabs>
                <Tabs.Tab
                  selected={tabIndex === 0}
                  onClick={() => setTabIndex(0)}>
                  Researched
                </Tabs.Tab>
                <Tabs.Tab
                  selected={tabIndex === 1}
                  onClick={() => setTabIndex(1)}>
                  Available
                </Tabs.Tab>
                <Tabs.Tab
                  selected={tabIndex === 2}
                  onClick={() => setTabIndex(2)}>
                  Future
                </Tabs.Tab>
              </Tabs>
            </Flex.Item>
            <Flex.Item align={"center"}>
              <Input
                value={searchText}
                onInput={(e, value) => setSearchText(value)}
                placeholder={"Search..."} />
            </Flex.Item>
          </Flex>
          <Box scrollable>
            {displayedNodes.map((n, idx) => {
              return (
                <TechNode node={n} key={`n${idx}`} />
              );
            })}
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};

const TechNode = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    node_cache,
    experiments,
    points,
  } = data;
  const { node } = props;
  const {
    id,
    can_afford,
    researched,
    available,
    visible,
  } = node;

  let thisNode = node_cache[id];
  return (
    <Section title={thisNode.name}
      buttons={!researched && (
        <Button
          icon="lightbulb"
          disabled={researched || !can_afford}
          onClick={() => act("researchNode", { node_id: thisNode.id })}>
          Research
        </Button>
      )}>
      <div className="Techweb__NodeProgress">
        {Object.keys(thisNode.costs).map((k, i) => {
          return (
            <ProgressBar
              key={`n${thisNode.id}p${i}`}
              ranges={{
                good: [0.5, Infinity],
                average: [0.25, 0.5],
                bad: [-Infinity, 0.25],
              }}
              value={Math.min(1, points[k] / thisNode.costs[k] || 1)}>
              {k} ({Math.min(thisNode.costs[k], points[k])}/{thisNode.costs[k]})
            </ProgressBar>
          );
        })}
      </div>
      <div className="Techweb__NodeDescription">{thisNode.description}</div>
      <Box className="Techweb__NodeUnlockedDesigns">
        {Object.keys(thisNode.design_ids).map((k, i) => {
          return (
            <span key={`${thisNode.id}${i}`}
              className={`design32x32 ${k} Techweb__DesignIcon`} />
          );
        })}
      </Box>
      {thisNode.required_experiments
        && thisNode.required_experiments.map((k, i) => {
          const thisExp = experiments[k];
          return (
            <Experiment key={`n${thisNode.id}e${i}`} exp={thisExp} />
          );
        })}
    </Section>
  );
};
