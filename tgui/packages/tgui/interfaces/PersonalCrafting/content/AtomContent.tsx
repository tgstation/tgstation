import { useState } from 'react';
import { useBackend } from 'tgui/backend';
import { Box, Floating } from 'tgui-core/components';
import { findIcon } from '../helpers';
import type { CraftingData } from '../types';
import { RecipeContent } from './RecipeContent';

type Props = {
  amount: number;
  atom_id: string;
  setParentForceFloating?: (state: boolean) => void;
};

export function AtomContent(props: Props) {
  const { amount, setParentForceFloating } = props;
  const { data } = useBackend<CraftingData>();

  const atom_id = Number(props.atom_id);
  const atom = data.atom_data[atom_id - 1];

  const visibleContent = (
    <Box my={1}>
      <Box
        verticalAlign="middle"
        inline
        my={-1}
        mr={0.5}
        className={findIcon(atom_id, data)}
      />
      <Box inline verticalAlign="middle">
        {atom.name}
        {atom.is_reagent ? `\xa0${amount}u` : amount > 1 && `\xa0${amount}x`}
      </Box>
    </Box>
  );

  // check if the atom itself has a recipe associated
  const hasRecipe = data.recipes.filter((recipe) => recipe.id === atom_id)[0];
  if (!hasRecipe) {
    return visibleContent;
  }

  const [forceFloating, setForceFloating] = useState(false);

  // add a tooltip to recursively show the recipe for this atom
  return (
    <Floating // `|| undefined` is used to avoid passing `false`.
      // The component treats `false` as `closed`,
      // whereas `undefined` means "not controlled",
      // allowing it to open and close normally.
      handleOpen={forceFloating || undefined}
      // No similar handling is necessary for `disabled`.
      // If we don't disable it it will close on unhover, for some reason.
      disabled={forceFloating}
      placement="left"
      closeAfterInteract={false}
      // `hoverOpen` is obvious, but `hoverSafePolygon` is what is needed
      // to allow the user to move their mouse over to the floating window.
      hoverOpen={true}
      hoverSafePolygon={true}
      // When the window state changes, we go up the chain to inform the parent.
      // At the same time we *always* reset forced state on close,
      // to prevent it from being stuck in limbo if it somehow closes otherwise.
      onOpenChange={(state) => {
        if (setParentForceFloating) {
          setParentForceFloating(state);
        }
        if (!state) {
          setForceFloating(false);
        }
      }}
      content={
        <Box
          p={0.5}
          backgroundColor={`hsl(0, 0%, 15%)`}
          style={{
            borderRadius: '4px',
            backdropFilter: 'blur(12px)',
          }}
        >
          <RecipeContent
            item={hasRecipe}
            nodesc={true}
            setParentForceFloating={setForceFloating}
          />
        </Box>
      }
    >
      {visibleContent}
    </Floating>
  );
}
