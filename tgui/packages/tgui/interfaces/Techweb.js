import { Button, Section, NoticeBox, Tabs, Box, Input, Flex, ProgressBar, Collapsible } from '../components';
import { Experiment } from './ExperimentConfigure';
import { Window } from '../layouts';
import { useBackend, useLocalState } from '../backend';
import { Fragment } from 'inferno';

export const Techweb = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    nodes,
    node_cache,
    design_cache,
    experiments,
    points,
    points_last_tick,
    web_org,
    sec_protocols,
    t_disk,
    d_disk,
  } = data;
  const [
    tabIndex,
    setTabIndex,
  ] = useLocalState(context, 'tabIndex', 1);
  const [
    searchText,
    setSearchText,
  ] = useLocalState(context, 'searchText');
  const [
    techwebRoute,
    setTechwebRoute,
  ] = useLocalState(context, 'techwebRoute', null)

  return (
    <Window
      width={640}
      height={880}
      scrollable>
      <Window.Content>
        <Section title={`${web_org} Research and Development Network`}
          className="Techweb__ViewportContainer">
          <Flex direction="column" className="Techweb__Viewport">
            <Flex.Item className="Techweb__HeaderSection">
              <Box className="Techweb__HeaderContent">
                Available points:
                <ul className="Techweb__PointSummary">
                  {Object.keys(points).map((k) => (
                    <li key={`ps${k}`}>
                      <b>{k}</b>: {points[k]} (+{points_last_tick[k] || 0}/t)
                    </li>
                  ))}
                </ul>
                Security protocols:
                <span
                  className={`Techweb__SecProtocol ${!!sec_protocols && "engaged"}`}>
                  {sec_protocols ? "Engaged" : "Disengaged"}
                </span> <br />
                Disks:
                <span>
                  {d_disk && (
                    <Button
                      icon="lightbulb"
                      onClick={() => setTechwebRoute({ route: "disk", diskType: "design" })}>
                      Design Disk
                    </Button>
                  )}
                  {t_disk && (
                    <Button
                      icon="lightbulb"
                      onClick={() => setTechwebRoute({ route: "disk", diskType: "tech" })}>
                      Tech Disk
                    </Button>
                  )}
                </span>
              </Box>
              <Flex justify={"space-between"} className="Techweb__HeaderSectionTabs">
                <Flex.Item align="center" className="Techweb__HeaderTabTitle">
                  <span>Nodes</span>
                </Flex.Item>
                <Flex.Item grow={1}>
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
            </Flex.Item>
            <TechwebRouter />
          </Flex>
        </Section>
      </Window.Content>
    </Window>
  );
};

const TechwebRouter = (props, context) => {
  const { act, data } = useBackend(context);
  const [
    techwebRoute,
    setTechwebRoute,
  ] = useLocalState(context, 'techwebRoute', null)

  if (!techwebRoute?.route) {
    return (<TechwebOverview />);
  }

  let content = null;
  switch (techwebRoute.route) {
    case "details":
      content = (<TechwebNodeDetail {...techwebRoute} />);
      break;
    case "disk":
      content = (<TechwebDiskMenu {...techwebRoute} />);
      break;
    default:
      content = (<TechwebOverview {...techwebRoute} />);
  };

  return (
    <Flex.Item grow={1} className={"Techweb__NodesSection"}>
      {content}
    </Flex.Item>
  );
};

const TechwebOverview = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    nodes,
    node_cache,
    design_cache,
  } = data;
  const [
    tabIndex,
  ] = useLocalState(context, 'tabIndex', 1);
  const [
    searchText,
  ] = useLocalState(context, 'searchText');

  let displayedNodes = tabIndex < 2
    ? nodes.filter(x => x.tier === tabIndex)
    : nodes.filter(x => x.tier >= tabIndex);
  displayedNodes.sort((a, b) => {
    const an = node_cache[a.id];
    const bn = node_cache[b.id];
    return an.name.localeCompare(bn.name);
  });

  if (searchText && searchText.trim() !== '') {
    displayedNodes = displayedNodes.filter(x => {
      const n = node_cache[x.id];
      return n.name.toLowerCase().includes(searchText)
        || n.description.toLowerCase().includes(searchText)
        || Object.keys(n.design_ids).some(e =>
          design_cache[e].name.toLowerCase().includes(searchText));
    });
  }

  return (
    <Fragment>
      {displayedNodes.map((n) => {
        return (
          <TechNode node={n} key={`n${n.id}`} />
        );
      })}
    </Fragment>
  );
};

const TechwebNodeDetail = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    nodes,
  } = data;
  const { selectedNode } = props;

  const selectedNodeData = selectedNode && nodes.filter(x => x.id == selectedNode)[0];
  return (
    <TechNodeDetail node={selectedNodeData} />
  );
}

const TechwebDiskMenu = (props, context) => {
  const { act, data } = useBackend(context);
  const { diskType } = props;
  const {
    t_disk,
    d_disk,
  } = data;
  const [
    techwebRoute,
    setTechwebRoute,
  ] = useLocalState(context, 'techwebRoute', null)

  // Check for the disk actually being inserted
  if ((diskType === "design" && !d_disk) || (diskType === "tech" && !t_disk)) {
    setTechwebRoute(null);
    return;
  }

  const content = diskType === "design" ? (<TechwebDesignDisk />) : (<TechwebTechDisk />);
  return (
    <div>
      <Button
        onClick={() => act("ejectDisk", { type: diskType })}>
        Eject Disk
      </Button>
      {content}
    </div>
  );
};

