# Create a raw transaction that can be spent in 2 weeks time, assuming the current block is 25

# Amount of 20,000,000 satoshis to this address: 2MvLcssW49n9atmksjwg2ZCMsEMsoj3pzUP 
# Use the UTXOs from the transaction below
# transaction="01000000000101c8b0928edebbec5e698d5f86d0474595d9f6a5b2e4e3772cd9d1005f23bdef772500000000ffffffff0276b4fa0000000000160014f848fe5267491a8a5d32423de4b0a24d1065c6030e9c6e000000000016001434d14a23d2ba08d3e3edee9172f0c97f046266fb0247304402205fee57960883f6d69acf283192785f1147a3e11b97cf01a210cf7e9916500c040220483de1c51af5027440565caead6c1064bac92cb477b536e060f004c733c45128012102d12b6b907c5a1ef025d0924a29e354f6d7b1b11b5a7ddff94710d6f0042f3da800000000"
#!/bin/bash

# Raw transaction hex (source transaction containing UTXOs i want to spend)
source_tx_hex="01000000000101c8b0928edebbec5e698d5f86d0474595d9f6a5b2e4e3772cd9d1005f23bdef772500000000ffffffff0276b4fa0000000000160014f848fe5267491a8a5d32423de4b0a24d1065c6030e9c6e000000000016001434d14a23d2ba08d3e3edee9172f0c97f046266fb0247304402205fee57960883f6d69acf283192785f1147a3e11b97cf01a210cf7e9916500c040220483de1c51af5027440565caead6c1064bac92cb477b536e060f004c733c45128012102d12b6b907c5a1ef025d0924a29e354f6d7b1b11b5a7ddff94710d6f0042f3da800000000"

# Decoding the raw transaction to extract its TXID
decoded_txid=$(bitcoin-cli -regtest -named decoderawtransaction hexstring=$source_tx_hex | jq -r '.txid')

# Extracting output indexes (vout) for the UTXOs i want to spend
first_utxo_index=$(bitcoin-cli -regtest -named decoderawtransaction hexstring=$source_tx_hex | jq -r '.vout[0].n')
second_utxo_index=$(bitcoin-cli -regtest -named decoderawtransaction hexstring=$source_tx_hex | jq -r '.vout[1].n')

# Destination address (where the 20,000,000 sats = 0.2 BTC will be sent)
destination_address="2MvLcssW49n9atmksjwg2ZCMsEMsoj3pzUP"

# Locktime set so transaction is only valid after a certain block height (time-lock)
# Given current block ~25, locktime=2041 enforces delay (~2 weeks in regtest simulation context)
tx_locktime=2041

# Create a new raw transaction:
# - Uses both UTXOs as inputs
# - Sets sequence < max to enable locktime
# - Sends 0.2 BTC to the recipient
# - Applies the locktime constraint
created_raw_tx=$(bitcoin-cli -regtest -named createrawtransaction \
  inputs='''[
    { "txid": "'$decoded_txid'", "vout": '$first_utxo_index', "sequence": 4294967293 },
    { "txid": "'$decoded_txid'", "vout": '$second_utxo_index', "sequence": 4294967293 }
  ]''' \
  outputs='''{ "'$destination_address'": 0.20000000 }''' \
  locktime=$tx_locktime)

# Output the final raw transaction hex (unsigned)
echo $created_raw_tx