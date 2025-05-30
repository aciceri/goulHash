use cardano/transaction.{OutputReference, Transaction}

pub type EscrowDatum {
  secret: ByteArray,
}

fn check_hash(_b: ByteArray) -> Bool {
  // TODO
  True
}

validator escrow {
  spend(
    datum_opt: Option<EscrowDatum>,
    _redeemer: Data,
    _input: OutputReference,
    _tx: Transaction,
  ) {
    expect Some(datum) = datum_opt
    check_hash(datum.secret)
  }

  else(_) {
    fail
  }
}
