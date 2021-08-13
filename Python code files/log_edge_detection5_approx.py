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

def my_conv2d(img, mask):
    row,col = img.shape
    m,n = mask.shape
    m_cap, n_cap = m//2, n//2
    canvas = np.zeros((row + 2*m_cap, col + 2*n_cap))
    filtered_img = np.zeros(img.shape)
    canvas[m_cap:row+m_cap, n_cap:col+n_cap] = img
    ##for repition
    #np.array(([[1,2]*3] + [[3,4]*3])*3)
    #np.array(([[0,1,0]*n] + [[1,-4,1]*n] + [[0,1,0]*n])*m)
    for i in range(0,row):
        for j in range(0, col):
            tmp = canvas[i:m+i, j:n+j] * mask
            filtered_img[i,j] = tmp.sum()
            
    return filtered_img

def exp(x):
    #return (1 + x + ((x**2)/2) + ((x**3)/6))
    return (1 + x + ((x**2)/2))

def gaussian(m, sigma):
    gaussian = np.zeros((m,m))
    m = m//2
    for x in range(-m, m+1):
            for y in range(-m, m+1):
                    #x1 = np.sqrt(2*np.pi) * sigma
                    #x2 = np.exp(-(x**2 + y**2)/(2*(sigma**2)))
                    x2 = exp(-(x**2 + y**2)/(2*(sigma**2)))
                    #gaussian[x+m, y+m] = (1/x1)*x2
                    gaussian[x+m, y+m] = x2
                    #gaussian = gaussian/np.sum(gaussian)
                    gaussian = gaussian.astype('float16')
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

cap = cv2.VideoCapture(0)
#5,15
#5,7
g = gaussian(5,30)
g = g/np.sum(g)
log = log_filter1(g, 'pos')
#log = log.astype('float32')
#print(log, log.dtype)
#log = log_filter(gaussian(5,14), 5, 14)

while True:
    ret, frame = cap.read()
    img1 = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    #img2 = signal.convolve2d(img1, g)
    #img3 = np.array([np.array(list(map(int, x)), dtype='uint8') for x in img2], dtype='uint8')
    #cv2.imshow("laplacian", img3)
    img4 = signal.convolve2d(img1, log, mode='same')
    #img4 = corr(img1, log)
    #img4 = my_conv2d(img1, log)
    #print(img4,img4.shape, img4.dtype)
    img4 = img4.astype('float16')
    img5 = np.array([np.array(list(map(int, x)), dtype='uint8') for x in img4], dtype='uint8')
    #print(img5)
    cv2.imshow("LOG", img5)

    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()
