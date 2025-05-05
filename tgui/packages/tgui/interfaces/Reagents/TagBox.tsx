import { Button, LabeledList } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { ReagentsData, ReagentsProps } from './types';

export function TagBox(props: ReagentsProps) {
  const { act, data } = useBackend<ReagentsData>();
  const { bitflags, selectedBitflags } = data;

  const [page, setPage] = props.pageState;

  return (
    <LabeledList>
      <LabeledList.Item label="Affects">
        <Button
          color={selectedBitflags & bitflags.BRUTE ? 'green' : 'red'}
          icon="gavel"
          onClick={() => {
            act('toggle_tag_brute');
            setPage(1);
          }}
        >
          Brute
        </Button>
        <Button
          color={selectedBitflags & bitflags.BURN ? 'green' : 'red'}
          icon="burn"
          onClick={() => {
            act('toggle_tag_burn');
            setPage(1);
          }}
        >
          Burn
        </Button>
        <Button
          color={selectedBitflags & bitflags.TOXIN ? 'green' : 'red'}
          icon="biohazard"
          onClick={() => {
            act('toggle_tag_toxin');
            setPage(1);
          }}
        >
          Toxin
        </Button>
        <Button
          color={selectedBitflags & bitflags.OXY ? 'green' : 'red'}
          icon="wind"
          onClick={() => {
            act('toggle_tag_oxy');
            setPage(1);
          }}
        >
          Suffocation
        </Button>
        <Button
          color={selectedBitflags & bitflags.ORGAN ? 'green' : 'red'}
          icon="brain"
          onClick={() => {
            act('toggle_tag_organ');
            setPage(1);
          }}
        >
          Organ
        </Button>
        <Button
          icon="flask"
          color={selectedBitflags & bitflags.CHEMICAL ? 'green' : 'red'}
          onClick={() => {
            act('toggle_tag_chemical');
            setPage(1);
          }}
        >
          Chemical
        </Button>
        <Button
          icon="seedling"
          color={selectedBitflags & bitflags.PLANT ? 'green' : 'red'}
          onClick={() => {
            act('toggle_tag_plant');
            setPage(1);
          }}
        >
          Plants
        </Button>
        <Button
          icon="question"
          color={selectedBitflags & bitflags.OTHER ? 'green' : 'red'}
          onClick={() => {
            act('toggle_tag_other');
            setPage(1);
          }}
        >
          Other
        </Button>
      </LabeledList.Item>
      <LabeledList.Item label="Type">
        <Button
          color={selectedBitflags & bitflags.DRINK ? 'green' : 'red'}
          icon="cocktail"
          onClick={() => {
            act('toggle_tag_drink');
            setPage(1);
          }}
        >
          Drink
        </Button>
        <Button
          color={selectedBitflags & bitflags.FOOD ? 'green' : 'red'}
          icon="drumstick-bite"
          onClick={() => {
            act('toggle_tag_food');
            setPage(1);
          }}
        >
          Food
        </Button>
        <Button
          color={selectedBitflags & bitflags.HEALING ? 'green' : 'red'}
          icon="medkit"
          onClick={() => {
            act('toggle_tag_healing');
            setPage(1);
          }}
        >
          Healing
        </Button>
        <Button
          icon="skull-crossbones"
          color={selectedBitflags & bitflags.DAMAGING ? 'green' : 'red'}
          onClick={() => {
            act('toggle_tag_damaging');
            setPage(1);
          }}
        >
          Toxic
        </Button>
        <Button
          icon="pills"
          color={selectedBitflags & bitflags.DRUG ? 'green' : 'red'}
          onClick={() => {
            act('toggle_tag_drug');
            setPage(1);
          }}
        >
          Drugs
        </Button>
        <Button
          icon="microscope"
          color={selectedBitflags & bitflags.SLIME ? 'green' : 'red'}
          onClick={() => {
            act('toggle_tag_slime');
            setPage(1);
          }}
        >
          Slime
        </Button>
        <Button
          icon="bomb"
          color={selectedBitflags & bitflags.EXPLOSIVE ? 'green' : 'red'}
          onClick={() => {
            act('toggle_tag_explosive');
            setPage(1);
          }}
        >
          Explosive
        </Button>
        <Button
          icon="puzzle-piece"
          color={selectedBitflags & bitflags.UNIQUE ? 'green' : 'red'}
          onClick={() => {
            act('toggle_tag_unique');
            setPage(1);
          }}
        >
          Unique
        </Button>
      </LabeledList.Item>
      <LabeledList.Item label="Difficulty">
        <Button
          icon="chess-pawn"
          color={selectedBitflags & bitflags.EASY ? 'green' : 'red'}
          onClick={() => {
            act('toggle_tag_easy');
            setPage(1);
          }}
        >
          Easy
        </Button>
        <Button
          icon="chess-knight"
          color={selectedBitflags & bitflags.MODERATE ? 'green' : 'red'}
          onClick={() => {
            act('toggle_tag_moderate');
            setPage(1);
          }}
        >
          Moderate
        </Button>
        <Button
          icon="chess-queen"
          color={selectedBitflags & bitflags.HARD ? 'green' : 'red'}
          onClick={() => {
            act('toggle_tag_hard');
            setPage(1);
          }}
        >
          Hard
        </Button>
        <Button
          icon="exclamation-triangle"
          color={selectedBitflags & bitflags.DANGEROUS ? 'green' : 'red'}
          onClick={() => {
            act('toggle_tag_dangerous');
            setPage(1);
          }}
        >
          Dangerous
        </Button>
        <Button
          icon="recycle"
          color={selectedBitflags & bitflags.COMPETITIVE ? 'green' : 'red'}
          onClick={() => {
            act('toggle_tag_competitive');
            setPage(1);
          }}
        >
          Competitive
        </Button>
      </LabeledList.Item>
    </LabeledList>
  );
}
