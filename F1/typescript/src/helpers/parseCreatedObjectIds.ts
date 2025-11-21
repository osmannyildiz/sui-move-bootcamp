import { SuiObjectChange } from "@mysten/sui/client";
import { ENV } from "../env";

interface Args {
  objectChanges: SuiObjectChange[];
}

interface Response {
  heroesIds: string[];
}

/**
 * Parses the provided SuiObjectChange[].
 * Extracts the IDs of the created Heroes and Weapons NFTs, filtering by objectType.
 */
export const parseCreatedObjectsIds = ({ objectChanges }: Args): Response => {
  const createdObjects = objectChanges.filter(
    (change) => change.type === "created"
  );
  const heroes = createdObjects.filter(
    (change) => change.objectType === `${ENV.PACKAGE_ID}::hero::Hero`
  );
  const heroesIds = heroes.map((hero) => hero.objectId);
  return {
    heroesIds,
  };
};
