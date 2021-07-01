import { useBackend } from '../../backend';
import { Box, Button, Chart, Flex, Icon, LabeledList, Tooltip } from '../../components';

export const RecipeLookup = (props, context) => {
  const { recipe, bookmarkedReactions } = props;
  const { act, data } = useBackend(context);
  if (!recipe) {
    return (
      <Box>
        No reaction selected!
      </Box>
    );
  }

  const getReaction = id => {
    return data.master_reaction_list.filter(reaction => (
      reaction.id === id
    ));
  };

  const addBookmark = bookmark => {
    bookmarkedReactions.add(bookmark);
  };

  return (
    <LabeledList>
      <LabeledList.Item bold label="Recipe">
        <Icon name="circle" mr={1} color={recipe.reagentCol} />
        {recipe.name}
        <Button
          icon="arrow-left"
          ml={3}
          disabled={recipe.subReactIndex === 1}
          onClick={() => act('reduce_index', {
            id: recipe.name,
          })} />
        <Button
          icon="arrow-right"
          disabled={recipe.subReactIndex === recipe.subReactLen}
          onClick={() => act('increment_index', {
            id: recipe.name,
          })} />
        {bookmarkedReactions && (
          <Button
            icon="book"
            color="green"
            disabled={bookmarkedReactions.has(getReaction(recipe.id)[0])}
            onClick={() => {
              addBookmark(getReaction(recipe.id)[0]);
              act('update_ui');
            }} />
        )}
      </LabeledList.Item>
      {recipe.products && (
        <LabeledList.Item bold label="Products">
          {recipe.products.map(product => (
            <Button
              key={product.name}
              icon="vial"
              disabled={product.hasProduct}
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
              icon="vial"
              color={reactant.color}
              content={reactant.ratio + "u " + reactant.name}
              onClick={() => act('reagent_click', {
                id: reactant.id,
              })} />
            {!!reactant.tooltipBool && (
              <Button
                icon="flask"
                color="purple"
                tooltip={reactant.tooltip}
                tooltipPosition="right"
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
          <LabeledList.Item label="Optimal pH range">
            <Box position="relative">
              <Tooltip
                content="If your reaction is kept within these bounds then the purity of your product will be 100%">
                {recipe.lowerpH + "-" + recipe.upperpH}
              </Tooltip>
            </Box>
          </LabeledList.Item>
          {!!recipe.inversePurity && (
            <LabeledList.Item label="Inverse purity">
              <Box position="relative">
                <Tooltip
                  content="If your purity is below this it will 100% convert into the product's associated Inverse reagent on consumption." >
                  {`<${(recipe.inversePurity*100)}%`}
                </Tooltip>
              </Box>
            </LabeledList.Item>
          )}
          {!!recipe.minPurity && (
            <LabeledList.Item label="Minimum purity">
              <Box position="relative">
                <Tooltip
                  content="If your purity is below this at any point during the reaction, it will cause negative effects, and if it remains below this value on completion it will convert into the product's associated Failed reagent." >
                  {`<${(recipe.minPurity*100)}%`}
                </Tooltip>
              </Box>
            </LabeledList.Item>
          )}
        </LabeledList>
      </LabeledList.Item>
      <LabeledList.Item bold label="Rate profile" width="10px">
        <Box
          height="50px"
          position="relative"
          style={{
            'background-color': 'black',
          }}>
          <Chart.Line
            fillPositionedParent
            data={recipe.thermodynamics}
            strokeWidth={0}
            fillColor={"#3cf072"} />
          {recipe.explosive && (
            <Chart.Line
              position="absolute"
              justify="right"
              top={0.01}
              bottom={0}
              right={recipe.isColdRecipe ? null : 0}
              width="28px"
              data={recipe.explosive}
              strokeWidth={0}
              fillColor={"#d92727"} />
          )}
        </Box>
        <Flex
          justify="space-between">
          <Tooltip
            content={recipe.isColdRecipe
              ? "The temperature at which it is underheated, causing negative effects on the reaction."
              : "The minimum temperature needed for this reaction to start. Heating it up past this point will increase the reaction rate."} >
            <Flex.Item
              position="relative"
              textColor={recipe.isColdRecipe && "red"}>
              {recipe.isColdRecipe
                ? recipe.explodeTemp + "K"
                : recipe.tempMin + "K"}
            </Flex.Item>
          </Tooltip>

          {recipe.explosive && (
            <Tooltip
              content={recipe.isColdRecipe
                ? "The minimum temperature needed for this reaction to start. Heating it up past this point will increase the reaction rate."
                : "The temperature at which it is overheated, causing negative effects on the reaction."}>
              <Flex.Item
                position="relative"
                textColor={!recipe.isColdRecipe && "red"}>
                {recipe.isColdRecipe
                  ? recipe.tempMin + "K"
                  : recipe.explodeTemp + "K"}
              </Flex.Item>
            </Tooltip>
          )}
        </Flex>
      </LabeledList.Item>
      <LabeledList.Item bold label="Dynamics">
        <LabeledList>
          <LabeledList.Item label="Optimal rate">
            <Tooltip
              content="The fastest rate the reaction can go, in units per second. This is the plateu region shown in the rate profile above.">
              <Box position="relative">
                {recipe.thermoUpper + "u/s"}
              </Box>
            </Tooltip>
          </LabeledList.Item>
        </LabeledList>
        <Tooltip
          content="The heat generated by a reaction - exothermic produces heat, endothermic consumes heat." >
          <Box
            position="relative">
            {recipe.thermics}
          </Box>
        </Tooltip>
      </LabeledList.Item>
    </LabeledList>
  );
};
