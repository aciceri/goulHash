use aiken/builtin.{keccak_256}
use cardano/transaction.{OutputReference, Transaction}
use cocktail/vodka_validity_range.{valid_before}
use mocktail.{complete, invalid_hereafter, mocktail_tx}

pub type EscrowDatum {
  secret: ByteArray,
}

fn check_hash(secret: ByteArray, hash: ByteArray) -> Bool {
  trace keccak_256(secret)
  keccak_256(secret) == hash
}

validator escrow(hash: ByteArray, lock_until: Int) {
  spend(
    datum_opt: Option<EscrowDatum>,
    _redeemer: Data,
    _input: OutputReference,
    tx: Transaction,
  ) {
    expect Some(datum) = datum_opt
    and {
      valid_before(tx.validity_range, lock_until),
      check_hash(datum.secret, hash),
    }
  }

  else(_) {
    fail
  }
}

test hello_world_example() {
  let datum =
    EscrowDatum {
      secret: #"0000000000000000000000000000000000000000000000000000000000000000",
    }
  let placeholder_utxo = OutputReference { transaction_id: "", output_index: 0 }
  let tx =
    mocktail_tx()
      |> invalid_hereafter(True, 1672843961001)
      |> complete()
  escrow.spend(
    #"290decd9548b62a8d60345a988386fc84ba6bc95484008f6362f93160ef3e563",
    2672863961001,
    Some(datum),
    Void,
    placeholder_utxo,
    tx,
  )
}