const TechwebDesignDisk = (props, context) => {
  const { act, data } = useBackend(context);

  return (
    <Fragment>
      Design Disk
    </Fragment>
  );
};

const TechwebTechDisk = (props, context) => {
  const { act, data } = useBackend(context);

  return (
    <Fragment>
      Tech Disk
    </Fragment>
  );
};

// rework the selected node to be included in route data because otherwise there will be issues with route transitions
const TechNodeDetail = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    nodes,
    node_cache,
    design_cache,
    experiments,
    points,
  } = data;
  const { node } = props;
  const {
    id,
    can_unlock,
    tier,
  } = node;
  let thisNode = node_cache[id];

  const prereqNodes = thisNode.prereq_ids.reduce((arr, val) => {
    const foundNode = nodes.filter(x => x.id == val)[0];
    if (foundNode)
      arr.push(foundNode);
    return arr;
  }, []);

  const unlockedNodes = Object.keys(thisNode.unlock_ids).reduce((arr, val) => {
    const foundNode = nodes.filter(x => x.id == val)[0];
    if (foundNode)
      arr.push(foundNode);
    return arr;
  }, []);

  return (
    <div>
      <TechNode node={node} />
      {prereqNodes.length > 0 && (
        <Section title="Required">
          {prereqNodes.map((n) =>
            (<TechNode node={n} key={`nr${n.id}`} />)
          )}
        </Section>
      )}
      {unlockedNodes.length > 0 && (
        <Section title="Unlocks">
          {unlockedNodes.map((n) =>
            (<TechNode node={n} key={`nu${n.id}`} />)
          )}
        </Section>
      )}
    </div>
  );
};

const TechNode = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    node_cache,
    design_cache,
    experiments,
    points,
  } = data;
  const { node } = props;
  const {
    id,
    can_unlock,
    tier,
  } = node;
  let thisNode = node_cache[id];
  let reqExp = thisNode?.required_experiments;
  const [
    techwebRoute,
    setTechwebRoute,
  ] = useLocalState(context, 'techwebRoute', null)
  const selected = false;

  const expcompl = reqExp.filter(x => experiments[x]?.completed).length;
  const experimentProgress = (
    <ProgressBar
      ranges={{
        good: [0.5, Infinity],
        average: [0.25, 0.5],
        bad: [-Infinity, 0.25],
      }}
      value={expcompl / reqExp.length}>
      Experiments ({expcompl}/{reqExp.length})
    </ProgressBar>
  );

  return (
    <Section title={thisNode.name}
      buttons={
        <span>
          <Button
            icon={selected ? "arrow-left" : "tasks"}
            onClick={() => {
              setTechwebRoute({ route: "details", selectedNode: node.id });
            }}>
            {selected ? "Back" : "Details"}
          </Button>
          {tier === 1 && (
          <Button
            icon="lightbulb"
            disabled={!can_unlock}
            onClick={() => act("researchNode", { node_id: thisNode.id })}>
            Research
          </Button>)}
        </span>
      }
      level={1}
      className="Techweb__NodeContainer">
      {tier !== 0 && (
        <Flex className="Techweb__NodeProgress">
          {Object.keys(thisNode.costs).map((k, i) => {
            const nodeProg = Math.min(thisNode.costs[k], points[k]) || 0;
            return (
              <Flex.Item grow={1} basis={0}
                key={`n${thisNode.id}p${i}`}>
                <ProgressBar
                  ranges={{
                    good: [0.5, Infinity],
                    average: [0.25, 0.5],
                    bad: [-Infinity, 0.25],
                  }}
                  value={Math.min(1, points[k] / thisNode.costs[k])}>
                  {k} ({nodeProg}/{thisNode.costs[k]})
                </ProgressBar>
              </Flex.Item>
            );
          })}
          {reqExp?.length > 0 && (
            <Flex.Item grow={1} basis={0}>
              {experimentProgress}
            </Flex.Item>
          )}
        </Flex>
      )}
      <div className="Techweb__NodeDescription">{thisNode.description}</div>
      <Box className="Techweb__NodeUnlockedDesigns">
        {Object.keys(thisNode.design_ids).map((k, i) => {
          return (
            <Button key={`d${thisNode.id}`}
              className={`${design_cache[k].class} Techweb__DesignIcon`}
              tooltip={design_cache[k].name}
              tooltipPosition={i % 15 < 7 ? "right" : "left"} />
          );
        })}
      </Box>
      {thisNode.required_experiments?.length > 0
        && (
          <Collapsible
            className="Techweb__NodeExperimentsRequired"
            title="Required Experiments">
            {thisNode.required_experiments.map((k) => {
              const thisExp = experiments[k];
              if (thisExp === null || thisExp === undefined) {
                return (
                  <div>Failed to find experiment &apos;{k}&apos;</div>
                );
              }
              return (
                <Experiment key={`n${thisNode.id}e${thisExp}`} exp={thisExp} />
              );
            })}
          </Collapsible>
        )}
    </Section>
  );
};
