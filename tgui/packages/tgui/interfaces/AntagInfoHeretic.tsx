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
  tooltip?: string;
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
  points_to_aura: number;
};

const IntroductionSection = (props) => {
  const { data } = useBackend<Info>();
  const { objectives, ascended, can_change_objective } = data;

  return (
    <Stack justify="space-evenly" height="100%" width="100%">
      <Stack.Item grow>
        <Section title="Вы Еретик!" fill fontSize="14px">
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
                      ? 'Для вознесения вам нужно выполнить следующие задачи'
                      : 'Используйте свои темные знания, чтобы выполнить персональные цели'
                  }
                  objectives={objectives}
                  objectiveFollowup={
                    <ReplaceObjectivesButton
                      can_change_objective={can_change_objective}
                      button_title={'Отвергнуть вознесение'}
                      button_colour={'red'}
                      button_tooltip={
                        'Отвернитесь от Мансуса, чтобы выполнить задание по своему выбору. Выбрав эту опцию, вы не сможете возвыситься!'
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
            Еще один день на бессмысленной работе. Вы чувствуете&nbsp;
            <span style={hereticBlue}>мерцание</span>
            &nbsp;вокруг себя, когда что-то&nbsp;
            <span style={hereticRed}>странное</span>
            &nbsp;в воздухе озаряет вас. Вы смотрите внутрь себя и находите то,
            что изменит вашу жизнь.
          </i>
        </Stack.Item>
        <Stack.Item>
          <b>
            <span style={hereticPurple}>Врата Мансуса</span>
            &nbsp;открылись для вашего разума.
          </b>
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

const GuideSection = () => {
  const { data } = useBackend<Info>();
  const { points_to_aura } = data;
  return (
    <Stack.Item>
      <Stack vertical fontSize="12px">
        <Stack.Item>
          - Ищите на станции рушащие реальность&nbsp;
          <span style={hereticPurple}>влияния</span>. Они не видны обычному
          глазу. Нажмите&nbsp;
          <b>правой кнопкой мыши</b> по ним чтобы получить&nbsp;
          <span style={hereticBlue}>очки знаний</span>. После добычи, они вскоре
          становятся видимыми для всех. Сноведения о Мансусе помогут найти их.
        </Stack.Item>
        <Stack.Item>
          - Используйте ваше&nbsp;
          <span style={hereticRed}>живое сердце</span>
          &nbsp;, чтобы найти&nbsp;
          <span style={hereticRed}>цели для жертвоприношения</span>, но будьте
          аккуратны: пульсируя, оно будет издавать звук сердцебиения на коротком
          расстоянии. Эта способность связана с вашим <b>сердцем</b> - если вы
          его потеряете, совершите ритуал, чтобы вернуть её.
        </Stack.Item>
        <Stack.Item>
          - Нарисуйте&nbsp;
          <span style={hereticGreen}>руну трансмутации</span>, используя
          инструмент для рисования (ручка или карандаш) на полу. Необходимо
          иметь&nbsp;
          <span style={hereticGreen}>хватку Мансуса</span>
          &nbsp;в вашей другой руке. Эта руна позволяет совершать ритуалы и
          жертвоприношения.
        </Stack.Item>
        <Stack.Item>
          - Следуйте за зовом <span style={hereticRed}>живого сердца</span>,
          чтобы найти свои цели. Принесите их на&nbsp;
          <span style={hereticGreen}>руну трансмутации</span> в критическом, или
          хуже, состоянии для&nbsp;
          <span style={hereticRed}>жертвоприношения</span>, которое даст&nbsp;
          <span style={hereticBlue}>очки знаний</span>. Мансус примет{' '}
          <b>ТОЛЬКО</b> цели, указанные вашим&nbsp;
          <span style={hereticRed}>живым сердцем</span>.
        </Stack.Item>
        <Stack.Item>
          - Сделайте себе <span style={hereticYellow}>фокусировку</span>, чтобы
          читать более продвинутые заклинания, которые помогут вам для более
          сложных жертвоприношений.
        </Stack.Item>
        <Stack.Item>
          - Выполните все свои задачи, чтобы узнать{' '}
          <span style={hereticYellow}>финальный ритуал</span>. Завершите его,
          чтобы стать всемогущим!
        </Stack.Item>
        <Stack.Item>
          <span style={hereticRed}>ВНИМАНИЕ!</span>
          <br /> При накоплении в общем <b>{points_to_aura}</b>&nbsp;
          <span style={hereticBlue}> очков знаний,</span>
          &nbsp; вас окружит&nbsp;
          <span style={hereticPurple}>энергия Мансуса</span>. Для получения ауры
          необходимо потратить очки знаний, простое получение не раскроет вас.
          <br />
          Эта аура пометит вас, как приверженца ереитческого пути, раскрыв вас
          для любого смотрящего. Подумайте о рисках, прежде чем накапливать
          слишком много знаний!
          <br />
          Держите в уме, что использование&nbsp;
          <span style={hereticPurple}> кодекса Цикатрикс</span> при поглощении
          &nbsp;<span style={hereticYellow}>разлома </span>
            сделает довольно очевидной, вашу приверженность еретическому пути
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
              <Stack.Item>Вы</Stack.Item>
              <Stack.Item fontSize="24px">
                <Box inline color="yellow">
                  ВОЗВЫСИЛИСЬ
                </Box>
                !
              </Stack.Item>
            </Stack>
          </Stack.Item>
        )}
        <Stack.Item>
          Доступно <span style={hereticBlue}>очков знаний</span>:{' '}
          <b>{charges || 0}</b>&nbsp;
        </Stack.Item>
        <Stack.Item>
          Жертвоприношений сделано: <b>{total_sacrifices || 0}</b>
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
    <Section title="Древо знаний" fill scrollable>
      <Box textAlign="center" fontSize="32px">
        <span style={hereticYellow}>РАССВЕТ</span>
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
        tooltip={
          node.tooltip ??
          `${node.name}:
          ${node.desc}`
        }
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
          {isBuyable && (node.cost > 0 ? node.cost : 'ДАР')}
        </Box>
      </Button>
      {!!node.ascension && (
        <Box textAlign="center" fontSize="32px">
          <span style={hereticPurple}>ЗАКАТ</span>
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
    <Section title="Магазин знаний" fill scrollable>
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
        Уровень {index + 1}
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
        Доступные <span style={hereticBlue}>очки знаний</span> :{' '}
        <b>{charges || 0}</b>&nbsp;.
      </Stack.Item>
      <Stack fill>
        <Stack.Item grow>
          <KnowledgeTree />
        </Stack.Item>
        {!!knowledge_shop?.length && (
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
            <h1>Выберите путь:</h1>{' '}
            <KnowledgeNode
              node={path.starting_knowledge}
              purchaseCategory={ShopCategory.Start}
            />
            <div>
              <h3>
                Сложность:{' '}
                <span style={{ color: path.complexity_color }}>
                  {path.complexity}
                </span>
              </h3>
            </div>
          </Stack.Item>
        )}

        <Stack.Item>
          <b>Описание:</b>{' '}
          {path.description.map((line, index) => (
            <div key={index}>{line}</div>
          ))}
        </Stack.Item>
        {(!isPathSelected && (
          <Stack.Item style={{ justifyItems: 'center' }}>
            <b>Пассивный навык: {name}</b>
            <p className="Passive">{description[0]}</p>
          </Stack.Item>
        )) || (
          <Stack.Item>
            <b>
               Способность: {name}, уровень: {passive_level}
            </b>
            <Stack>
              {description.map((line, index) => (
                <Stack.Item
                  key={index}
                  className={`Passive ${passive_level >= index + 1 ? 'Passive--Active' : ''}`}
                >
                  Уровень {index + 1}
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
              <b>Гарантированные способности:</b>
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
              <b>Cильные стороны:</b>
              <div>
                {path.pros.map((pro, index) => (
                  <p key={index}>{pro}</p>
                ))}
              </div>
            </Stack.Item>
            <Stack.Item>
              <b>Слабые стороны:</b>
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
            <b>Cоветы:</b>
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
    { label: 'Информация', icon: 'info', content: <IntroductionSection /> },
    {
      label: 'Информация пути',
      icon: 'info',
      content: <PathInfo currentPath={currentPath} />,
    },
    { label: 'Исследования', icon: 'book', content: <ResearchInfo /> },
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
