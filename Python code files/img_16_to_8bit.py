#floating point 16 to fixed int 8 bit converter

##
# Settings
# go to specific var and right click on it and then export data pattern
# here =>
# address range = all
# file format = MTI
# check om => no adresses
# address radix = anything
# data radix = binary
# line wrap = words per line = 1
# give name to file by browsing
# click on OK

import numpy as np
import cv2

#f = open("G:\intelFPGAlite_workspace\multisim_user\myimg.mem","r")
f = open("G:\intelFPGAlite_workspace\edge_detection_vhdl1\modelsim_work\mymem1.mem","r")

g = f.readlines()

g = g[3:]
bias = 15

(x,y) = (100,100)
l=[]

for e1 in range(x):
    l.append([])
    for e2 in range(y):
        a = g[(e1*y) + e2]
        sign = int(a[0])
        #mantissa = 1 + sum([int(i)*(2**j) for (i,j) in zip(a[6:16], range(-1,-11,-1))])
        #b = (2**(int(a[1:6], base=2)-bias))*mantissa
        b = (2**(int(a[1:6], base=2)-bias))
        l[e1].append(((-1)**sign)*b)

img = np.array(l)
img = img.astype("uint8")
img1 = cv2.resize(img, (600,600))
cv2.imshow("f",img1)
f.close()
