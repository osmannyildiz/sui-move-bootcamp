import { ENV } from "../env";
import { suiClient } from "../suiClient";

/**
 * Gets the dynamic object fields attached to a hero object by the object's id.
 * For the scope of this exercise, we ignore pagination, and just fetch the first page.
 * Filters the objects and returns the object ids of the swords.
 */
export const getHeroSwordIds = async (id: string): Promise<string[]> => {
  const { data } = await suiClient.getDynamicFields({
    parentId: id,
  });
  const swords = data.filter(
    (field) => field.objectType === `${ENV.PACKAGE_ID}::blacksmith::Sword`
  );
  const swordIds = swords.map((sword) => sword.objectId);
  return swordIds;
};
