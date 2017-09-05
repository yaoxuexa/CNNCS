# Cell Detection with Deep Convolutional Neural Network and Compressed Sensing (CNNCS)
This repository contains the code for CNNCS introduced in the paper <a href="https://arxiv.org/abs/1708.03307">"Cell Detection with Deep Convolutional Neural Network and Compressed Sensing"</a> (now submitted to IEEE Trans. on Image Processing) by Yao Xue, Nilanjan Ray, Judith Hugh, Gilbert Bigras

# Introduction
The proposed detection framework consists of three components: (1) cell location encoding phase using random projections, (2) a CNN-based regression model to capture the relationship between a cell microscopy image and the encoded signal, and (3) decoding phase for detection.

<img src="https://user-images.githubusercontent.com/31593901/30071781-52b3df92-9225-11e7-96f2-fc12ce68bbc0.jpg" width="600">

During training, the ground truth location of cells is indicated by a pixel-wise binary annotation map $B$. We propose a cell location encoding scheme, which converts cell location from pixel space representation $B$ to compressed signal representation $y$. Probably in the simplest form, this encoding may consist of reshaping the sparse matrix $B$ into a sparse vector $f$ by row or column major fashion. Then, $f$ is multiplied by a sensing matrix (usually, a random Gaussian matrix) to form a compressed and encoded vector $y$. The encoding scheme can also be more sophisticated as discussed later. Then, each training pair, consisting of a cell microscopy image and the signal $y$, trains a CNN to work as a multi-label regression model. We employ the Euclidean loss function during training, because it is often more suitable for regression. Image rotations may be performed on the training sets for the purpose of data augmentation as well as making the system more robust to rotations. During testing, the trained network is responsible for outputting an estimated signal $\hat{y}$ for each test image. After that, a decoding scheme is designed to predict the cell location by performing $L_1$ minimization recovery on the estimated signal $\hat{y}$, with the known sensing matrix.

# Setup

Download the AMIDA-13 datasets http://amida13.isi.uu.nl/
Download the DAL http://ttic.uchicago.edu/~ryotat/softwares/dal/
Install Mxnet https://github.com/apache/incubator-mxnet

Install Mxnet and required dependencies like cuDNN. See the instructions here for a step-by-step guide.

# Usage:

Run Create_OA.m to create observation axes based on which cell coordinates are encoded. 

Run CNNCS_Encode_trainset.m to generate training exmples list from downloaded dataset and encode the ground-truth cell coordinates to label vectors.

Then, cd to the home of Mxnet, generate the required .bin file from your training data list and label vectors by command:
./bin/im2rec /path-to-training-data-list.txt /local /path-of-bin-file-saved-to label_width= quality=100

Start training the neural network based regressor by calling the "Train_NN_regressor.py":
python /path-to-"Train_NN_regressor.py" --network resnet-28-small --data-dir /path-to-bin-file --gpus 0,1 --batch-size 40 --lr 0.01 --lr-factor 0.1 --lr-factor-epoch 10 --model-prefix /path-of-model-saved-to --num-epochs 30 2>&1 | tee /path-to-log.txt
