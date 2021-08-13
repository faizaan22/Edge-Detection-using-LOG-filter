import numpy as np
import cv2
from PIL import Image

img = Image.open("F:\python_projects\python essentials\edge_detection_project_log\sample_image2_100x100.jpg")
img = np.array(img)
print(img.shape)
#img1 = cv2.cvtColor(img, cv2.COLOR_RGB2GRAY)

cv2.imshow("f", cv2.resize(img, (600,600)))

f = open("img_8bit_100s.txt","w")

for e in range(img.shape[0]):
    for l in range(img.shape[1]):
        f.write('"'+format(img[e,l], "08b")+'", ')

f.close()
