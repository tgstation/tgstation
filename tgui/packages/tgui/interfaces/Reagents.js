import { useBackend, useLocalState } from '../backend';
import { Box, Button, LabeledList, Section, NoticeBox, Table, Icon, Chart } from '../components';
import { TableCell, TableRow } from '../components/Table';
import { Window } from '../layouts';

export const Wires = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    hasReagent,
    hasReaction,
    isImpure,
    reagent_mode_recipe,
    reagent_mode_reagent,
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
  const [damaging, setDamaging] = useLocalState(
    context, 'damaging', false);
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
  return (
    <Window
      width={450}
      height={800}>
      <Window.Content>
        <Table>
          <TableCell>
            <TableRow>
              <Section 
                title="Recipe lookup"
                buttons={(
                  <Button
                    content="Search recipes"
                    icon="search"
                    onClick={() => act('search_recipe')} />
                )}>
                {!!hasReaction && (
                  <Table>
                    <TableCell>
                      <TableRow bold color="label">
                        Recipie:
                      </TableRow>
                      <TableRow>
                        {reagent_mode_recipe.name}
                      </TableRow>
                    </TableCell>
                    <TableCell>
                      <TableRow bold color="label">
                        Products:
                      </TableRow>
                      <TableRow>
                        {reagent_mode_recipe.products.map(product => (
                          <Button
                            key={product.name}
                            icon="vial"
                            content={product.name + " " + product.ratio + "u"}
                            onClick={() => act('reagent_click', {
                              id: product.id,
                            })} />
                        ))}
                      </TableRow>
                    </TableCell>
                    <TableCell>
                      <TableRow bold color="label">
                        Reactants:
                      </TableRow>
                      <TableRow>
                        {reagent_mode_recipe.reactants.map(reactant => (
                          <Box key={reactant.id}>
                            {reactant.tooltipBool && (                    
                              <Button
                                key={reactant.name}
                                icon="vial"
                                color={reactant.color}
                                content={reactant.name + " " + reactant.ratio + "u"}
                                tooltip={reactant.tooltip}
                                onClick={() => act('reagent_click', {
                                  id: reactant.id,
                                })} />
                            ) || (
                              <Button
                                key={reactant.name}
                                icon="vial"
                                color={reactant.color}
                                content={reactant.name + " " + reactant.ratio + "u"}
                                onClick={() => act('reagent_click', {
                                  id: reactant.id,
                                })} />
                            )}
                          </Box>
                        ))}
                      </TableRow>
                    </TableCell>
                    <TableCell>
                      <TableRow bold color="label" height="120px">
                        Thermodynamics:
                      </TableRow>
                      <TableRow>
                        <Chart.Line
                          height="120px"
                          fillPositionedParent
                          data={reagent_mode_recipe.thermodynamics}
                          strokeColor={"#fc0303"}
                          fillColor={"#ff3b3b"} />
                      </TableRow>
                      <TableRow>
                        {"Max rate: " + reagent_mode_recipe.thermoUpper}
                        {reagent_mode_recipe.thermics}
                      </TableRow>
                    </TableCell>
                    <TableCell>
                      <TableRow bold color="label">
                        Purity effects:
                      </TableRow>
                      <TableRow>
                        {"Optimal pH range: " + reagent_mode_recipe.lowerpH + "-" + reagent_mode_recipe.upperpH}
                        {"Inverse purity: " + reagent_mode_recipe.inversePurity}
                        {"Minimum purity: " + reagent_mode_recipe.minPurity}
                      </TableRow>
                    </TableCell>
                  </Table>
                ) || (
                  <Box>
                    No reaction selected!
                  </Box>
                )}
              </Section>
            </TableRow>
            <TableRow>
              <Section title="Reagent lookup"
                buttons={(
                  <Button
                    content="Search reagents"
                    icon="search"
                    onClick={() => act('search_reagent')} />
                )}>
                {!!hasReagent && (
                  <Table>
                    <TableCell>
                      <TableRow bold color="label">
                        Reagent:
                      </TableRow>
                      <TableRow>
                        <Icon name="circle" mr={1} color={reagent_mode_reagent.reagentCol} />
                        {reagent_mode_reagent.name}
                      </TableRow>
                    </TableCell>
                    <TableCell>
                      <TableRow bold color="label">
                        Description:
                      </TableRow>
                      <TableRow>
                        {reagent_mode_reagent.desc}
                      </TableRow>
                    </TableCell>
                    <TableCell>
                      <TableRow bold color="label">
                        pH:
                      </TableRow>
                      <TableRow>
                        <Icon name="circle" mr={1} color={reagent_mode_reagent.pHCol} />
                        {reagent_mode_reagent.pH}
                      </TableRow>
                    </TableCell>
                    <TableCell>
                      <TableRow bold color="label">
                        Properties:
                      </TableRow>
                      <TableRow>
                        Overdose: {reagent_mode_reagent.OD}u
                        Addiction: {reagent_mode_reagent.Addiction}u
                        Metabolization rate: {reagent_mode_reagent.metaRate}u/s
                      </TableRow>
                    </TableCell>
                    <TableCell>
                      <TableRow bold color="label">
                        Impurities:
                      </TableRow>
                      <TableRow>
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
                      </TableRow>
                    </TableCell>
                    <TableCell>
                      <Button
                        key={reagent_mode_reagent.id}
                        icon="flask"
                        content={"Find associated reaction"}
                        onClick={() => act('reagent_click', {
                          id: reagent_mode_reagent.id,
                        })} />
                    </TableCell>
                  </Table>
                )}
              </Section>
            </TableRow>
          </TableCell>
        </Table>         
        <Section title="Tags">
          <Button
            content={"Brute"}
            color={brute ? "green" : "red"}
            onClick={() => { 
              act('toggle_tag_brute'); setBrute(!brute); }}>
            <Icon name="gavel" mr={1} />
            Brute
          </Button>
          <Button
            content={"Burn"}
            color={burn ? "green" : "red"}
            onClick={() => { act('toggle_tag_burn'); setBurn(!burn); }}>
            <Icon name="burn" mr={1} />
            Burn
          </Button>
          <Button
            content={"Toxin"}
            color={toxin ? "green" : "red"}
            onClick={() => { act('toggle_tag_toxin'); setToxin(!toxin); }}>
            <Icon name="biohazard" mr={1} />
            Toxin
          </Button>
          <Button
            content={"Oxy"}
            color={oxy ? "green" : "red"}
            onClick={() => { act('toggle_tag_oxy'); setOxy(!oxy); }}>
            <Icon name="lungs" mr={1} />
            Suffocation
          </Button>
          <Button
            content={"Clone"}
            color={clone ? "green" : "red"}
            onClick={() => { act('toggle_tag_clone'); setClone(!clone); }}>
            <Icon name="male" mr={1} />
            Clone
          </Button>
          <Button
            content={"organ"}
            color={organ ? "green" : "red"}
            onClick={() => { act('toggle_tag_organ'); setOrgan(!organ); }}>
            <Icon name="hand-holding-heart" mr={1} />
            Organ
          </Button>
          <Button
            content={"Healing"}
            color={healing ? "green" : "red"}
            onClick={() => { act('toggle_tag_healing'); setHealing(!healing); }}>
            <Icon name="medkit" mr={1} />
            Healing
          </Button>
          <Button
            content={"damaging"}
            color={damaging ? "green" : "red"}
            onClick={() => { act('toggle_tag_damaging'); setDamaging(!damaging); }}>
            <Icon name="skull-crossbones" mr={1} />
            Damaging
          </Button>
          <Button
            content={"explosiive"}
            color={explosive ? "green" : "red"}
            onClick={() => { act('toggle_tag_explosive'); setExplosive(!explosive); }}>
            <Icon name="bomb" mr={1} />
            Explosive
          </Button>
          <Button
            content={"other"}
            color={other ? "green" : "red"}
            onClick={() => { act('toggle_tag_other'); setOther(!other); }}>
            <Icon name="question-mark" mr={1} />
            Other
          </Button>
          <Button
            content={"easy"}
            color={easy ? "green" : "red"}
            onClick={() => { act('toggle_tag_easy'); setEasy(!easy); }}>
            <Icon name="chess-pawn" mr={1} />
            Easy
          </Button>
          <Button
            content={"moderate"}
            color={moderate ? "green" : "red"}
            onClick={() => { act('toggle_tag_moderate'); setModerate(!moderate); }}>
            <Icon name="chess-knight" mr={1} />
            Moderate
          </Button>
          <Button
            content={"hard"}
            color={hard ? "green" : "red"}
            onClick={() => { act('toggle_tag_hard'); setHard(!hard); }}>
            <Icon name="chess-queen" mr={1} />
            Hard
          </Button>
        </Section>
        <Section scrollable title="Possible recipies">
          <Table>
            {master_reaction_list.map(reaction => (
              <TableCell key={reaction.name}>
                <TableRow bold color="label">
                  <Button
                    key={reaction.name}
                    icon="flask"
                    color="purple"
                    content={reaction.name}
                    onClick={() => act('reaction_click', {
                      id: reaction.id,
                    })} />  
                  {reaction.name}
                </TableRow>
                <TableRow>
                  {reaction.reactant.map(reactant => (
                    <Button
                      key={reactant.name}
                      icon="vial"
                      color={reactant.color}
                      content={reactant.name}
                      onClick={() => act('reagent_click', {
                        id: reactant.id,
                      })} />                    
                  ))}
                </TableRow>
              </TableCell>  
            ))}
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
};
