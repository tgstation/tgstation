import { Box, LabeledList, Chart, Flex, Button, Icon } from '../../components';
import { useBackend } from '../../backend';

export const RecipeLookup = (props, context) => {
  const { recipe } = props;
  const { act } = useBackend(context);
  return (
        
    recipe && (
      <LabeledList labelBold>
        <LabeledList.Item bold label="Recipe">
          <Icon name="circle" mr={1} color={recipe.reagentCol} />
          {recipe.name}
          <Button
            key={"reduce_index"}
            icon="arrow-left"
            ml={3}
            disabled={recipe.subReactIndex
                            === 1 ? true : false}
            content={null}
            onClick={() => act('reduce_index', {
              id: recipe.name,
            })} />
          <Button
            key={"increment_index"}
            icon="arrow-right"
            disabled={recipe.subReactIndex
                            === recipe.subReactLen?true:false}
            content={null}
            onClick={() => act('increment_index', {
              id: recipe.name,
            })} />
        </LabeledList.Item>
        {recipe.products && (
          <LabeledList.Item bold label="Products">
            {recipe.products.map(product => (
              <Button
                key={product.name}
                icon="vial"
                disabled={product.hasProduct ? true : false}
                content={product.ratio + "u " + product.name}
                onClick={() => act('reagent_click', {
                  id: product.id,
                })} />
            ))}
          </LabeledList.Item>
        )}
        <LabeledList.Item bold label="Reactants">
          {recipe.reactants.map(reactant => (
            <Box key={reactant.id}>
              <Button
                key={reactant.name}
                icon="vial"
                color={reactant.color}
                content={reactant.ratio + "u " + reactant.name}
                onClick={() => act('reagent_click', {
                  id: reactant.id,
                })} />
              {!!reactant.tooltipBool && (
                <Button
                  key={reactant.name}
                  icon="flask"
                  color={"purple"}
                  content={null}
                  tooltip={reactant.tooltip}
                  tooltipPosition={"right"}
                  onClick={() => act('find_reagent_reaction', {
                    id: reactant.id,
                  })} />
              )}
            </Box>
          ))}
        </LabeledList.Item>
        {recipe.catalysts && (
          <LabeledList.Item bold label="Catalysts">
            {recipe.catalysts.map(catalyst => (
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
          </LabeledList.Item>
        )}
        {recipe.reqContainer && (
          <LabeledList.Item bold label="Container">
            <Button
              color="transparent"
              textColor="white"
              tooltipPosition="right"
              content={recipe.reqContainer}
              tooltip="The required container for this reaction to occur in." />
          </LabeledList.Item>
        )}
        <LabeledList.Item bold label="Purity">
          <LabeledList>
            <LabeledList.Item label="Optimal pH range" >
              <Button
                color="transparent"
                textColor="white"
                tooltipPosition="right"
                content={recipe.lowerpH + "-" + recipe.upperpH}
                tooltip="If your reaction is kept within these bounds then the purity of your product will be 100%" />
            </LabeledList.Item>
            <LabeledList.Item label="Inverse purity">
              <Button
                color="transparent"
                textColor="white"
                tooltipPosition="right"
                content={recipe.inversePurity}
                tooltip="If your purity is below this it will 100% convert into the product's associated Inverse reagent on consumption." />
            </LabeledList.Item>
            <LabeledList.Item label="Minimum purity">
              <Button
                color="transparent"
                tooltipPosition="right"
                textColor="white"
                content={recipe.minPurity}
                tooltip="If your purity is below this at any point during the reaction, it will cause negative effects, and if it remains below this value on completion it will convert into the product's associated Failed reagent." />
            </LabeledList.Item>
          </LabeledList>
        </LabeledList.Item>
        <LabeledList.Item bold label="Rate profile" width="10px">
          <Flex
            height="50px"
            width="225px"
            position="relative"
            style={{
              'background-color': 'black',
            }} >
            <Chart.Line
              fillPositionedParent
              data={recipe.thermodynamics}
              strokeWidth={0}
              fillColor={"#3cf072"} />
            {recipe.explosive && (
              <Chart.Line
                position="absolute"
                top={0.01}
                bottom={0}
                right={recipe.isColdRecipe?16.41:0}
                width="28px"
                data={recipe.explosive}
                strokeWidth={0}
                fillColor={"#d92727"} />
            )}
          </Flex>
        </LabeledList.Item>
        <LabeledList.Item bold label="Dynamics">
          <Flex position="relative" top="5px" left="-12px">
            <Button
              color="transparent"
              textColor={recipe.isColdRecipe ? "red" : "white"}
              content={recipe.isColdRecipe ? recipe.explodeTemp+"K" : recipe.tempMin+"K"}
              tooltip={recipe.isColdRecipe ? "The temperature at which it is underheated, causing negative effects on the reaction." : "The minimum temperature needed for this reaction to start. Heating it up past this point will increase the reaction rate."}
              tooltipPosition="right" />
            {recipe.explosive && (
              <Flex width="190px" position="relative" top="0px" left="155px" >
                <Button
                  color="transparent"
                  textColor={recipe.isColdRecipe ? "white" : "red"}
                  content={recipe.isColdRecipe ? recipe.tempMin+"K" : recipe.explodeTemp+"K"}
                  tooltip={recipe.isColdRecipe ? "The minimum temperature needed for this reaction to start. Heating it up past this point will increase the reaction rate." : "The temperature at which it is overheated, causing negative effects on the reaction."}
                  tooltipPosition="right" />
              </Flex>
            )}
          </Flex>
          <LabeledList.Item label="Optimal rate">
            <Button
              color="transparent"
              textColor="white"
              content={recipe.thermoUpper+"u/s"}
              tooltip="The fastest rate the reaction can go, in units per second. This is the plateu region shown in the rate profile above."
              tooltipPosition="right" />
          </LabeledList.Item>
          <Flex>
            <Button
              color="transparent"
              textColor="white"
              content={recipe.thermics}
              tooltip="The heat generated by a reaction - exothermic produces heat, endothermic consumes heat."
              tooltipPosition="right" />
          </Flex>
        </LabeledList.Item>
      </LabeledList>
    ) || (
      <Box>
        No reaction selected!
      </Box>
    )
  );
};