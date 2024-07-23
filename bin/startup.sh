#!/bin/bash

conda init
conda create -n python38 python=3.8
conda activate python3.8
pip install torch torchtext scikit-learn fasttext transformers simpletransformers rdflib gensim fasttext matplotlib tabulate scipy datetime numpy pandas 

apt update
apt install zip
