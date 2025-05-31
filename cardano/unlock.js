import {
  deserializeAddress,
  deserializeDatum,
  unixTimeToEnclosingSlot,
  SLOT_CONFIG_NETWORK,
} from "@meshsdk/core";

import {
  getTxBuilder,
  beneficiary_wallet,
  scriptAddr,
  scriptCbor,
  blockchainProvider,
} from "./common.js";
import { mConStr0 } from "@meshsdk/common";

async function withdrawFundTx(vestingUtxo) {
  const utxos = await beneficiary_wallet.getUtxos();
  const beneficiaryAddress = beneficiary_wallet.addresses.baseAddressBech32;
  const collateral = await beneficiary_wallet.getCollateral();
  const collateralInput = collateral[0].input;
  const collateralOutput = collateral[0].output;

  const { pubKeyHash: beneficiaryPubKeyHash } = deserializeAddress(
    beneficiary_wallet.addresses.baseAddressBech32,
  );

  const txBuilder = getTxBuilder();
  await txBuilder
    .spendingPlutusScript("V3")
    .txIn(
      vestingUtxo.input.txHash,
      vestingUtxo.input.outputIndex,
      vestingUtxo.output.amount,
      scriptAddr,
    )
    .spendingReferenceTxInInlineDatumPresent()
    .spendingReferenceTxInRedeemerValue(
      "0000000000000000000000000000000000000000000000000000000000000000",
    )
    .txInScript(scriptCbor)
    .txOut(beneficiaryAddress, [])
    .txInCollateral(
      collateralInput.txHash,
      collateralInput.outputIndex,
      collateralOutput.amount,
      collateralOutput.address,
    )
    .requiredSignerHash(beneficiaryPubKeyHash)
    .changeAddress(beneficiaryAddress)
    .selectUtxosFrom(utxos)
    .complete();
  return txBuilder.txHex;
}

async function main() {
  const txHashFromDesposit =
    "a37eea12333a72217776ea2c898a264c083c696fafe7de7ae3c7e186483a557a";

  const utxo = await getUtxoByTxHash(txHashFromDesposit);

  if (utxo === undefined) throw new Error("UTxO not found");

  const unsignedTx = await withdrawFundTx(utxo);

  const signedTx = await beneficiary_wallet.signTx(unsignedTx);

  const txHash = await beneficiary_wallet.submitTx(signedTx);
  console.log("txHash", txHash);
}

async function getUtxoByTxHash(txHash) {
  const utxos = await blockchainProvider.fetchUTxOs(txHash);
  if (utxos.length === 0) {
    throw new Error("UTxO not found");
  }
  return utxos[0];
}

main();
