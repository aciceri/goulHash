let
  aciceri = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIm9Sl/I+5G4g4f6iE4oCUJteP58v+wMIew9ZuLB+Gea";
in
{
  "blockfrost-api-key.age".publicKeys = [ aciceri ];
  "ethereum-wallet-private-key.age".publicKeys = [ aciceri ];
}
