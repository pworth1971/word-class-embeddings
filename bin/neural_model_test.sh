#!/bin/bash

# Get script name using basename with the $0 variable, which contains the script's call path
script_name=$(basename "$0")

# Option to enable logging to a file
LOG_TO_FILE=false

# Log file for recording all outputs (used if LOG_TO_FILE is true)
log_file_path="../log/lc_test3_output_$(date +%Y%m%d%H%M%S).log"

# Print script name and log file path to stdout
echo "Running script: $script_name"
if $LOG_TO_FILE; then
    echo "Logging output to: $log_file_path"
else
    echo "Logging output to: stdout"
fi


#
# command line params
# NB: must be run from /bin directory
#
PY="python ../src/layer_cake.py"
LOG="--log-file ../log/lc_test3.test"
EP="10"


#
# supported neural network architecture
#
nets=(lstm attn cnn)

#
#supported datasets
#
datasets=(\
    "--dataset reuters21578 --pickle-dir ../pickles" \
    "--dataset ohsumed --pickle-dir ../pickles" \
    "--dataset 20newsgroups --pickle-dir ../pickles"
)
#ng_dataset="--dataset 20newsgroups --pickle-dir ../pickles"                     # 20_newsgroups (single label, 20 classes)
#ohm_dataset="--dataset ohsumed --pickle-dir ../pickles"                         # ohsumed (multi-label, 23 classes)
#reut_dataset="--dataset reuters21578 --pickle-dir ../pickles"                   # reuters21578 (multi-label, 115 classes)


# Embedding config params
GLOVE="--pretrained glove --glove-path ../.vector_cache" 
WORD2VEC="--pretrained word2vec --word2vec-path ../.vector_cache/GoogleNews-vectors-negative300.bin"
FASTTEXT="--pretrained fasttext --fasttext-path ../.vector_cache/crawl-300d-2M.vec"
BERT="--pretrained bert --bert-path ../.vector_cache"

# Function to execute a command and handle logging
run_command() {
    local command="$1"
    if $LOG_TO_FILE; then
        echo
        echo "Executing: $command" | tee -a "$log_file_path"
        $command >> "$log_file_path" 2>&1
    else
        echo
        echo "Executing: $command"
        $command
    fi

    if [ $? -ne 0 ]; then
        echo "Error detected during execution." | tee -a "$log_file_path"
        exit 1
    fi
}

for dataset in "${datasets[@]}"; do
    for net in "${nets[@]}"; do
        
        echo
        echo "*********************** Starting runs for $net on $dataset ***********************" | tee -a "$log_file_path"

        for run in {1..10}; do
            echo "------------------------ run $run for $net on $dataset ------------------------" | tee -a "$log_file_path"
        
            # Run base Neural Net config
            run_command "$PY $LOG $dataset --net $net --learnable 200 --hidden 256 --seed $run --nepochs $EP"

            # Iterate over embeddings
            for emb in "$GLOVE" "$WORD2VEC" "$FASTTEXT" "$BERT"; do
                run_command "$PY $LOG $dataset --net $net --hidden 256 $emb --seed $run --nepochs $EP"
                run_command "$PY $LOG $dataset --net $net --hidden 256 $emb --tunable --seed $run --nepochs $EP"
                run_command "$PY $LOG $dataset --net $net --learnable 20 --hidden 256 $emb --tunable --seed $run --droptype learn --nepochs $EP"
                run_command "$PY $LOG $dataset --net $net --hidden 2048 $emb --supervised --seed $run --nepochs $EP"
                run_command "$PY $LOG $dataset --net $net --hidden 1024 $emb --supervised --tunable --seed $run --nepochs $EP"
            done
        done        # for run
    done            # for net
done                # for dataset