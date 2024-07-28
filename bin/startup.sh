#!/bin/bash

conda init
conda create -n python38 python=3.8
conda activate python38
pip install scikit-learn fasttext transformers simpletransformers rdflib gensim fasttext matplotlib tabulate scipy datetime numpy pandas 
conda install -c pytorch torchtext
aptapt update
apt install zip
