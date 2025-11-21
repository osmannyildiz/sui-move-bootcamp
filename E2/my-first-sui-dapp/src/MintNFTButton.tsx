import {
  useCurrentAccount,
  useSignAndExecuteTransaction,
  useSuiClient,
} from "@mysten/dapp-kit";
import { Transaction } from "@mysten/sui/transactions";
import { Button } from "@radix-ui/themes";
import { useQueryClient } from "@tanstack/react-query";
import { useState } from "react";
import { PACKAGE_ID } from "./config";

export function MintNFTButton() {
  const suiClient = useSuiClient();
  const account = useCurrentAccount();
  const queryClient = useQueryClient();
  const { mutateAsync } = useSignAndExecuteTransaction();

  const [isPending, setIsPending] = useState(false);

  const handleMint = async () => {
    if (!account?.address) {
      alert("Please connect your wallet");
      return;
    }

    const tx = new Transaction();

    const hero = tx.moveCall({
      target: `${PACKAGE_ID}::hero::mint_hero`,
      // arguments: [],
      // typeArguments: [],
    });
    tx.transferObjects([hero], account.address);

    setIsPending(true);
    try {
      const result = await mutateAsync({
        transaction: tx,
      });

      await suiClient.waitForTransaction({
        digest: result.digest,
      });

      // queryClient.invalidateQueries({ queryKey: ["getOwnedObjects"] });
      queryClient.invalidateQueries({
        predicate: (query) =>
          query.queryKey[0] === "testnet" &&
          query.queryKey[1] === "getOwnedObjects",
      });
    } catch (error) {
      console.error("Error minting NFT:", error);
      alert("Oops! Something went wrong. Please try again.");
    } finally {
      setIsPending(false);
    }
  };

  return (
    <Button size="4" loading={isPending} onClick={handleMint}>
      Mint Hero NFT
    </Button>
  );
}
