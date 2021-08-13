import numpy as np
import cv2
from PIL import Image
import matplotlib.pyplot as plt
from scipy import signal

#####################################################################

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

def gaussian(m, sigma):
    gaussian = np.zeros((m,m))
    m = m//2
    for x in range(-m, m+1):
            for y in range(-m, m+1):
                    #x1 = np.sqrt(2*np.pi) * sigma
                    #x2 = np.exp(-(x**2 + y**2)/(2*(sigma**2)))
                    x2 = np.exp(-(x**2 + y**2)/(2*(sigma**2)))
                    #gaussian[x+m, y+m] = (1/x1)*x2
                    gaussian[x+m, y+m] = x2
                    #gaussian = gaussian/np.sum(gaussian)
                    gaussian = gaussian.astype('float16')
    return gaussian

def log_filter2(m, sigma):
    logf = np.zeros((m,m))
    m = m//2
    for x in range(-m, m+1):
            for y in range(-m, m+1):
                    x1 = (-1)/(np.pi*(sigma**4))
                    x2 = 1 - ((x**2 + y**2)/(2*(sigma**2)))
                    x3 = np.exp(-(x**2 + y**2)/(2*(sigma**2)))
                    #gaussian[x+m, y+m] = (1/x1)*x2
                    logf[x+m, y+m] = x1*x2*x3
                    #gaussian = gaussian/np.sum(gaussian)
                    logf = logf.astype('float16')
    return logf

pos_laplacian_operator = np.array([[0, 1, 0],
                                   [1, -4, 1],
                                   [0, 1, 0]])

neg_laplacian_operator = np.array([[0, -1, 0],
                                   [-1, 4, -1],
                                   [0, -1, 0]])

sobel_pos_laplacian_operator = np.array([[-1, -1, -1],
                                        [-1, 8, -1],
                                        [-1, -1, -1]])

sobel_neg_laplacian_operator = np.array([[1, 1, 1],
                                        [1, -8, 1],
                                        [1, 1, 1]])

def log_filter1(gaussian, what='pos'):
    if what=='pos':
        return signal.convolve2d(pos_laplacian_operator, gaussian)
    elif what=='neg':
        return signal.convolve2d(neg_laplacian_operator, gaussian)
    elif what=='spos':
        return signal.convolve2d(sobel_pos_laplacian_operator, gaussian)
    elif what=='sneg':
        return signal.convolve2d(sobel_neg_laplacian_operator, gaussian)

def frac_bin(f):
	l=[]
	no = f
	for e in range(32):
		l.append(str(int(no*2)))
		no = no*2 - int(no*2)
	return ''.join(l)

def gen_floating(n):
	n=n
	if(n==0):
		return ''.join(['0']*16)
	sign="0"
	if(str(n)[0] == "-"):
		sign = "1"
		n=n*-1
	intg = int(n)
	floatg = n - intg
	tmp = bin(intg)[2:] + "x" + frac_bin(floatg)
	#print(tmp)
	pos1 = tmp.find("1")
	posx = tmp.find("x")
	shift=0
	if (posx>pos1):
		shift = posx-pos1-1
	else:
		shift = posx-pos1
	shift = shift+15
	#print(shift)
	frac = tmp[pos1+1:].replace("x","")
	return sign + format(shift, "05b") + format(int(frac[:10],base=2)+int(frac[10]), "010b")

#####################################################################


g = gaussian(5,30)
g = g/np.sum(g)
#g = g/g.max()
log = log_filter1(g, 'pos')
"""
log = np.array([[0, 0, -1, 0, 0],
                [0, -1, -2, -1, 0],
                [-1, -2, 16, -2, -1],
                [0, -1, -2, -1, 0],
                [0, 0, -1, 0, 0]])
"""
#log = log_filter2(7, 1.4)
#log = log/np.sum(log)
#log = (log/log.max()).astype("int32")

#log = #write here in this format => np.array([[...],[...],...]) #

#img = Image.open("F:\python_projects\python essentials\edge_detection_project_log\sample_image2_100x100.jpg")
img = Image.open("F:\python_projects\python essentials\edge_detection_project_log\sample_image3.jpeg")
#img = Image.open("sample_image2_100x100.jpg")
img = np.array(img)

img = cv2.cvtColor(img, cv2.COLOR_RGB2GRAY)

imgc = img
##
"""
blur = cv2.GaussianBlur(img,(3,3),0)
laplacian = cv2.Laplacian(blur,cv2.CV_64F)
laplacian1 = laplacian/laplacian.max()
cv2.imshow("a", laplacian1)
"""
##

#####
"""bad
blur = cv2.GaussianBlur(np.eye(7),(3,3),0)
laplacian = cv2.Laplacian(blur,cv2.CV_64F)
laplacian1 = laplacian/laplacian.max()
img5 = my_conv2d(img, laplacian1)
cv2.imshow("a", img5.astype("uint8"))
"""
#####

img = cv2.resize(img, (100,100), cv2.INTER_NEAREST)

print(img.shape)

##
"""
blur = cv2.GaussianBlur(img,(3,3),0)
laplacian = cv2.Laplacian(blur,cv2.CV_64F)
laplacian1 = laplacian/laplacian.max()
cv2.imshow('a7',cv2.resize(laplacian1, (600,600)))
"""
##

img1 = my_conv2d(img, log)
print(img1.shape, img1.dtype)
img2 = img1.astype("float16")

img3 = np.zeros(img2.shape)

for i in range(img2.shape[0]):
    for j in range(img2.shape[1]):
        float_no = gen_floating(img2[i,j])
        sign = int(float_no[0])
        b = (2**(int(float_no[1:6], base=2)-15))
        img3[i,j] = ((-1)**sign)*b

img31 = img3.astype("int32")
print(img2, img2.dtype)
print(img31, img31.dtype)
img3 = img31.astype("uint8")

cv2.imshow("f1", cv2.resize(img, (600,600)))
cv2.imshow("f2", cv2.resize(img2.astype("uint8"), (600,600)))
cv2.imshow("f3", cv2.resize(img3, (600,600)))
cv2.imwrite("sample_img3_ed.jpg",cv2.resize(img3, (600,600)))

