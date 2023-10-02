from PIL import Image
import numpy as np
import os

#read image
if os.path.exists('./image.jpg'):
    img = Image.open('./image.jpg')
elif os.path.exists('./image.png'):
    img = Image.open('./image.png')
else:
    print('Image not found!')

#Convert RGB image to grayscale.
img = img.convert('L')
img.save('image_grayscale.jpg')

#Resize the grayscale image into 64x64
img = img.resize((64,64))
img.save('image_resized.jpg')

#output the resized image as img.dat
data = np.asarray(img)
data = np.reshape(data, (4096))
binary_repr_v = np.vectorize(np.binary_repr)
bidata = binary_repr_v(data, 9)
f = open('img.dat','w')
for i, pixel in enumerate(bidata):
    tmpStr = pixel+'0000'+' //data '+str(i)+': '+str(data[i])+'.0'+'\n'
    f.write(tmpStr)
img.close()
f.close()

#Implement the algorithm of layer 0 
sourceFile = open('img.dat','r')
targetFile = open('layer0_golden.dat','w')

imgPadding = np.zeros((68, 68))
#print(imgPadding)
lines = sourceFile.readlines()
i=2
j=2
#insert central data
for idx,line in enumerate(lines):
    #print(idx,int(line[line.find(':')+1:-3]))
    imgPadding[i,j]=float(line[line.find(':')+2:-1])
    j=j+1
    if(j==66):
        i=i+1
        j=2
#print(imgPadding[:10,:10])

#set padding data
imgPadding[:3,:3] = imgPadding[2,2]
imgPadding[:3,65:] = imgPadding[2,65]
imgPadding[65:,:3] = imgPadding[65,2]
imgPadding[65:,65:] = imgPadding[65,65]

imgPadding[:2,3:65] = imgPadding[2,3:65]
imgPadding[66:,3:65] = imgPadding[65,3:65]
imgPadding[3:65,66] = imgPadding[3:65,65]
imgPadding[3:65,67] = imgPadding[3:65,65]
imgPadding[3:65,0] = imgPadding[3:65,2]
imgPadding[3:65,1] = imgPadding[3:65,2]
print(imgPadding[:10,:10])

#Atrous Convolution
imgLayer0=np.zeros((64,64))
kernel = np.array([[-0.0625,-0.125,-0.0625],[-0.25,1,-0.25],[-0.0625,-0.125,-0.0625]])
bias = -0.75
for i in range(2,66,1):
    for j in range(2,66,1):
        tmpMatrix = np.array([[imgPadding[i-2][j-2],imgPadding[i-2][j],imgPadding[i-2][j+2]],
                              [imgPadding[i][j-2],imgPadding[i][j],imgPadding[i][j+2]],
                              [imgPadding[i+2][j-2],imgPadding[i+2][j],imgPadding[i+2][j+2]]])
        imgLayer0[i-2][j-2]=np.sum(tmpMatrix*kernel)+bias

        #ReLU
        if imgLayer0[i-2][j-2] >= 0:
            imgLayer0[i-2][j-2] = imgLayer0[i-2][j-2]
        else:
            imgLayer0[i-2][j-2] = 0
#print(imgLayer0)

#max-pooling
imgLayer1=np.zeros((32,32))
for i in range(0,32,1):
    for j in range(0,32,1):
        imgLayer1[i][j] = np.max((imgLayer0[i*2][j*2],imgLayer0[i*2+1][j*2],
                                  imgLayer0[i*2][j*2+1],imgLayer0[i*2+1][j*2+1]))
        #ceiling
        imgLayer1[i][j] = np.ceil(imgLayer1[i][j])
#print(imgLayer1)

#output the layer0 as layer0_golden.dat
#integer
dataOrigin = (np.reshape(imgLayer0, (4096)))
data = (np.reshape(np.floor(imgLayer0), (4096))).astype('int')
binary_repr_v = np.vectorize(np.binary_repr)
bidata = binary_repr_v(data, 9)
#decimal
dataDec = (np.reshape(imgLayer0%1/0.0625, (4096))).astype('int')
binary_repr_v = np.vectorize(np.binary_repr)
bidataDec = binary_repr_v(dataDec, 4)
f = open('layer0_golden.dat','w')
for i in range(len(bidata)):
    tmpStr = bidata[i]+bidataDec[i]+' //data '+str(i)+': '+str(dataOrigin[i])+'\n'
    f.write(tmpStr)
f.close()

#output the layer1 as layer1_golden.dat
data = np.reshape(imgLayer1, (1024)).astype('int')
binary_repr_v = np.vectorize(np.binary_repr)
bidata = binary_repr_v(data, 9)
f = open('layer1_golden.dat','w')
for i, pixel in enumerate(bidata):
    tmpStr = pixel+'0000'+' //data '+str(i)+': '+str(data[i])+'.0'+'\n'
    f.write(tmpStr)
img.close()
f.close()