import '../styles/interfaces/AntagInfoHeretic.scss';

import { useState } from 'react';
import {
  Box,
  Button,
  DmIcon,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { logger } from '../logging';
import {
  type Objective,
  ObjectivePrintout,
  ReplaceObjectivesButton,
} from './common/Objectives';

const hereticRed = {
  color: '#e03c3c',
};

const hereticBlue = {
  fontWeight: 'bold',
  color: '#2185d0',
};

const hereticPurple = {
  fontWeight: 'bold',
  color: '#bd54e0',
};

const hereticGreen = {
  fontWeight: 'bold',
  color: '#20b142',
};

const hereticYellow = {
  fontWeight: 'bold',
  color: 'yellow',
};

type IconParams = {
  icon: string;
  state: string;
  frame: number;
  dir: number;
  moving: BooleanLike;
};

type Knowledge = {
  path: string;
  icon_params: IconParams;
  name: string;
  desc: string;
  gainFlavor: string;
  cost: number;
  bgr: string;
  category?: ShopCategory;
  depth: number;
  done: BooleanLike;
  ascension: BooleanLike;
  disabled: BooleanLike;
};

enum ShopCategory {
  Tree = 'tree',
  Shop = 'shop',
  Draft = 'draft',
  Start = 'start',
}

type KnowledgeTier = {
  nodes: Knowledge[];
};

type HereticPassive = {
  name: string;
  description: string[];
};

type HereticPath = {
  route: string;
  complexity: string;
  complexity_color: string;
  description: string[];
  pros: string[];
  cons: string[];
  tips: string[];
  starting_knowledge: Knowledge;
  preview_abilities: Knowledge[];
  passive: HereticPassive;
};

type Info = {
  charges: number;
  total_sacrifices: number;
  ascended: BooleanLike;
  objectives: Objective[];
  can_change_objective: BooleanLike;
  paths: HereticPath[];
  knowledge_shop: Knowledge[];
  knowledge_tiers: KnowledgeTier[];
  passive_level: number;
};

const IntroductionSection = (props) => {
  const { data } = useBackend<Info>();
  const { objectives, ascended, can_change_objective } = data;

  return (
    <Stack justify="space-evenly" height="100%" width="100%">
      <Stack.Item grow>
        <Section title="You are the Heretic!" fill fontSize="14px">
          <Stack vertical>
            <FlavorSection />
            <Stack.Divider />
            <GuideSection />
            <Stack.Divider />
            <InformationSection />
            <Stack.Divider />
            {!ascended && (
              <Stack.Item>
                <ObjectivePrintout
                  fill
                  titleMessage={
                    can_change_objective
                      ? 'In order to ascend, you have these tasks to fulfill'
                      : 'Use your dark knowledge to fulfil your personal goal'
                  }
                  objectives={objectives}
                  objectiveFollowup={
                    <ReplaceObjectivesButton
                      can_change_objective={can_change_objective}
                      button_title={'Reject Ascension'}
                      button_colour={'red'}
                      button_tooltip={
                        'Turn your back on the Mansus to accomplish a task of your choosing. Selecting this option will prevent you from ascending!'
                      }
                    />
                  }
                />
              </Stack.Item>
            )}
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const FlavorSection = () => {
  return (
    <Stack.Item>
      <Stack vertical textAlign="center" fontSize="14px">
        <Stack.Item>
          <i>
            Another day at a meaningless job. You feel a&nbsp;
            <span style={hereticBlue}>shimmer</span>
            &nbsp;around you, as a realization of something&nbsp;
            <span style={hereticRed}>strange</span>
            &nbsp;in the air unfolds. You look inwards and discover something
            that will change your life.
          </i>
        </Stack.Item>
        <Stack.Item>
          <b>
            The <span style={hereticPurple}>Gates of Mansus</span>
            &nbsp;open up to your mind.
          </b>
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

const GuideSection = () => {
  return (
    <Stack.Item>
      <Stack vertical fontSize="12px">
        <Stack.Item>
          - Find reality smashing&nbsp;
          <span style={hereticPurple}>influences</span>
          &nbsp;around the station invisible to the normal eye and&nbsp;
          <b>right click</b> on them to harvest them for&nbsp;
          <span style={hereticBlue}>knowledge points</span>. Tapping them makes
          them visible to all after a short time. Dreaming of Mansus may help to
          find them.
        </Stack.Item>
        <Stack.Item>
          - Use your&nbsp;
          <span style={hereticRed}>Living Heart action</span>
          &nbsp;to track down&nbsp;
          <span style={hereticRed}>sacrifice targets</span>, but be careful:
          Pulsing it will produce a heartbeat sound that nearby people may hear.
          This action is tied to your <b>heart</b> - if you lose it, you must
          complete a ritual to regain it.
        </Stack.Item>
        <Stack.Item>
          - Draw a&nbsp;
          <span style={hereticGreen}>transmutation rune</span> by using a
          drawing tool (a pen or crayon) on the floor while having&nbsp;
          <span style={hereticGreen}>Mansus Grasp</span>
          &nbsp;active in your other hand. This rune allows you to complete
          rituals and sacrifices.
        </Stack.Item>
        <Stack.Item>
          - Follow your <span style={hereticRed}>Living Heart</span> to find
          your targets. Bring them back to a&nbsp;
          <span style={hereticGreen}>transmutation rune</span> in critical or
          worse condition to&nbsp;
          <span style={hereticRed}>sacrifice</span> them for&nbsp;
          <span style={hereticBlue}>knowledge points</span>. The Mansus{' '}
          <b>ONLY</b> accepts targets pointed to by the&nbsp;
          <span style={hereticRed}>Living Heart</span>.
        </Stack.Item>
        <Stack.Item>
          - Make yourself a <span style={hereticYellow}>focus</span> to be able
          to cast various advanced spells to assist you in acquiring harder and
          harder sacrifices.
        </Stack.Item>
        <Stack.Item>
          - Accomplish all of your objectives to be able to learn the{' '}
          <span style={hereticYellow}>final ritual</span>. Complete the ritual
          to become all powerful!
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

const InformationSection = () => {
  const { data } = useBackend<Info>();
  const { charges, total_sacrifices, ascended } = data;
  return (
    <Stack.Item>
      <Stack vertical fill>
        {!!ascended && (
          <Stack.Item>
            <Stack align="center">
              <Stack.Item>You have</Stack.Item>
              <Stack.Item fontSize="24px">
                <Box inline color="yellow">
                  ASCENDED
                </Box>
                !
              </Stack.Item>
            </Stack>
          </Stack.Item>
        )}
        <Stack.Item>
          You have <b>{charges || 0}</b>&nbsp;
          <span style={hereticBlue}>
            knowledge point{charges !== 1 ? 's' : ''}
          </span>
          .
        </Stack.Item>
        <Stack.Item>
          You have made a total of&nbsp;
          <b>{total_sacrifices || 0}</b>&nbsp;
          <span style={hereticRed}>sacrifices</span>.
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

const KnowledgeTree = () => {
  const { data } = useBackend<Info>();
  const { knowledge_tiers } = data;

  const nodesToShow = knowledge_tiers.filter((tier) => tier.nodes.length > 0);

  return (
    <Section title="Research Tree" fill scrollable>
      <Box textAlign="center" fontSize="32px">
        <span style={hereticYellow}>DAWN</span>
      </Box>
      <Stack vertical>
        {nodesToShow.length === 0
          ? 'None!'
          : nodesToShow.map((tier, i) => (
              <Stack.Item key={i}>
                <Stack
                  justify="center"
                  align="center"
                  backgroundColor="transparent"
                  wrap="wrap"
                >
                  {tier.nodes.map((node) => (
                    <KnowledgeNode
                      key={node.path}
                      node={node}
                      // hack, free nodes are draft nodes
                      purchaseCategory={node.category}
                    />
                  ))}
                </Stack>
                <hr />
              </Stack.Item>
            ))}
      </Stack>
    </Section>
  );
};

type KnowledgeNodeProps = {
  node: Knowledge;
  purchaseCategory?: ShopCategory;
  can_buy?: BooleanLike;
};

const KnowledgeNode = (props: KnowledgeNodeProps) => {
  const { node, can_buy = true, purchaseCategory } = props;
  const { data, act } = useBackend<Info>();
  const { charges } = data;

  const isBuyable = can_buy && !node.done && !node.disabled;

  const iconState = () => {
    if (!can_buy) {
      return node.bgr;
    }
    if (node.done) {
      return 'node_finished';
    }
    if (charges < node.cost || node.disabled) {
      return 'node_locked';
    }
    return node.bgr;
  };

  return (
    <Stack.Item key={node.name}>
      <Button
        color="transparent"
        tooltip={`${node.name}:
          ${node.desc}`}
        onClick={
          !isBuyable
            ? () => logger.warn(`Cannot buy ${node.name}`)
            : () =>
                act('research', { path: node.path, category: purchaseCategory })
        }
        width={node.ascension ? '192px' : '64px'}
        height={node.ascension ? '192px' : '64px'}
        m="8px"
        style={{
          borderRadius: '50%',
        }}
      >
        <DmIcon
          icon="icons/ui_icons/antags/heretic/knowledge.dmi"
          icon_state={iconState()}
          height={node.ascension ? '192px' : '64px'}
          width={node.ascension ? '192px' : '64px'}
          top="0px"
          left="0px"
          position="absolute"
        />
        <DmIcon
          icon={node.icon_params?.icon}
          icon_state={node.icon_params?.state}
          frame={node.icon_params?.frame}
          direction={node.icon_params?.dir}
          movement={node.icon_params?.moving}
          height={node.ascension ? '152px' : '64px'}
          width={node.ascension ? '152px' : '64px'}
          top={node.ascension ? '20px' : '0px'}
          left={node.ascension ? '20px' : '0px'}
          position="absolute"
        />
        <Box
          position="absolute"
          top="0px"
          left="0px"
          backgroundColor="black"
          textColor="white"
          bold
          style={{ margin: '2px', borderRadius: '100%' }}
        >
          {isBuyable && (node.cost > 0 ? node.cost : 'FREE')}
        </Box>
      </Button>
      {!!node.ascension && (
        <Box textAlign="center" fontSize="32px">
          <span style={hereticPurple}>DUSK</span>
        </Box>
      )}
    </Stack.Item>
  );
};

const KnowledgeShop = () => {
  const { data } = useBackend<Info>();
  const { knowledge_shop } = data;

  if (!knowledge_shop || knowledge_shop.length === 0) {
    return null;
  }

  return (
    <Section title="Knowledge Shop" fill scrollable>
      <Stack vertical fill>
        <Knowledges />
      </Stack>
    </Section>
  );

  function Knowledges() {
    // filter the list into being indexed by tier
    const tiers: Knowledge[][] = knowledge_shop.reduce((acc, knowledge) => {
      const tierIndex = knowledge.depth - 1; // depth starts at 1, so
      if (!acc[tierIndex]) {
        acc[tierIndex] = [];
      }
      acc[tierIndex].push(knowledge);
      return acc;
    }, [] as Knowledge[][]);

    return tiers?.map((tier, index) => (
      <Stack.Item key={`tier-${index}`}>
        Tier {index + 1}
        <Stack fill scrollable wrap="wrap">
          {tier.map((knowledge) => (
            <Stack.Item key={`knowledge-${knowledge.path}`}>
              <KnowledgeNode
                node={knowledge}
                purchaseCategory={knowledge.category}
              />
            </Stack.Item>
          ))}
        </Stack>
        <hr />
      </Stack.Item>
    ));
  }
};

const ResearchInfo = () => {
  const { data } = useBackend<Info>();
  const { charges, knowledge_shop } = data;

  return (
    <>
      <Stack.Item mb={1.5} fontSize="20px" textAlign="center">
        You have <b>{charges || 0}</b>&nbsp;
        <span style={hereticBlue}>
          knowledge point{charges !== 1 ? 's' : ''}
        </span>{' '}
        to spend.
      </Stack.Item>
      <Stack fill>
        <Stack.Item grow>
          <KnowledgeTree />
        </Stack.Item>
        {knowledge_shop?.length && (
          <Stack.Item grow>
            <KnowledgeShop />
          </Stack.Item>
        )}
      </Stack>
    </>
  );
};

const PathInfo = ({ currentPath }: { currentPath?: HereticPath }) => {
  const { data } = useBackend<Info>();
  const { paths } = data;

  const pathBoughtIndex = paths.findIndex(
    (path) => currentPath && path.route === currentPath.route,
  );

  const [currentTab, setCurrentTab] = useState(
    pathBoughtIndex !== -1 ? pathBoughtIndex : 0,
  );

  return (
    <Stack fill>
      {!currentPath && (
        <Stack.Item>
          <Tabs fluid vertical>
            {paths.map((path, index) => (
              <Tabs.Tab
                key={index}
                icon="info"
                selected={currentTab === index}
                onClick={() => setCurrentTab(index)}
              >
                {path.route}
              </Tabs.Tab>
            ))}
          </Tabs>
        </Stack.Item>
      )}
      <Stack.Item grow>
        <PathContent path={paths[currentTab]} isPathSelected={!!currentPath} />
      </Stack.Item>
    </Stack>
  );
};

const PathContent = ({
  path,
  isPathSelected,
}: {
  path: HereticPath;
  isPathSelected: boolean;
}) => {
  const { data } = useBackend<Info>();
  const { passive_level } = data;
  const { name, description } = path.passive;
  return (
    <Section
      title={<h1 className="PathTitle">{path.route}</h1>}
      textAlign="center"
      fill
      scrollable
    >
      <Stack vertical>
        {!isPathSelected && (
          <Stack.Item verticalAlign="center" textAlign="center">
            <h1>Choose Path:</h1>{' '}
            <KnowledgeNode
              node={path.starting_knowledge}
              purchaseCategory={ShopCategory.Start}
            />
            <div>
              <h3>
                Complexity:{' '}
                <span style={{ color: path.complexity_color }}>
                  {path.complexity}
                </span>
              </h3>
            </div>
          </Stack.Item>
        )}

        <Stack.Item>
          <b>Description:</b>{' '}
          {path.description.map((line, index) => (
            <div key={index}>{line}</div>
          ))}
        </Stack.Item>
        {(!isPathSelected && (
          <Stack.Item style={{ justifyItems: 'center' }}>
            <b>Passive: {name}</b>
            <p className="Passive">{description[0]}</p>
          </Stack.Item>
        )) || (
          <Stack.Item>
            <b>
              Passive: {name}, level: {passive_level}
            </b>
            <Stack>
              {description.map((line, index) => (
                <Stack.Item
                  key={index}
                  className={`Passive ${passive_level >= index + 1 ? 'Passive--Active' : ''}`}
                >
                  Level {index + 1}
                  <br />
                  {line}
                </Stack.Item>
              ))}
            </Stack>
          </Stack.Item>
        )}
        <Stack.Item>
          {!isPathSelected && (
            <>
              <b>Guaranteed Abilities:</b>
              <Stack wrap="wrap" justify="center">
                {path.preview_abilities.map((ability) => (
                  <Stack.Item key={`guaranteed_${ability.name}`} m={1}>
                    <KnowledgeNode node={ability} can_buy={false} />
                  </Stack.Item>
                ))}
              </Stack>
            </>
          )}
        </Stack.Item>
        {!isPathSelected && (
          <>
            <Stack.Item>
              <b>Pros:</b>
              <div>
                {path.pros.map((pro, index) => (
                  <p key={index}>{pro}</p>
                ))}
              </div>
            </Stack.Item>
            <Stack.Item>
              <b>Cons:</b>
              <div>
                {path.cons.map((con, index) => (
                  <p key={index}>{con}</p>
                ))}
              </div>
            </Stack.Item>
          </>
        )}

        {isPathSelected && (
          <Stack.Item textAlign="left" mt={2} mb={1}>
            <b>Tips:</b>
            <ul>
              {path.tips.map((tip, index) => (
                <li key={index}>{tip}</li>
              ))}
            </ul>
          </Stack.Item>
        )}
      </Stack>
    </Section>
  );
};

export const AntagInfoHeretic = () => {
  const { data } = useBackend<Info>();
  const { ascended, knowledge_tiers, paths } = data;

  const [currentTab, setTab] = useState(1);
  // only tiers has done variables set
  const currentPath = paths.find((path) =>
    knowledge_tiers.some((tier) =>
      tier.nodes.some(
        (node) => node.done && node.path === path.starting_knowledge.path,
      ),
    ),
  );

  const tabs = [
    { label: 'Information', icon: 'info', content: <IntroductionSection /> },
    {
      label: 'Path Info',
      icon: 'info',
      content: <PathInfo currentPath={currentPath} />,
    },
    { label: 'Research', icon: 'book', content: <ResearchInfo /> },
  ];

  const currentTheme = () => {
    if (currentPath?.route) {
      return `Heretic theme-Heretic--${currentPath.route.replace(' ', '')}`;
    }
    return 'Heretic';
  };

  return (
    <Window
      width={750}
      height={635}
      theme={`${currentTheme()}${ascended ? ' heretic-theme-ascended' : ''}`}
    >
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Tabs fluid>
              {tabs.map((tab, index) => (
                <Tabs.Tab
                  key={index}
                  icon={tab.icon}
                  selected={currentTab === index}
                  onClick={() => setTab(index)}
                >
                  {tab.label}
                </Tabs.Tab>
              ))}
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>{tabs[currentTab].content}</Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
