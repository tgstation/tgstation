import { range } from 'common/collections';
import { BooleanLike } from 'common/react';
import { multiline } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Box, BlockQuote, Button, Icon, Section, Stack } from '../components';
import { Window } from '../layouts';

const INFORMATION_PAGE = 0;

const ADAPTION_PAGE = 1;

const ABILITIES_PER_PAGE = 5;

const tipstyle = {
  color: 'lightblue',
};

const SYMPTOMTYPE2DESC = {
  "Active": "An activated symptom that comes with cooldowns, useful early on to pick your targets.",
  "Minor": "A weak symptom that is cheap to aquire early.",
  "Intermediate": "An average symptom with decent power for unlock requirements.",
  "Supportive": "A symptom that will support the host instead of harming them.",
  "Major": "A powerful symptom that will grant large stats or very dangerous effects, at the price of a high unlock requirement.",
  "Major Supportive": "A powerful symptom that will grant large advantages for the host instead of harming them, at the price of a high unlock requirement.",
};

// Major Heal

type Ability = {
  purchased: BooleanLike;
  cost: number;
  total_requirement: number;
  name: string;
  category: string;
  desc: string;
  resist: number;
  stealth: number;
  speed: number;
  transmit: number;
}

type Objective = {
  count: number;
  name: string;
  explanation: string;
  complete: BooleanLike;
  was_uncompleted: BooleanLike;
  reward: number;
}

type Info = {
  objectives: Objective[];
  abilities: Ability[];
  cure: string;
  points: number;
  total_points: number;
  resist: number;
  stealth: number;
  speed: number;
  transmit: number;
};

