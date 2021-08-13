import numpy as np
import cv2
from PIL import Image
import matplotlib.pyplot as plt
from scipy import signal

def corr(img, mask):
    row,col = img.shape
    m,n = mask.shape
    new = np.zeros((row+m-1, col+n-1))
    n = n//2
    m = m//2
    filtered_img = np.zeros(img.shape)
    new[m:new.shape[0]-m, n:new.shape[1]-n] = img
    for i in range(m, new.shape[0]-m):
        for j in range(n, new.shape[1]-n):
            temp=new[i-m:i+m+1,j-m:j+m+1]
            result = temp*mask
            filtered_img[i-m,j-n]=result.sum()

    return filtered_img

def gaussian(m, sigma):
    gaussian = np.zeros((m,m))
    m = m//2
    for x in range(-m, m+1):
            for y in range(-m, m+1):
                    #x1 = np.sqrt(2*np.pi) * sigma
                    x2 = np.exp(-(x**2 + y**2)/(2*(sigma**2)))
                    #gaussian[x+m, y+m] = (1/x1)*x2
                    gaussian[x+m, y+m] = x2
                    #gaussian = gaussian/np.sum(gaussian)
    return gaussian

def log_filter(gaussian, m, sigma):
    log = np.zeros((m,m))
    mag = np.sum(gaussian)
    m = m//2
    for x in range(-m, m+1):
        for y in range(-m, m+1):
            x1 = (x**2 + y**2 - (2*(sigma**2))) * gaussian[x+m, y+m]
            x2 = (sigma**4) * mag
            log[x+m, y+m] = x1*(1/x2)
    return log

pos_laplacian_operator = np.array([[0, 1, 0],
                                   [1, -4, 1],
                                   [0, 1, 0]])

neg_laplacian_operator = np.array([[0, -1, 0],
                                   [-1, 4, -1],
                                   [0, -1, 0]])

def log_filter1(gaussian, what='pos'):
    if what=='pos':
        return signal.convolve2d(pos_laplacian_operator, gaussian)
    elif what=='neg':
        return signal.convolve2d(neg_laplacian_operator, gaussian)

img = Image.open("sample_image.jpg")
img = np.array(img)
img1 = cv2.cvtColor(img, cv2.COLOR_RGB2GRAY)
cv2.imshow("f", img1)
#gaussian
g = gaussian(5,20)
g = g/np.sum(g)
img2 = signal.convolve2d(img1, g)
#img2 = corr(img1, gaussian(5,10))
img3 = np.array([np.array(list(map(int, x)), dtype='uint8') for x in img2], dtype='uint8')
cv2.imshow("laplacian", img3)

#log
#g = gaussian(5,3)
#log = log_filter(g, 5, 2)
log = log_filter1(g, 'neg')
img4 = signal.convolve2d(img1, log)
#img4 = signal.convolve2d(neg_laplacian_operator, img1)
#img4 = corr(img1, log)
img5 = np.array([np.array(list(map(int, x)), dtype='uint8') for x in img4], dtype='uint8')
cv2.imshow("LOG", img5)
