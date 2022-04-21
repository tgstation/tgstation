import { filter, map, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { useBackend, useLocalState } from '../backend';
import { Button, Section, Modal, Dropdown, Tabs, Box, Input, Flex, ProgressBar, Collapsible, Icon, Divider } from '../components';
import { Window, NtosWindow } from '../layouts';
import { Experiment } from './ExperimentConfigure';

// Data reshaping / ingestion (thanks stylemistake for the help, very cool!)
// This is primarily necessary due to measures that are taken to reduce the size
// of the sent static JSON payload to as minimal of a size as possible
// as larger sizes cause a delay for the user when opening the UI.

const remappingIdCache = {};
const remapId = id => remappingIdCache[id];

const selectRemappedStaticData = data => {
  // Handle reshaping of node cache to fill in unsent fields, and
  // decompress the node IDs
  const node_cache = {};
  for (let id of Object.keys(data.static_data.node_cache)) {
    const node = data.static_data.node_cache[id];
    const costs = Object.keys(node.costs || {}).map(x => ({
      type: remapId(x),
      value: node.costs[x],
    }));
    node_cache[remapId(id)] = {
      ...node,
      id: remapId(id),
      costs,
      prereq_ids: map(remapId)(node.prereq_ids || []),
      design_ids: map(remapId)(node.design_ids || []),
      unlock_ids: map(remapId)(node.unlock_ids || []),
      required_experiments: node.required_experiments || [],
      discount_experiments: node.discount_experiments || [],
    };
  }

  // Do the same as the above for the design cache
  const design_cache = {};
  for (let id of Object.keys(data.static_data.design_cache)) {
    const [name, classes] = data.static_data.design_cache[id];
    design_cache[remapId(id)] = {
      name: name,
      class: classes.startsWith("design") ? classes : `design32x32 ${classes}`,
    };
  }

  return {
    node_cache,
    design_cache,
  };
};

let remappedStaticData;

const useRemappedBackend = context => {
  const { data, ...rest } = useBackend(context);
  // Only remap the static data once, cache for future use
  if (!remappedStaticData) {
    const id_cache = data.static_data.id_cache;
    for (let i = 0; i < id_cache.length; i++) {
      remappingIdCache[i + 1] = id_cache[i];
    }
    remappedStaticData = selectRemappedStaticData(data);
  }
  return {
    data: {
      ...data,
      ...remappedStaticData,
    },
    ...rest,
  };
};

// Utility Functions

const abbreviations = {
  "General Research": "Gen. Res.",
};
const abbreviateName = name => abbreviations[name] ?? name;

// Actual Components

export const Techweb = (props, context) => {
  const { act, data } = useRemappedBackend(context);
  const {
    locked,
  } = data;
  return (
    <Window
      width={640}
      height={735}>
      <Window.Content scrollable>
        {!!locked && (
          <Modal width="15em" align="center" className="Techweb__LockedModal">
            <div><b>Console Locked</b></div>
            <Button
              icon="unlock"
              onClick={() => act("toggleLock")}>
              Unlock
            </Button>
          </Modal>
        )}
        <TechwebContent />
      </Window.Content>
    </Window>
  );
};

export const AppTechweb = (props, context) => {
  const { act, data } = useRemappedBackend(context);
  const {
    locked,
  } = data;
  return (
    <NtosWindow
      width={640}
      height={735}>
      <NtosWindow.Content scrollable>
        {!!locked && (
          <Modal width="15em" align="center" className="Techweb__LockedModal">
            <div><b>Console Locked</b></div>
            <Button
              icon="unlock"
              onClick={() => act("toggleLock")}>
              Unlock
            </Button>
          </Modal>
        )}
        <TechwebContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

export const TechwebContent = (props, context) => {
  const { act, data } = useRemappedBackend(context);
  const {
    points,
    points_last_tick,
    web_org,
    sec_protocols,
    t_disk,
    d_disk,
    locked,
  } = data;
  const [
    techwebRoute,
    setTechwebRoute,
  ] = useLocalState(context, 'techwebRoute', null);
  const [
    lastPoints,
    setLastPoints,
  ] = useLocalState(context, 'lastPoints', {});

  return (
    <Flex direction="column" className="Techweb__Viewport" height="100%">
      <Flex.Item className="Techweb__HeaderSection">
        <Flex className="Techweb__HeaderContent">
          <Flex.Item>
            <Box>
              Available points:
              <ul className="Techweb__PointSummary">
                {Object.keys(points).map(k => (
                  <li key={k}>
                    <b>{k}</b>: {points[k]}
                    {!!points_last_tick[k] && (
                      ` (+${points_last_tick[k]}/sec)`
                    )}
                  </li>
                ))}
              </ul>
            </Box>
            <Box>
              Security protocols:
              <span
                className={`Techweb__SecProtocol ${!!sec_protocols && "engaged"}`}>
                {sec_protocols ? "Engaged" : "Disengaged"}
              </span>
            </Box>
          </Flex.Item>
          <Flex.Item grow={1} />
          <Flex.Item>
            <Button fluid
              onClick={() => act("toggleLock")}
              icon="lock">
              Lock Console
            </Button>
            {d_disk && (
              <Flex.Item>
                <Button fluid
                  onClick={() => setTechwebRoute({ route: "disk", diskType: "design" })}>
                  Design Disk Inserted
                </Button>
              </Flex.Item>
            )}
            {t_disk && (
              <Flex.Item>
                <Button fluid
                  onClick={() => setTechwebRoute({ route: "disk", diskType: "tech" })}>
                  Tech Disk Inserted
                </Button>
              </Flex.Item>
            )}
          </Flex.Item>
        </Flex>
      </Flex.Item>
      <Flex.Item className="Techweb__RouterContent" height="100%">
        <TechwebRouter />
      </Flex.Item>
    </Flex>
  );
};

const TechwebRouter = (props, context) => {
  const [
    techwebRoute,
  ] = useLocalState(context, 'techwebRoute', null);

  const route = techwebRoute?.route;
  const RoutedComponent = (
    route === "details" && TechwebNodeDetail
    || route === "disk" && TechwebDiskMenu
    || TechwebOverview
  );

  return (
    <RoutedComponent {...techwebRoute} />
  );
};

const TechwebOverview = (props, context) => {
  const { act, data } = useRemappedBackend(context);
  const { nodes, node_cache, design_cache } = data;
  const [
    tabIndex,
    setTabIndex,
  ] = useLocalState(context, 'overviewTabIndex', 1);
  const [
    searchText,
    setSearchText,
  ] = useLocalState(context, 'searchText');

  // Only search when 3 or more characters have been input
  const searching = searchText && searchText.trim().length > 1;

  let displayedNodes = nodes;
  if (searching) {
    displayedNodes = displayedNodes.filter(x => {
      const n = node_cache[x.id];
      return n.name.toLowerCase().includes(searchText)
        || n.description.toLowerCase().includes(searchText)
        || n.design_ids.some(e =>
          design_cache[e].name.toLowerCase().includes(searchText));
    });
  } else {
    displayedNodes = sortBy(x => node_cache[x.id].name)(tabIndex < 2
      ? nodes.filter(x => x.tier === tabIndex)
      : nodes.filter(x => x.tier >= tabIndex));
  }

  const switchTab = tab => {
    setTabIndex(tab);
    setSearchText(null);
  };

  return (
    <Flex direction="column" height="100%">
      <Flex.Item>
        <Flex justify="space-between" className="Techweb__HeaderSectionTabs">
          <Flex.Item align="center" className="Techweb__HeaderTabTitle">
            Web View
          </Flex.Item>
          <Flex.Item grow={1}>
            <Tabs>
              <Tabs.Tab
                selected={!searching && tabIndex === 0}
                onClick={() => switchTab(0)}>
                Researched
              </Tabs.Tab>
              <Tabs.Tab
                selected={!searching && tabIndex === 1}
                onClick={() => switchTab(1)}>
                Available
              </Tabs.Tab>
              <Tabs.Tab
                selected={!searching && tabIndex === 2}
                onClick={() => switchTab(2)}>
                Future
              </Tabs.Tab>
              {!!searching && (
                <Tabs.Tab
                  selected>
                  Search Results
                </Tabs.Tab>
              )}
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
      <Flex.Item className={"Techweb__OverviewNodes"} height="100%">
        {displayedNodes.map(n => {
          return (
            <TechNode node={n} key={n.id} />
          );
        })}
      </Flex.Item>
    </Flex>
  );
};

const TechwebNodeDetail = (props, context) => {
  const { act, data } = useRemappedBackend(context);
  const { nodes } = data;
  const { selectedNode } = props;

  const selectedNodeData = selectedNode
    && nodes.find(x => x.id === selectedNode);
  return (
    <TechNodeDetail node={selectedNodeData} />
  );
};

const TechwebDiskMenu = (props, context) => {
  const { act, data } = useRemappedBackend(context);
  const { diskType } = props;
  const { t_disk, d_disk } = data;
  const [
    techwebRoute,
    setTechwebRoute,
  ] = useLocalState(context, 'techwebRoute', null);

  // Check for the disk actually being inserted
  if ((diskType === "design" && !d_disk) || (diskType === "tech" && !t_disk)) {
    return null;
  }

  const DiskContent = diskType === "design" && TechwebDesignDisk
    || TechwebTechDisk;
  return (
    <Flex direction="column" height="100%">
      <Flex.Item>
        <Flex justify="space-between" className="Techweb__HeaderSectionTabs">
          <Flex.Item align="center" className="Techweb__HeaderTabTitle">
            {diskType.charAt(0).toUpperCase() + diskType.slice(1)} Disk
          </Flex.Item>
          <Flex.Item grow={1}>
            <Tabs>
              <Tabs.Tab selected>
                Stored Data
              </Tabs.Tab>
            </Tabs>
          </Flex.Item>
          <Flex.Item align="center">
            {diskType === "tech" && (
              <Button
                icon="save"
                onClick={() => act("loadTech")}>
                Web &rarr; Disk
              </Button>
            )}
            <Button
              icon="upload"
              onClick={() => act("uploadDisk", { type: diskType })}>
              Disk &rarr; Web
            </Button>
            <Button
              icon="trash"
              onClick={() => act("eraseDisk", { type: diskType })}>
              Erase
            </Button>
            <Button
              icon="eject"
              onClick={() => {
                act("ejectDisk", { type: diskType });
                setTechwebRoute(null);
              }}>
              Eject
            </Button>
            <Button
              icon="home"
              onClick={() => setTechwebRoute(null)}>
              Home
            </Button>
          </Flex.Item>
        </Flex>
      </Flex.Item>
      <Flex.Item grow={1} className="Techweb__OverviewNodes">
        <DiskContent />
      </Flex.Item>
    </Flex>
  );
};

const TechwebDesignDisk = (props, context) => {
  const { act, data } = useRemappedBackend(context);
  const {
    design_cache,
    researched_designs,
    d_disk,
  } = data;
  const { blueprints } = d_disk;
  const [
    selectedDesign,
    setSelectedDesign,
  ] = useLocalState(context, "designDiskSelect", null);
  const [
    showModal,
    setShowModal,
  ] = useLocalState(context, 'showDesignModal', -1);

  const designIdByIdx = Object.keys(researched_designs);
  const designOptions = flow([
    filter(x => x.toLowerCase() !== "error"),
    map((id, idx) => `${design_cache[id].name} [${idx}]`),
    sortBy(x => x),
  ])(designIdByIdx);

  return (
    <>
      {showModal >= 0 && (
        <Modal width="20em">
          <Flex direction="column" className="Techweb__DesignModal">
            <Flex.Item>
              Select a design to save...
            </Flex.Item>
            <Flex.Item>
              <Dropdown
                width="100%"
                options={designOptions}
                onSelected={val => {
                  const idx = parseInt(val.split('[').pop().split(']')[0], 10);
                  setSelectedDesign(designIdByIdx[idx]);
                }} />
            </Flex.Item>
            <Flex.Item align="center">
              <Button
                onClick={() => setShowModal(-1)}>
                Cancel
              </Button>
              <Button
                disabled={selectedDesign === null}
                onClick={() => {
                  act("writeDesign", {
                    slot: showModal + 1,
                    selectedDesign: selectedDesign,
                  });
                  setShowModal(-1);
                  setSelectedDesign(null);
                }}>
                Select
              </Button>
            </Flex.Item>
          </Flex>
        </Modal>
      )}
      {blueprints.map((x, i) => (
        <Section
          key={i}
          title={`Slot ${i + 1}`}
          buttons={
            <>
              {x !== null && (
                <Button
                  icon="upload"
                  onClick={() => act("uploadDesignSlot", { slot: i + 1 })}>
                  Upload Design to Web
                </Button>
              )}
              <Button
                icon="save"
                onClick={() => setShowModal(i)}>
                {x !== null ? "Overwrite Slot" : "Load Design to Slot"}
              </Button>
              {x !== null && (
                <Button
                  icon="trash"
                  onClick={() => act("clearDesignSlot", { slot: i + 1 })}>
                  Clear Slot
                </Button>
              )}
            </>
          }>
          {x === null && 'Empty' || (
            <>
              Contains the design for <b>{design_cache[x].name}</b>:<br />
              <span
                className={`${design_cache[x].class} Techweb__DesignIcon`} />
            </>
          )}
        </Section>
      ))}
    </>
  );
};

const TechwebTechDisk = (props, context) => {
  const { act, data } = useRemappedBackend(context);
  const { t_disk } = data;
  const { stored_research } = t_disk;

  return Object.keys(stored_research).map(x => ({ id: x })).map(n => (
    <TechNode key={n.id} nocontrols node={n} />
  ));
};

const TechNodeDetail = (props, context) => {
  const { act, data } = useRemappedBackend(context);
  const {
    nodes,
    node_cache,
  } = data;
  const { node } = props;
  const { id } = node;
  const { prereq_ids, unlock_ids } = node_cache[id];
  const [
    tabIndex,
    setTabIndex,
  ] = useLocalState(context, 'nodeDetailTabIndex', 0);
  const [
    techwebRoute,
    setTechwebRoute,
  ] = useLocalState(context, 'techwebRoute', null);

  const prereqNodes = nodes.filter(x => prereq_ids.includes(x.id));
  const complPrereq = prereq_ids
    .filter(x => nodes.find(y => y.id === x)?.tier === 0).length;
  const unlockedNodes = nodes.filter(x => unlock_ids.includes(x.id));

  return (
    <Flex direction="column" height="100%">
      <Flex.Item shrink={1}>
        <Flex justify="space-between" className="Techweb__HeaderSectionTabs">
          <Flex.Item align="center" className="Techweb__HeaderTabTitle">
            Node
          </Flex.Item>
          <Flex.Item grow={1}>
            <Tabs>
              <Tabs.Tab
                selected={tabIndex === 0}
                onClick={() => setTabIndex(0)}>
                Required ({complPrereq}/{prereqNodes.length})
              </Tabs.Tab>
              <Tabs.Tab
                selected={tabIndex === 1}
                disabled={unlockedNodes.length === 0}
                onClick={() => setTabIndex(1)}>
                Unlocks ({unlockedNodes.length})
              </Tabs.Tab>
            </Tabs>
          </Flex.Item>
          <Flex.Item align="center">
            <Button
              icon="home"
              onClick={() => setTechwebRoute(null)}>
              Home
            </Button>
          </Flex.Item>
        </Flex>
      </Flex.Item>
      <Flex.Item className="Techweb__OverviewNodes" shrink={0}>
        <TechNode node={node} nodetails />
        <Divider />
      </Flex.Item>
      {tabIndex === 0 && (
        <Flex.Item className="Techweb__OverviewNodes" grow={1}>
          {prereqNodes.map(n => (
            <TechNode key={n.id} node={n} />
          ))}
        </Flex.Item>
      )}
      {tabIndex === 1 && (
        <Flex.Item className="Techweb__OverviewNodes" grow={1}>
          {unlockedNodes.map(n => (
            <TechNode key={n.id} node={n} />
          ))}
        </Flex.Item>
      )}
    </Flex>
  );
};

const TechNode = (props, context) => {
  const { act, data } = useRemappedBackend(context);
  const {
    node_cache,
    design_cache,
    experiments,
    points,
    nodes,
  } = data;
  const { node, nodetails, nocontrols } = props;
  const { id, can_unlock, tier } = node;
  const {
    name,
    description,
    costs,
    design_ids,
    prereq_ids,
    required_experiments,
    discount_experiments,
  } = node_cache[id];
  const [
    techwebRoute,
    setTechwebRoute,
  ] = useLocalState(context, 'techwebRoute', null);
  const [
    tabIndex,
    setTabIndex,
  ] = useLocalState(context, 'nodeDetailTabIndex', 0);

  const expcompl = required_experiments
    .filter(x => experiments[x]?.completed)
    .length;
  const experimentProgress = (
    <ProgressBar
      ranges={{
        good: [0.5, Infinity],
        average: [0.25, 0.5],
        bad: [-Infinity, 0.25],
      }}
      value={expcompl / required_experiments.length}>
      Experiments ({expcompl}/{required_experiments.length})
    </ProgressBar>
  );

  const techcompl = prereq_ids
    .filter(x => nodes.find(y => y.id === x)?.tier === 0)
    .length;
  const techProgress = (
    <ProgressBar
      ranges={{
        good: [0.5, Infinity],
        average: [0.25, 0.5],
        bad: [-Infinity, 0.25],
      }}
      value={techcompl / prereq_ids.length}>
      Tech ({techcompl}/{prereq_ids.length})
    </ProgressBar>
  );

  // Notice this logic will have te be changed if we make the discounts
  // pool-specific
  const nodeDiscount = Object.keys(discount_experiments)
    .filter(x => experiments[x]?.completed)
    .reduce((tot, curr) => {
      return tot + discount_experiments[curr];
    }, 0);

  return (
    <Section
      className="Techweb__NodeContainer"
      title={name}
      buttons={!nocontrols && (
        <>
          {!nodetails && (
            <Button
              icon="tasks"
              onClick={() => {
                setTechwebRoute({ route: "details", selectedNode: id });
                setTabIndex(0);
              }}>
              Details
            </Button>
          )}
          {tier > 0 && (
            <Button
              icon="lightbulb"
              disabled={!can_unlock || tier > 1}
              onClick={() => act("researchNode", { node_id: id })}>
              Research
            </Button>
          )}
        </>
      )}>
      {tier !== 0 && (
        <Flex className="Techweb__NodeProgress">
          {costs.map(k => {
            const reqPts = Math.max(0, k.value - nodeDiscount);
            const nodeProg = Math.min(reqPts, points[k.type]) || 0;
            return (
              <Flex.Item key={k.type} grow={1} basis={0}>
                <ProgressBar
                  ranges={{
                    good: [0.5, Infinity],
                    average: [0.25, 0.5],
                    bad: [-Infinity, 0.25],
                  }}
                  value={reqPts === 0
                    ? 1
                    : Math.min(1, (points[k.type]||0) / reqPts)}>
                  {abbreviateName(k.type)} ({nodeProg}/{reqPts})
                </ProgressBar>
              </Flex.Item>
            );
          })}
          {prereq_ids.length > 0 && (
            <Flex.Item grow={1} basis={0}>
              {techProgress}
            </Flex.Item>
          )}
          {required_experiments.length > 0 && (
            <Flex.Item grow={1} basis={0}>
              {experimentProgress}
            </Flex.Item>
          )}
        </Flex>
      )}
      <Box className="Techweb__NodeDescription" mb={2}>
        {description}
      </Box>
      <Box className="Techweb__NodeUnlockedDesigns" mb={2}>
        {design_ids.map((k, i) => (
          <Button
            key={id}
            className={`${design_cache[k].class} Techweb__DesignIcon`}
            tooltip={design_cache[k].name}
            tooltipPosition={i % 15 < 7 ? "right" : "left"}
          />
        ))}
      </Box>
      {required_experiments.length > 0 && (
        <Collapsible
          className="Techweb__NodeExperimentsRequired"
          title="Required Experiments">
          {required_experiments.map(k => {
            const thisExp = experiments[k];
            if (thisExp === null || thisExp === undefined) {
              return (
                <LockedExperiment />
              );
            }
            return (
              <Experiment key={thisExp} exp={thisExp} />
            );
          })}
        </Collapsible>
      )}
      {Object.keys(discount_experiments).length > 0 && (
        <Collapsible
          className="TechwebNodeExperimentsRequired"
          title="Discount-Eligible Experiments">
          {Object.keys(discount_experiments).map(k => {
            const thisExp = experiments[k];
            if (thisExp === null || thisExp === undefined) {
              return (
                <LockedExperiment />
              );
            }
            return (
              <Experiment key={thisExp} exp={thisExp}>
                <Box className="Techweb__ExperimentDiscount">
                  Provides a discount of {discount_experiments[k]} points
                  to all required point pools.
                </Box>
              </Experiment>
            );
          })}
        </Collapsible>
      )}
    </Section>
  );
};

const LockedExperiment = (props, context) => {
  return (
    <Box m={1} className="ExperimentConfigure__ExperimentPanel">
      <Button fluid
        backgroundColor="#40628a"
        className="ExperimentConfigure__ExperimentName"
        disabled>
        <Flex align="center" justify="space-between">
          <Flex.Item
            color="rgba(0, 0, 0, 0.6)">
            <Icon name="lock" />
            Undiscovered Experiment
          </Flex.Item>
          <Flex.Item
            color="rgba(0, 0, 0, 0.5)">
            ???
          </Flex.Item>
        </Flex>
      </Button>
      <Box className={"ExperimentConfigure__ExperimentContent"}>
        This experiment has not been discovered yet, continue researching
        nodes in the tree to discover the contents of this experiment.
      </Box>
    </Box>
  );
};
