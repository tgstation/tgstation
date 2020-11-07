import { Button, Section, Modal, Dropdown, Tabs, Box, Input, Flex, ProgressBar, Collapsible } from '../components';
import { Experiment } from './ExperimentConfigure';
import { Window } from '../layouts';
import { useBackend, useLocalState } from '../backend';
import { Fragment } from 'inferno';
import { flow } from 'common/fp';
import { sortBy, filter, map } from 'common/collections';

// Data reshaping / ingestion (thanks stylemistake for the help, very cool!)
// This is primarily necessary due to measures that are taken to reduce the size
// of the sent static JSON payload to as minimal of a size as possible
// as larger sizes cause a delay for the user when opening the UI.

let remappingIdCache;
const remapId = id => typeof(id) === "string"
  ? remappingIdCache[parseInt(id, 10) - 1]
  : remappingIdCache[id - 1];

const selectRemappedStaticData = data => {
  // Handle reshaping of node cache to fill in unsent fields, and
  // decompress the node IDs
  const node_cache = Object.keys(data.static_data.node_cache)
    .reduce((cache, id) => {
      const n = data.static_data.node_cache[id];
      const costs = Object.keys(n.costs || {}).map(x => ({
        type: remapId(x),
        value: n.costs[x],
      }));
      return {
        ...cache,
        [remapId(id)]: {
          ...n,
          id: remapId(id),
          costs: costs,
          prereq_ids: n.prereq_ids?.map(x => remapId(x)) || [],
          design_ids: n.design_ids?.map(x => remapId(x)) || [],
          unlock_ids: n.unlock_ids?.map(x => remapId(x)) || [],
          required_experiments: n.required_experiments || [],
          discount_experiments: n.discount_experiments || [],
        },
      };
    }, {});

  // Do the same as the above for the design cache
  const design_cache = Object.keys(data.static_data.design_cache)
    .reduce((cache, id) => {
      const d = data.static_data.design_cache[id];
      return {
        ...cache,
        [remapId(id)]: {
          ...d,
        },
      };
    }, {});

  return {
    node_cache,
    design_cache,
  };
};

let remappedStaticData;

const selectRemappedData = data => {
  // Only remap the static data once, cache for future use
  if (!remappedStaticData) {
    remappingIdCache = data.static_data.id_cache;
    remappedStaticData = selectRemappedStaticData(data);
  }

  // Take only non-static data to combine with static data
  const {
    static_data,
    ...rest
  } = data;

  return {
    ...rest,
    ...remappedStaticData,
  };
};

let remappedInputData;
let remappedOutputData;

const useRemappedBackend = context => {
  const { data, ...rest } = useBackend(context);
  // Recalculate when input data is different
  if (remappedInputData !== data) {
    remappedInputData = data;
    remappedOutputData = selectRemappedData(data);
  }
  return {
    data: remappedOutputData,
    ...rest,
  };
};

// Components

