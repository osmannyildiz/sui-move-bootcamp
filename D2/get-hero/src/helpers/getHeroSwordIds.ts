import { ENV } from "../env";
import { suiClient } from "../suiClient";

/**
 * Gets the dynamic object fields attached to a hero object by the object's id.
 * For the scope of this exercise, we ignore pagination, and just fetch the first page.
 * Filters the objects and returns the object ids of the swords.
 */
export const getHeroSwordIds = async (id: string): Promise<string[]> => {
  // Fetch the dynamic fields for the given hero object id
  const resp = await suiClient.getDynamicFields({
    parentId: id,
  });
  console.log("== Dynamic Fields: ", resp);

  return resp.data
    .filter(
      ({ objectType }) => objectType === `${ENV.PACKAGE_ID}::blacksmith::Sword`
    )
    .map(({ objectId }) => objectId);
};
