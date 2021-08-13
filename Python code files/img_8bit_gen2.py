import numpy as np
import cv2

from tkinter import *
from tkinter import filedialog
from PIL import Image

Tk().withdraw()

filename = filedialog.askopenfilename()

#img = Image.open("F:\python_projects\python essentials\edge_detection_project_log\sample_image3.jpeg")
img = Image.open(filename)
img = np.array(img)
cv2.imshow("f",cv2.cvtColor(img, cv2.COLOR_RGB2BGR))
print(img.shape)
img = cv2.cvtColor(img, cv2.COLOR_RGB2GRAY)
img = cv2.resize(img, (200,200))
cv2.imshow("f1",img)
#img1 = cv2.cvtColor(img, cv2.COLOR_RGB2GRAY)

#cv2.imshow("f", cv2.resize(img, (600,600)))

f = open("img_8b_200s.mif","w")

mylist=[]

for e in range(img.shape[0]):
    for l in range(img.shape[1]):
        #f.writeline(format(img[e,l], "08b"))
        mylist.append(format(img[e,l], "08b"))

f.write('\n'.join(mylist))

f.close()