export const Techweb = (props, context) => {
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

  return (
    <Window
      width={640}
      height={880}
      title={`${web_org} Research and Development Network`}>
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
      <Window.Content>
        <Flex direction="column" className="Techweb__Viewport" height="100%">
          <Flex.Item className="Techweb__HeaderSection">
            <Flex className="Techweb__HeaderContent">
              <Flex.Item>
                <Box>
                  Available points:
                  <ul className="Techweb__PointSummary">
                    {Object.keys(points).map(k => (
                      <li key={k}>
                        <b>{k}</b>: {points[k]} (+{points_last_tick[k]||0}/t)
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
      </Window.Content>
    </Window>
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

  let displayedNodes = sortBy(x => node_cache[x.id].name)(tabIndex < 2
    ? nodes.filter(x => x.tier === tabIndex)
    : nodes.filter(x => x.tier >= tabIndex));

  if (searchText && searchText.trim() !== '') {
    displayedNodes = displayedNodes.filter(x => {
      const n = node_cache[x.id];
      return n.name.toLowerCase().includes(searchText)
        || n.description.toLowerCase().includes(searchText)
        || n.design_ids.some(e =>
          design_cache[e].name.toLowerCase().includes(searchText));
    });
  }

  return (
    <Flex direction="column" height="100%">
      <Flex.Item>
        <Flex justify="space-between" className="Techweb__HeaderSectionTabs">
          <Flex.Item align="center" className="Techweb__HeaderTabTitle">
            <span>Web View</span>
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
    <Fragment>
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
      {blueprints.map((x, i) => {
        return (
          <Section
            title={`Slot ${i + 1}`}
            key={i}
            buttons={
              <span>
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
              </span>
            }>
            {x === null && (
              <span>Empty</span>
            ) || (
              <span>
                Contains the design for <b>{design_cache[x].name}</b>:<br />
                <span
                  className={`${design_cache[x].class} Techweb__DesignIcon`} />
              </span>
            )}
          </Section>
        );
      })}
    </Fragment>
  );
};

const TechwebTechDisk = (props, context) => {
  const { act, data } = useRemappedBackend(context);
  const { t_disk } = data;
  const { stored_research } = t_disk;

  return Object.keys(stored_research).map(x => ({ id: x })).map(n => (
    <TechNode nocontrols node={n} key={n.id} />
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
  const unlockedNodes = nodes.filter(x => unlock_ids.includes(x.id));

  return (
    <Flex direction="column" height="100%">
      <Flex.Item>
        <Flex justify="space-between" className="Techweb__HeaderSectionTabs">
          <Flex.Item align="center" className="Techweb__HeaderTabTitle">
            Node
          </Flex.Item>
          <Flex.Item grow={1}>
            <Tabs>
              <Tabs.Tab
                selected={tabIndex === 0}
                onClick={() => setTabIndex(0)}>
                Details
              </Tabs.Tab>
              <Tabs.Tab
                selected={tabIndex === 1}
                disabled={prereqNodes.length === 0}
                onClick={() => setTabIndex(1)}>
                Required ({prereqNodes.length})
              </Tabs.Tab>
              <Tabs.Tab
                selected={tabIndex === 2}
                disabled={unlockedNodes.length === 0}
                onClick={() => setTabIndex(2)}>
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
      {tabIndex === 0 && (
        <Flex.Item className="Techweb__OverviewNodes">
          <TechNode node={node} nodetails />
        </Flex.Item>
      )}
      {tabIndex === 1 && (
        <Flex.Item className="Techweb__OverviewNodes">
          {prereqNodes.map(n =>
            (<TechNode node={n} key={n.id} />)
          )}
        </Flex.Item>
      )}
      {tabIndex === 2 && (
        <Flex.Item className="Techweb__OverviewNodes">
          {unlockedNodes.map(n =>
            (<TechNode node={n} key={n.id} />)
          )}
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
  } = data;
  const { node, nodetails, nocontrols } = props;
  const { id, can_unlock, tier } = node;
  const {
    name,
    description,
    costs,
    design_ids,
    required_experiments,
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
    .filter(x => experiments[x]?.completed).length;
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

  return (
    <Section title={name}
      buttons={!nocontrols && (
        <span>
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
          {tier === 1 && (
            <Button
              icon="lightbulb"
              disabled={!can_unlock}
              onClick={() => act("researchNode", { node_id: id })}>
              Research
            </Button>)}
        </span>
      )}
      level={1}
      className="Techweb__NodeContainer">
      {tier !== 0 && (
        <Flex className="Techweb__NodeProgress">
          {costs.map(k => {
            const nodeProg = Math.min(k.value, points[k.type]) || 0;
            return (
              <Flex.Item grow={1} basis={0}
                key={k.type}>
                <ProgressBar
                  ranges={{
                    good: [0.5, Infinity],
                    average: [0.25, 0.5],
                    bad: [-Infinity, 0.25],
                  }}
                  value={Math.min(1, points[k.type] / k.value)}>
                  {k.type} ({nodeProg}/{k.value})
                </ProgressBar>
              </Flex.Item>
            );
          })}
          {required_experiments?.length > 0 && (
            <Flex.Item grow={1} basis={0}>
              {experimentProgress}
            </Flex.Item>
          )}
        </Flex>
      )}
      <div className="Techweb__NodeDescription">{description}</div>
      <Box className="Techweb__NodeUnlockedDesigns">
        {design_ids.map((k, i) => {
          return (
            <Button key={id}
              className={`${design_cache[k].class} Techweb__DesignIcon`}
              tooltip={design_cache[k].name}
              tooltipPosition={i % 15 < 7 ? "right" : "left"} />
          );
        })}
      </Box>
      {required_experiments?.length > 0
        && (
          <Collapsible
            className="Techweb__NodeExperimentsRequired"
            title="Required Experiments">
            {required_experiments.map(k => {
              const thisExp = experiments[k];
              if (thisExp === null || thisExp === undefined) {
                return (
                  <div>Failed to find experiment &apos;{k}&apos;</div>
                );
              }
              return (
                <Experiment key={thisExp} exp={thisExp} />
              );
            })}
          </Collapsible>
        )}
    </Section>
  );
};
