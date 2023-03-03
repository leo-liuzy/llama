# Copyright (c) Meta Platforms, Inc. and affiliates.
# This software may be used and distributed according to the terms of the GNU General Public License version 3.

PRESIGNED_URL="https://dobf1k6cxlizq.cloudfront.net/*?Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9kb2JmMWs2Y3hsaXpxLmNsb3VkZnJvbnQubmV0LyoiLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE2NzgzNzE3MTJ9fX1dfQ__&Signature=fzd5Jprfuym8h~CbDu6U5Y7GTec0o57H7n5rsLEvURn1gNAa4cOvzdhlNPTUfvl13riWb6XbR-vt~lpWB1snwk8Lc8S6THcWbH~-OrzaLiBDpa7ZVGgmQLmrX4i45fFKM26coaljWoXEV15HxJfs0N4DTXYZS9IIUcFmhjwHTcc7UIgsYzDFBKUaGj1r0MILHbcDCm~9HOcbzsuA57shB2gd7rb6qX01nryMeuBtBZb7znpCpEV~w3Mb8j3-CnWasOJUwLl4YhYjvi~5CI0KH5kY6uMv24qr3JmyatEbXncFAp4y0GXZf4vlqzuCAZXwQRUuCFKyV2O10HdCBhGeMQ__&Key-Pair-Id=K231VYXPC1TA1R"             # replace with presigned url from email
MODEL_SIZE="7"  # edit this list with the model sizes you wish to download
# MODEL_SIZE="7B 13B 30B 65B"  # edit this list with the model sizes you wish to download
TARGET_FOLDER="released_checkpoints"             # where all files should end up

declare -A N_SHARD_DICT

N_SHARD_DICT["7"]="0"
N_SHARD_DICT["13"]="1"
N_SHARD_DICT["30"]="3"
N_SHARD_DICT["65"]="7"

echo "Downloading tokenizer"
wget ${PRESIGNED_URL/'*'/"tokenizer.model"} -O ${TARGET_FOLDER}"/tokenizer.model"
wget ${PRESIGNED_URL/'*'/"tokenizer_checklist.chk"} -O ${TARGET_FOLDER}"/tokenizer_checklist.chk"

(cd ${TARGET_FOLDER} && md5 tokenizer_checklist.chk)

for i in ${MODEL_SIZE//,/ }
do
    echo "Downloading ${i}B"
    mkdir -p ${TARGET_FOLDER}"/${i}B"
    for s in $(seq -f "0%g" 0 ${N_SHARD_DICT[$i]})
    do
        echo "Downloading shard ${s}"
        wget ${PRESIGNED_URL/'*'/"${i}B/consolidated.${s}.pth"} -O ${TARGET_FOLDER}"/${i}B/consolidated.${s}.pth"
    done
    wget ${PRESIGNED_URL/'*'/"${i}B/params.json"} -O ${TARGET_FOLDER}"/${i}B/params.json"
    wget ${PRESIGNED_URL/'*'/"${i}B/checklist.chk"} -O ${TARGET_FOLDER}"/${i}B/checklist.chk"
    echo "Checking checksums"
    (cd ${TARGET_FOLDER}"/${i}B" && md5 checklist.chk)
done