import { SuiObjectChange } from "@mysten/sui/client";
import { ENV } from "../env";

interface Args {
  objectChanges: SuiObjectChange[];
}

interface Response {
  swordsIds: string[];
  heroesIds: string[];
}

/**
 * Parses the provided SuiObjectChange[].
 * Extracts the IDs of the created Heroes and Swords NFTs, filtering by objectType.
 */
export const parseCreatedObjectsIds = ({ objectChanges }: Args): Response => {
  const createdObjects = objectChanges.filter(
    (change) => change.type === "created"
  );
  // This won't work because TS sucks
  // const createdObjects = objectChanges.filter(
  //   ({type}) => type === "created"
  // );

  const swords = createdObjects.filter(
    (change) => change.objectType === `${ENV.PACKAGE_ID}::blacksmith::Sword`
  );
  const heroes = createdObjects.filter(
    (change) => change.objectType === `${ENV.PACKAGE_ID}::hero::Hero`
  );

  const swordsIds = swords.map((sword) => sword.objectId);
  const heroesIds = heroes.map((hero) => hero.objectId);

  return {
    swordsIds,
    heroesIds,
  };
};
