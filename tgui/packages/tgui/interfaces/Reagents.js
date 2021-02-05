import { useBackend, useLocalState } from '../backend';
import { Box, Button, LabeledList, Section, NoticeBox, Table, Icon, Chart, Flex, Stack } from '../components';
import { TableCell, TableRow } from '../components/Table';
import { Window } from '../layouts';
import { map } from 'common/collections';
import { logger } from '../logging.js';

export const Reagents = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    hasReagent,
    hasReaction,
    isImpure,
    reagent_mode_recipe,
    reagent_mode_reagent,
    selectedBitflags,
    currentReagents = [],
    master_reaction_list = [],
  } = data;
  const [brute, setBrute] = useLocalState(
    context, 'brute', false);
  const [burn, setBurn] = useLocalState(
    context, 'burn', false);
  const [toxin, setToxin] = useLocalState(
    context, 'toxin', false);
  const [oxy, setOxy] = useLocalState(
    context, 'oxy', false);
  const [clone, setClone] = useLocalState(
    context, 'clone', false);
  const [organ, setOrgan] = useLocalState(
    context, 'organ', false);
  const [healing, setHealing] = useLocalState(
    context, 'healing', false);
  const [drink, setDrink] = useLocalState(
    context, 'drink', false);
  const [food, setFood] = useLocalState(
    context, 'food', false);
  const [damaging, setDamaging] = useLocalState(
    context, 'damaging', false);
  const [slime, setSlime] = useLocalState(
    context, 'slime', false);
  const [explosive, setExplosive] = useLocalState(
    context, 'explosive', false);
  const [other, setOther] = useLocalState(
    context, 'other', false);
  const [easy, setEasy] = useLocalState(
    context, 'easy', false);
  const [moderate, setModerate] = useLocalState(
    context, 'moderate', false);
  const [hard, setHard] = useLocalState(
    context, 'hard', false);
  const [dangerous, setDangerous] = useLocalState(
    context, 'dangerous', false);
  const [reagentFilter, setReagentFilter] = useLocalState(
    context, 'reagentFilter', true);
  const BRUTE = 1 << 0;
  const BURN = 1 << 1;
  const TOXIN = 1 << 2;
  const OXY = 1 << 3;
  const CLONE = 1 << 4;
  const HEALING = 1 << 5;
  const DAMAGING = 1 << 6;
  const EXPLOSIVE = 1 << 7;
  const OTHER = 1 << 8;
  const DANGEROUS = 1 << 9;
  const EASY = 1 << 10;
  const MODERATE = 1 << 11;
  const HARD = 1 << 12;
  const ORGAN = 1 << 13;
  const DRINK = 1 << 14;
  const FOOD = 1 << 15;
  const SLIME = 1 << 16;
  const flagsObject = {
    "gavel": BRUTE,
    "burn": BURN,
    "biohazard": TOXIN,
    "wind": OXY,
    "male": CLONE,
    "medkit": HEALING,
    "skull-crossbones": DAMAGING,
    "bomb": EXPLOSIVE,
    "question": OTHER,
    "exclamation-triangle": DANGEROUS,
    "chess-pawn": EASY,
    "chess-knight": MODERATE,
    "chess-queen": HARD,
    "brain": ORGAN,
    "cocktail": DRINK,
    "drumstick-bite": FOOD,
    "microscope": SLIME,
  };
  
  /* es-lint please no */
  function matchBitflag(flag1, flag2) {
    if (flag1 === 0) {
      return true;
    }
    let merge = flag1 | flag2;
    if (flag1 & flag2)
    { if ((merge ^ flag2)) 
    {
      return false; 
    }
    return true;
    }
    return false;
  }
  
  function matchReagents(reaction) {
    if (!reagentFilter) {
      return true;
    }
    if (currentReagents === null) {
      return true;
    }
    let matches = 0;
    for (var index = 0; index < currentReagents.length; ++index) {
      reaction.reactants.map(reactant => {
        if (reactant.id === currentReagents[index]) {
          ++matches;
        } });
    }
    if (matches === currentReagents.length) {
      return true;
    }
    return false;
  }

  return (
    <Window
      width={700}
      height={800}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item >
            <Stack fill>
              <Stack.Item grow basis={0}>
                <Section 
                  title="Recipe lookup"
                  minWidth="340px"
                  maxWidth="340px" 
                  buttons={(
                    <Button
                      content="Search recipes"
                      icon="search"
                      onClick={() => act('search_recipe')} />
                  )}>
                  {!!hasReaction && (
                    <Table>
                      <TableRow>
                        <TableCell bold color="label">
                          Recipie:
                        </TableCell>
                        <TableCell>
                          <Icon name="circle" mr={1} color={reagent_mode_recipe.reagentCol} />
                          {reagent_mode_recipe.name}
                        </TableCell>
                      </TableRow>
                      <TableRow>
                        <TableCell bold color="label">
                          Products:
                        </TableCell>
                        <TableCell>
                          {reagent_mode_recipe.products.map(product => (
                            <Button
                              key={product.name}
                              icon="vial"
                              disabled={product.hasProduct ? true : false}
                              content={product.ratio + "u " + product.name}
                              onClick={() => act('reagent_click', {
                                id: product.id,
                              })} />
                          ))}
                        </TableCell>
                      </TableRow>
                      <TableRow>
                        <TableCell bold color="label">
                          Reactants:
                        </TableCell>
                        <TableCell>
                          {reagent_mode_recipe.reactants.map(reactant => (
                            <Box key={reactant.id}>
                              {reactant.tooltipBool && (                    
                                <Button
                                  key={reactant.name}
                                  icon="vial"
                                  color={reactant.color}
                                  content={reactant.ratio + "u " + reactant.name}
                                  tooltip={reactant.tooltip}
                                  tooltipPosition={"right"}
                                  onClick={() => act('reagent_click', {
                                    id: reactant.id,
                                  })} />
                              ) || (
                                <Button
                                  key={reactant.name}
                                  icon="vial"
                                  color={reactant.color}
                                  content={reactant.ratio + "u " + reactant.name}
                                  onClick={() => act('reagent_click', {
                                    id: reactant.id,
                                  })} />
                              )}
                            </Box>
                          ))}
                        </TableCell>
                      </TableRow>
                      {reagent_mode_reagent.catalysts && (
                        <TableRow>
                        <TableCell bold color="label">
                          Catalysts:
                        </TableCell>
                        <TableCell>
                          {reagent_mode_recipe.catalysts.map(catalyst => (
                            <Box key={catalyst.id}>
                              {catalyst.tooltipBool && (                    
                                <Button
                                  key={catalyst.name}
                                  icon="vial"
                                  color={catalyst.color}
                                  content={catalyst.ratio + "u " + catalyst.name}
                                  tooltip={catalyst.tooltip}
                                  tooltipPosition={"right"}
                                  onClick={() => act('reagent_click', {
                                    id: catalyst.id,
                                  })} />
                              ) || (
                                <Button
                                  key={catalyst.name}
                                  icon="vial"
                                  color={catalyst.color}
                                  content={catalyst.ratio + "u " + catalyst.name}
                                  onClick={() => act('reagent_click', {
                                    id: catalyst.id,
                                  })} />
                              )}
                            </Box>
                          ))}
                        </TableCell>
                      </TableRow>
                      )}
                      {reqContainer && (
                        <TableRow>
                          <TableCell bold color ="label">
                            Required Container:
                          </TableCell>
                          <TableCell>
                            {reqContainer}
                          </TableCell>
                        </TableRow>
                      )}
                      <TableRow>
                        <TableCell bold color="label">
                          Purity:
                        </TableCell>
                        <TableCell>
                          <LabeledList>
                            <LabeledList.Item label="Optimal pH range">
                              {reagent_mode_recipe.lowerpH + "-" + reagent_mode_recipe.upperpH}
                            </LabeledList.Item>
                            <LabeledList.Item label="Inverse purity">
                              {reagent_mode_recipe.inversePurity}
                            </LabeledList.Item>
                            <LabeledList.Item label="Minimum purity">
                              {reagent_mode_recipe.minPurity}
                            </LabeledList.Item>
                          </LabeledList>
                        </TableCell>
                      </TableRow>
                      <TableRow>
                        <TableCell bold color="label">
                          <Box position="relative" width="20px">
                            Thermo
                            dynamics:
                          </Box>
                        </TableCell>
                        <TableCell>
                          <Box height="50px" position="relative">
                            <Chart.Line
                              fillPositionedParent
                              data={reagent_mode_recipe.thermodynamics}
                              strokeColor={"#6cf303"}
                              strokeWidth={3}
                              fillColor={"#6ffb9b"} />
                            <Chart.Line
                              position="absolute"
                              top={0}
                              bottom={0}
                              right={0}
                              width="10px"
                              data={reagent_mode_recipe.explosive}
                              strokeColor={"#ff9b9b"}
                              strokeWidth={3}
                              fillColor={"#ff9b9b"} />
                          </Box>
                          <TableRow>
                            <Box width="190px" position="relative" top="5px" left="-12px">
                              {reagent_mode_recipe.tempMin+"K"}
                            </Box>
                            <Box width="190px" position="relative" top="-10px" left="205px">
                              {reagent_mode_recipe.explodeTemp+"K"}
                            </Box>
                          </TableRow>
                          <TableRow>
                            <LabeledList.Item label="Optimal rate">
                              {reagent_mode_recipe.thermoUpper+"u/s"}
                            </LabeledList.Item>
                            <Flex ml={1}>
                              {reagent_mode_recipe.thermics}
                            </Flex>
                          </TableRow>
                        </TableCell>
                      </TableRow>
                    </Table>
                  ) || (
                    <Box>
                      No reaction selected!
                    </Box>
                  )}
                </Section>
              </Stack.Item>
              <Stack.Item grow basis={0}>
                <Section title="Reagent lookup"
                  minWidth="300px"
                  buttons={(
                    <Button
                      content="Search reagents"
                      icon="search"
                      onClick={() => act('search_reagents')} />
                  )}>
                  {!!hasReagent && (
                    <Table>
                      <TableRow>
                        <TableCell bold color="label">
                          Reagent:
                        </TableCell>
                        <TableCell>
                          <Icon name="circle" mr={1} color={reagent_mode_reagent.reagentCol} />
                          {reagent_mode_reagent.name}
                        </TableCell>
                      </TableRow>
                      <TableRow>
                        <TableCell bold color="label">
                          Description:
                        </TableCell>
                        <TableCell>
                          {reagent_mode_reagent.desc}
                        </TableCell>
                      </TableRow>
                      <TableRow>
                        <TableCell bold color="label">
                          pH:
                        </TableCell>
                        <TableCell>
                          <Icon name="circle" mr={1} color={reagent_mode_reagent.pHCol} />
                          {reagent_mode_reagent.pH}
                        </TableCell>
                      </TableRow>
                      <TableRow>
                        <TableCell bold color="label">
                          Properties:
                        </TableCell>
                        <TableCell>
                          <LabeledList>
                            <LabeledList.Item label="Overdose">
                              {reagent_mode_reagent.OD}u
                            </LabeledList.Item>
                            <LabeledList.Item label="Addiction">
                              {reagent_mode_reagent.Addiction}u
                            </LabeledList.Item>
                            <LabeledList.Item label="Metabolization rate">
                              {reagent_mode_reagent.metaRate}u/s
                            </LabeledList.Item>
                          </LabeledList>
                        </TableCell>
                      </TableRow>
                      <TableRow mt={2}>
                        <TableCell bold color="label">
                          Impurities:
                        </TableCell>
                        <TableCell>
                          {!isImpure && (
                            <LabeledList>
                              <LabeledList.Item label="Impure reagent">
                                <Button
                                  key={reagent_mode_reagent.impureReagent}
                                  icon="vial"
                                  content={reagent_mode_reagent.impureReagent}
                                  onClick={() => act('reagent_click', {
                                    id: reagent_mode_reagent.impureId,
                                  })} />
                              </LabeledList.Item>
                              <LabeledList.Item label="Inverse reagent">
                                <Button
                                  key={reagent_mode_reagent.inverseReagent}
                                  icon="vial"
                                  content={reagent_mode_reagent.inverseReagent}
                                  onClick={() => act('reagent_click', {
                                    id: reagent_mode_reagent.inverseId,
                                  })} />
                              </LabeledList.Item>
                              <LabeledList.Item label="Failed reagent">
                                <Button
                                  key={reagent_mode_reagent.failedReagent}
                                  icon="vial"
                                  content={reagent_mode_reagent.failedReagent}
                                  onClick={() => act('reagent_click', {
                                    id: reagent_mode_reagent.failedId,
                                  })} />
                              </LabeledList.Item>
                            </LabeledList>
                          ) || (
                            <Box>
                              This reagent is an impure reagent.
                            </Box>
                          )}
                        </TableCell>
                      </TableRow>
                      <TableRow>
                        <TableCell />
                        <TableCell>
                          <Button
                            key={reagent_mode_reagent.id}
                            icon="flask"
                            mt={2}
                            content={"Find associated reaction"}
                            color="purple"
                            onClick={() => act('find_reagent_reaction', {
                              id: reagent_mode_reagent.id,
                            })} />
                        </TableCell>
                      </TableRow>
                    </Table>
                  ) || (
                    <Box>
                      No reagent selected!
                    </Box>
                  )}
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item>       
            <Section title="Tags">
              <LabeledList>
                <LabeledList.Item label="Affects">
                  <Button
                    color={brute ? "green" : "red"}
                    icon="gavel"
                    onClick={() => { act('toggle_tag_brute'); setBrute(!brute); }}>
                    Brute
                  </Button>
                  <Button
                    color={burn ? "green" : "red"}
                    icon="burn"
                    onClick={() => { act('toggle_tag_burn'); setBurn(!burn); }}>
                    Burn
                  </Button>
                  <Button
                    color={toxin ? "green" : "red"}
                    icon="biohazard"
                    onClick={() => { act('toggle_tag_toxin'); setToxin(!toxin); }}>
                    Toxin
                  </Button>
                  <Button
                    color={oxy ? "green" : "red"}
                    icon="wind"
                    onClick={() => { act('toggle_tag_oxy'); setOxy(!oxy); }}>
                    Suffocation
                  </Button>
                  <Button
                    color={clone ? "green" : "red"}
                    icon="male"
                    onClick={() => { act('toggle_tag_clone'); setClone(!clone); }}>
                    Clone
                  </Button>
                  <Button
                    color={organ ? "green" : "red"}
                    icon="brain"
                    onClick={() => { act('toggle_tag_organ'); setOrgan(!organ); }}>
                    Organ
                  </Button>
                </LabeledList.Item>
                <LabeledList.Item label="Type">
                  <Button
                    color={drink ? "green" : "red"}
                    icon="cocktail"
                    onClick={() => { act('toggle_tag_drink'); setDrink(!drink); }}>
                    Drink
                  </Button>
                  <Button
                    color={food ? "green" : "red"}
                    icon="drumstick-bite"
                    onClick={() => { act('toggle_tag_drink'); setFood(!food); }}>
                    Food
                  </Button>
                  <Button
                    color={healing ? "green" : "red"}
                    icon="medkit"
                    onClick={() => { act('toggle_tag_healing'); setHealing(!healing); }}>
                    Healing
                  </Button>
                  <Button
                    icon="skull-crossbones"
                    color={damaging ? "green" : "red"}
                    onClick={() => { act('toggle_tag_damaging'); setDamaging(!damaging); }}>
                    Damaging
                  </Button>
                  <Button
                    icon="microscope"
                    color={slime ? "green" : "red"}
                    onClick={() => { act('toggle_tag_slime'); setSlime(!slime); }}>
                    Slime
                  </Button>
                  <Button
                    icon="bomb"
                    color={explosive ? "green" : "red"}
                    onClick={() => { act('toggle_tag_explosive'); setExplosive(!explosive); }}>
                    Explosive
                  </Button>
                  <Button
                    icon="question"
                    color={other ? "green" : "red"}
                    onClick={() => { act('toggle_tag_other'); setOther(!other); }}>
                    Other
                  </Button>
                </LabeledList.Item>
                <LabeledList.Item label="Difficulty">
                  <Button
                    icon="chess-pawn"
                    color={easy ? "green" : "red"}
                    onClick={() => { act('toggle_tag_easy'); setEasy(!easy); }}>
                    Easy
                  </Button>
                  <Button
                    icon="chess-knight"
                    color={moderate ? "green" : "red"}
                    onClick={() => { act('toggle_tag_moderate'); setModerate(!moderate); }}>
                    Moderate
                  </Button>
                  <Button
                    icon="chess-queen"
                    color={hard ? "green" : "red"}
                    onClick={() => { act('toggle_tag_hard'); setHard(!hard); }}>
                    Hard
                  </Button>
                  <Button
                    icon="exclamation-triangle"
                    color={dangerous ? "green" : "red"}
                    onClick={() => { act('toggle_tag_dangerous'); setDangerous(!dangerous); }}>
                    Dangerous
                  </Button>
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
          <Stack.Item grow={2} basis={0}>
            <Section scrollable fill title="Possible recipies"
              buttons={(
                <Button
                  content="Filter by reagents in beaker"
                  icon="search"
                  color={reagentFilter ? "green" : "default"}
                  onClick={() => setReagentFilter(!reagentFilter)} />
              )}>
              <Table>
                <TableRow>
                  <TableCell bold color="label">
                    Reaction
                  </TableCell>
                  <TableCell bold color="label">
                    Required reagents
                  </TableCell>
                  <TableCell bold color="label">
                    Tags
                  </TableCell>
                </TableRow>
                {master_reaction_list.map(reaction => (
                  matchBitflag(selectedBitflags, reaction.bitflags) && (
                    <TableRow key={reaction.name}>
                      {matchReagents(reaction, currentReagents) && (
                        <>
                          <TableCell bold color="label">
                            <Button
                              mt={1.2}
                              key={reaction.name}
                              icon="flask"
                              color="purple"
                              content={reaction.name}
                              onClick={() => act('recipe_click', {
                                id: reaction.id,
                              })} />  
                          </TableCell>
                          <TableCell>
                            {reaction.reactants.map(reactant => (
                              <Button
                                mt={0.1}
                                key={reactant.name}
                                icon="vial"
                                color={reactant.color}
                                content={reactant.name}
                                onClick={() => act('reagent_click', {
                                  id: reactant.id,
                                })} />                    
                            ))}
                          </TableCell>
                          <TableCell width="40px">
                            {map((flag, icon) => 
                              (reaction.bitflags & Number(flag)) && (
                                <Icon name={icon} mr={1} color={"white"} />
                              ) || (
                                null
                              ))(flagsObject)}
                          </TableCell>                         
                        </>
                      )}  
                    </TableRow>           
                  )))}
              </Table>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
