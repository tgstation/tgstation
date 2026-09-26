import { useState } from 'react';
import { useBackend } from 'tgui/backend';
import { Box, Button, Floating, Stack } from 'tgui-core/components';
import { findIcon } from '../helpers';
import type { AtomData, CraftingData } from '../types';
import { RecipeContent } from './RecipeContent';

type Props = {
  amount: number;
  atom_id: string;
  setParentForceFloating?: (state: boolean) => void;
};

export function AtomContent(props: Props) {
  const { amount, atom_id, setParentForceFloating } = props;
  const { data } = useBackend<CraftingData>();
  const { atom_data, recipes } = data;

  const atom_id_int = Number(atom_id);
  const atom = atom_data[atom_id_int - 1];

  // check if the atom itself has a recipe associated
  const hasRecipe = recipes.filter((recipe) => recipe.id === atom_id_int);
  if (hasRecipe.length <= 0) {
    return (
      <AtomContentInner
        atom={atom}
        atom_id={atom_id_int}
        amount={amount}
        underline={false}
      />
    );
  }

  const [forceFloating, setForceFloating] = useState(false);
  const [shownRecipe, setShownRecipe] = useState(hasRecipe[0]);

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
      placement="bottom"
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
          {hasRecipe.length > 1 && (
            <Stack align="center" fill mb={0.5}>
              <Stack.Item grow>
                <Button
                  fluid
                  icon="arrow-left"
                  align="center"
                  onClick={() =>
                    setShownRecipe(
                      hasRecipe[
                        (hasRecipe.indexOf(shownRecipe) -
                          1 +
                          hasRecipe.length) %
                          hasRecipe.length
                      ],
                    )
                  }
                />
              </Stack.Item>
              <Stack.Item grow>
                <Button
                  fluid
                  icon="arrow-right"
                  align="center"
                  onClick={() =>
                    setShownRecipe(
                      hasRecipe[
                        (hasRecipe.indexOf(shownRecipe) + 1) % hasRecipe.length
                      ],
                    )
                  }
                />
              </Stack.Item>
            </Stack>
          )}
          <RecipeContent
            item={shownRecipe}
            nodesc={true}
            setParentForceFloating={setForceFloating}
            showIcon={false}
          />
        </Box>
      }
    >
      {/* hover doesn't work without this box wrapper */}
      <Box>
        <AtomContentInner
          atom={atom}
          atom_id={atom_id_int}
          amount={amount}
          underline={true}
        />
      </Box>
    </Floating>
  );
}

type AtomContentInnerProps = {
  atom: AtomData;
  atom_id: number;
  amount: number;
  underline?: boolean;
};

function AtomContentInner(props: AtomContentInnerProps) {
  const { atom, atom_id, amount, underline = false } = props;
  const { data } = useBackend<CraftingData>();

  return (
    <Box my={1}>
      <Box
        verticalAlign="middle"
        inline
        my={-1}
        mr={0.5}
        className={findIcon(atom_id, data)}
      />
      <Box inline verticalAlign="middle">
        {underline ? (
          <Box
            inline
            style={{
              borderBottom: '2px dotted rgba(255, 255, 255, 0.8)',
            }}
          >
            {atom.name}
          </Box>
        ) : (
          atom.name
        )}
        {atom.is_reagent ? `\xa0${amount}u` : amount > 1 && `\xa0${amount}x`}
      </Box>
    </Box>
  );
}
