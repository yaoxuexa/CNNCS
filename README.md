# Cell Detection with Deep Convolutional Neural Network and Compressed Sensing (CNNCS)
This repository contains the code for CNNCS introduced in the paper <a href="https://arxiv.org/abs/1708.03307">"Cell Detection with Deep Convolutional Neural Network and Compressed Sensing"</a> (now submitted to IEEE Trans. on Image Processing) by Yao Xue, Nilanjan Ray, Judith Hugh, Gilbert Bigras

# Introduction
Cell detection/localization from microscopy images is a significant task in medical applications. Since the output space is sparse for the cell detection problem (only a few pixel locations are cell centers), we employ compressed sensing (CS)-based output encoding. Using random projections, CS converts the sparse, output pixel space into dense and compressed vectors. As a regressor, we use deep convolutional neural net (CNN) to predict the compressed vectors. Then applying a L1-norm recovery algorithm to the predicted vectors, we recover sparse cell locations in the output pixel space. The proposed detection framework consists of three components: (1) cell location encoding phase using random projections, (2) a CNN-based regression model to capture the relationship between a cell microscopy image and the encoded signal, and (3) decoding phase for detection.

<img src="https://user-images.githubusercontent.com/31593901/30071781-52b3df92-9225-11e7-96f2-fc12ce68bbc0.jpg" width="350" align="center">

# Setup

Download the <a href="http://amida13.isi.uu.nl/">AMIDA-13</a> dataset.

Download the sparsity-regularized minimization solver MATLAB toolbox: <a href="http://ttic.uchicago.edu/~ryotat/softwares/dal/">DAL</a>.

Install the deep learning library: <a href="https://github.com/apache/incubator-mxnet">Mxnet</a>.
See the instructions <a href="https://mxnet.incubator.apache.org/get_started/ubuntu_setup.html">here</a> for a step-by-step guide for installation on Ubuntu.

# Usage

To run the proposed CNNCS method, you can clone this repo and run the demo code "CNNCS_test.m", which uses our pre-trained CNN-based regression model and calls relavant functions to complete the decoding, sparse recovery and other related processings.

For training the whole CNNCS framework on your own data, the major procedures are as follows:

1. Run Create_OA.m to create observation axes based on which cell coordinates are encoded. 

2. Run CNNCS_Encode_trainset.m to generate training exmples list from downloaded dataset and encode the ground-truth cell coordinates to label vectors. You can also perform data augmentation using this .m file to supplement your training set, if necessary.

3. cd to the home of Mxnet, generate the required .bin file from your training data list and label vectors by command:
./bin/im2rec /path-to-training-data-list.txt /local /path-of-bin-file-saved-to label_width=3090 quality=100

4. Start training the neural network based regressor by calling the "Train_NN_regressor.py":
python /path-to-"Train_NN_regressor.py" --network resnet-28-small --data-dir /path-to-bin-file --gpus 0,1 --batch-size 40 --lr 0.01 --lr-factor 0.1 --lr-factor-epoch 10 --model-prefix /path-of-model-saved-to --num-epochs 30 2>&1 | tee /path-to-log.txt