export const AntagInfoDisease = (props, context) => {
  const [pageIndex, setPageIndex] = useLocalState(context, 'pageIndex', INFORMATION_PAGE);
  return (
    <Window
      width={620}
      height={550}>
      <Window.Content
        style={{
          'background-image': 'none',
        }}
        backgroundColor="#2b542f">
        <Stack vertical fill>
          <Stack.Item>
            <PageSelection />
          </Stack.Item>
          {pageIndex === INFORMATION_PAGE && (
            <>
              <Stack.Item grow>
                <Section fill scrollable>
                  <ObjectivePrintout />
                </Section>
              </Stack.Item>
              <Stack.Item>
                <Section fill>
                  <Stack vertical>
                    <span style={tipstyle}>
                      Starting out:&ensp;
                    </span>
                    Time is valuable. As soon as someone who is infected
                    visits medbay, you&apos;re going to have the station working
                    towards wiping you out completely. Better to infect fast
                    and quickly adapt into something deadly or friendly than
                    to be caught as a sneezing virus, something that can be
                    quickly cured out of existence. Also, mind who you start
                    with. Space explorers won&apos;t help. Hardsuits and some
                    other outfits will prevent initial spread.
                    <Stack.Divider mb={0.75} />
                    <span style={tipstyle}>
                      Going Deadly:&ensp;
                    </span>
                    Disable medbay. While you don&apos;t have a lot of control
                    over who you&apos;re attacking, medbay is the only
                    department that is able to work towards producing cures.
                    Even chemists getting infected before full awareness gets
                    out grants you a ton of time.
                    <Stack.Divider mb={0.75} />
                    <span style={tipstyle}>
                      Going Friendly:&ensp;
                    </span>
                    Honestly a pretty luck based strategy, but all I have to say
                    is that first impressions do best. Try starting out and
                    spreading selectively until you have your positive symptoms.
                    Also, while we all love regenerative coma, you will be cured
                    if you coma the wrong person so don&apos;t do it.
                  </Stack>
                </Section>
              </Stack.Item>
            </>
          ) || (
            <Stack.Item grow>
              <Stack fill>
                <Stack.Item basis={0} grow>
                  <VirusStats />
                </Stack.Item>
                <Stack.Item basis={0} grow={2}>
                  <PurchaseMenu />
                </Stack.Item>
              </Stack>
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};

const ObjectivePrintout = (props, context) => {
  const { data } = useBackend<Info>(context);
  const {
    objectives,
  } = data;
  return (
    <Stack vertical>
      <Stack.Item bold>
        To ensure survival as a star-faring disease:
      </Stack.Item>
      <Stack.Item>
        {!objectives && "None!"
        || objectives.map(objective => (
          <Stack.Item key={objective.count}>
            #{objective.count}: {objective.explanation}
          </Stack.Item>
        )) }
      </Stack.Item>
    </Stack>
  );
};

const PageSelection = (props, context) => {
  const [pageIndex, setPageIndex] = useLocalState(context, 'pageIndex', 0);
  return (
    <Section textColor="red" fontSize="18px">
      <Stack fill align="baseline">
        <Stack.Item fontSize="19px" grow>
          You are the Sentient Disease.
        </Stack.Item>
        <Stack.Item>
          <Button
            disabled={pageIndex === 0}
            icon="info"
            onClick={() => setPageIndex(INFORMATION_PAGE)}>
            Information
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button
            disabled={pageIndex === 1}
            icon="dna"
            onClick={() => setPageIndex(ADAPTION_PAGE)} >
            Adaption
          </Button>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const VirusStats = (props, context) => {
  const { data } = useBackend<Info>(context);
  const [examinedAbility, setExaminedAbility] = useLocalState<Ability | null>(context, 'examinedAbility', null);
  const {
    cure,
    resist,
    stealth,
    speed,
    transmit,
  } = data;
  return (
    <Section fill>
      <Stack mb={-45} vertical fill>
        <Stack.Item bold fontSize="16px">
          Overall Virus Stats:
        </Stack.Item>
        <DiseaseStatDisplay
          resist={resist}
          stealth={stealth}
          speed={speed}
          transmit={transmit} />
        <Stack.Item>
          <Button
            icon="syringe"
            color="transparent"
            tooltip="This is your bane! You'll be cured in anybody who has this reagent." /> Cure: {cure}
        </Stack.Item>
        <Stack.Divider />
      </Stack>
      {examinedAbility && (
        <Box fontSize="16px" mb={0.5} bold>
          {examinedAbility.name}:
        </Box>
      )}
      <Stack vertical fill>
        <ExaminePanel />
        <Stack.Divider />
        <Stack.Item basis={0} mb={44}>
          <BlockQuote>
            Tip: Symptoms require both points, and max points.
            Max points are gained by infecting lots of people.
          </BlockQuote>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const PurchaseMenu = (props, context) => {
  const { data } = useBackend<Info>(context);
  const [abilityPage, setAbilityPage] = useLocalState(context, 'abilityPage', 0);
  const {
    abilities,
    points,
    total_points,
  } = data;
  return (
    <>
      <Section>
        <Stack bold fill>
          <Stack.Item fontSize="20px" grow>
            Points: {points}/{total_points}
          </Stack.Item>
          <Stack.Item mt={0.5}>
            <Button
              icon="arrow-left"
              disabled={abilityPage === 0}
              onClick={() => setAbilityPage(abilityPage-1)} />
            <Button
              icon="arrow-right"
              disabled={
                !abilities[((abilityPage + 1) * ABILITIES_PER_PAGE) + 1]
              }
              onClick={() => setAbilityPage(abilityPage+1)} />
          </Stack.Item>
        </Stack>
      </Section>
      <Stack vertical>
        {range(0, ABILITIES_PER_PAGE).map(number => (
          <PurchasableAbility
            key={number}
            abilityIndex={
              abilityPage * ABILITIES_PER_PAGE + number
            } />
        ))}
      </Stack>
    </>
  );
};

const PurchasableAbility = (props, context) => {
  const { data } = useBackend<Info>(context);
  const [examinedAbility, setExaminedAbility] = useLocalState<Ability | null>(context, 'examinedAbility', null);
  const {
    abilities,
  } = data;
  const {
    abilityIndex,
  } = props;
  const selectedAbility = abilities[abilityIndex];
  if (!selectedAbility) {
    return null;
  }
  return (
    <Section
      height="75.2px"
      className={selectedAbility.purchased ? "AntagInfoDisease__purchased" : ""}>
      <Stack fill vertical>
        <Stack.Item grow>
          <Stack align="baseline" fill>
            <Stack.Item bold>
              {selectedAbility.name}
            </Stack.Item>
            <Stack.Item grow />
            <Stack.Item>
              Cost: {selectedAbility.cost}
            </Stack.Item>
            <Stack.Item>
              Unlock: {selectedAbility.total_requirement}
            </Stack.Item>
            <Stack.Item>
              <Button
                disabled={examinedAbility === selectedAbility}
                onClick={() => setExaminedAbility(selectedAbility)}>
                {examinedAbility !== selectedAbility ? "Examine" : "Selected"}
              </Button>
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <BlockQuote>
            {selectedAbility.desc}
          </BlockQuote>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const ExaminePanel = (props, context) => {
  const { data } = useBackend<Info>(context);
  const [examinedAbility, setExaminedAbility] = useLocalState<Ability | null>(context, 'examinedAbility', null);
  const {
    points,
    total_points,
  } = data;
  return (
    <>
      {!examinedAbility ? (
        <>
          <Stack.Item grow />
          <Stack.Item textAlign="center">
            <Icon size={3} name="search" />
          </Stack.Item>
          <Stack.Item fontSize="14px" textAlign="center">
            Examining a possible symptom will show
            important details and stats before purchase.
          </Stack.Item>
        </>
      ) : (
        <>
          <DiseaseStatDisplay
            resist={examinedAbility.resist}
            stealth={examinedAbility.stealth}
            speed={examinedAbility.speed}
            transmit={examinedAbility.transmit} />
          <Stack.Item>
            <Button
              color="transparent"
              icon="info"
              tooltip={SYMPTOMTYPE2DESC[examinedAbility.category]}
              tooltipPosition="top-end" /> Category: {examinedAbility.category}
          </Stack.Item>
          <Stack.Item>
            <BlockQuote />
          </Stack.Item>
          <Stack.Item>
            <Stack fill>
              <Stack.Item grow>
                {!examinedAbility.purchased && (
                  <Button
                    disabled={
                      points < examinedAbility.cost
                      || total_points < examinedAbility.total_requirement
                    }
                    icon="biohazard"
                    color="green">
                    Unlock
                  </Button>
                ) || (
                  <Button icon="recycle" color="green">
                    Refund
                  </Button>
                )}
              </Stack.Item>
              <Stack.Item>
                <Button
                  icon="undo"
                  onClick={() => setExaminedAbility(null)}>
                  Cancel
                </Button>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </>
      )}
      <Stack.Item grow />
    </>
  );
};



const DiseaseStatDisplay = (props, context) => {
  const {
    resist,
    stealth,
    speed,
    transmit,
  } = props;
  return (
    <>
      <Stack.Item>
        <Button
          color="transparent"
          icon="shield-alt"
          tooltip={multiline`
            Resistance changes what spacemen need to cure you.
            Higher resistance means harder to produce and
            distribute chemicals which means spacemen will
            take longer to be rid of you.
          `} /> Resistance: {resist}
      </Stack.Item>
      <Stack.Item>
        <Button
          color="transparent"
          icon="low-vision"
          tooltip={multiline`
            Stealth changes how easy it is to detect you.
            Higher stealth stat means dodging medical scanners,
            and other machines that are designed to find you and
            your cure reagent out.
          `} /> Stealth: {stealth}
      </Stack.Item>
      <Stack.Item>
        <Button
          color="transparent"
          icon="angle-double-right"
          tooltip={multiline`
            Stage Speed is how fast your virus advances in a victim.
            You may load up your virus with all kinds of nasty symptoms,
            but without stage speed your victim may not feel it before
            getting cured. Sad!
          `} /> Stage Speed: {speed}
      </Stack.Item>
      <Stack.Item>
        <Button
          color="transparent"
          icon="wifi"
          tooltip={multiline`
            Transmissibility is your disease's ability to spread.
            At higher levels, your disease becomes airborne and
            sticks around in blood. Without it, you may chew through
            all your victims and accidently make yourself extinct.
          `} /> Transmissibility: {transmit}
      </Stack.Item>
    </>
  );
};
