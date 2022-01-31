export enum BodyZone {
  Head = "head",
  Chest = "chest",
  LeftArm = "l_arm",
  RightArm = "r_arm",
  LeftLeg = "l_leg",
  RightLeg = "r_leg",
  Eyes = "eyes",
  Mouth = "mouth",
  Groin = "groin",
}

const bodyZonePixelToZone: (x: number, y: number) => (BodyZone | null)
  = (x, y) => {
    // TypeScript translation of /atom/movable/screen/zone_sel/proc/get_zone_at
    if (y < 1) {
      return null;
    } else if (y < 10) {
      if (x > 10 && x < 15) {
        return BodyZone.RightLeg;
      } else if (x > 17 && x < 22) {
        return BodyZone.LeftLeg;
      }
    } else if (y < 13) {
      if (x > 8 && x < 11) {
        return BodyZone.RightArm;
      } else if (x > 12 && x < 20) {
        return BodyZone.Groin;
      } else if (x > 21 && x < 24) {
        return BodyZone.LeftArm;
      }
    } else if (y < 22) {
      if (x > 8 && x < 11) {
        return BodyZone.RightArm;
      } else if (x > 12 && x < 20) {
        return BodyZone.Chest;
      } else if (x > 21 && x < 24) {
        return BodyZone.LeftArm;
      }
    } else if (y < 30 && (x > 12 && x < 20)) {
      if (y > 23 && y < 24 && (x > 15 && x < 17)) {
        return BodyZone.Mouth;
      } else if (y > 26.00 && y < 26.99 && (x > 15 && x < 17)) {
        // The eyeline
        return BodyZone.Eyes;
      } else if (y > 25 && y < 27 && (x > 15 && x < 17)) {
        return BodyZone.Eyes;
      } else {
        return BodyZone.Head;
      }
    }

    return null;
  };
