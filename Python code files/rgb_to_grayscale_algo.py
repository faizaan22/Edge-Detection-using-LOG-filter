import numpy as np
import cv2
from PIL import Image
import matplotlib.pyplot as plt

cap = cv2.VideoCapture(0)

while True:
    ret, frame = cap.read()
    ###The lightness method averages the most prominent and
    ###least prominent colors: (max(R, G, B) + min(R, G, B)) / 2.
    #img1 = np.array(list(map(lambda x:list(map(lambda y:int((max(y) + min(y))/2), x)), frame)))
    #img1 = img1.astype("uint8")
    ###The average method simply averages the values: (R + G + B) / 3.
    #img2 = np.array(list(map(lambda x:list(map(lambda y:int((sum(y))/3), x)), frame)))
    #img2 = img2.astype("uint8")
    ###The formula for luminosity is 0.21 R + 0.72 G + 0.07 B.
    #img3 = np.array(list(map(lambda x:list(map(lambda y:int((0.21*y[2] + 0.72*y[1] + 0.07*y[0])), x)), frame)))
    #img3 = img3.astype("uint8")
    ### here formula used : 0.299R + 0.587G + 0.114B
    img4 = np.array(list(map(lambda x:list(map(lambda y:int((0.299*y[2] + 0.587*y[1] + 0.114*y[0])), x)), frame)))
    img4 = img4.astype("uint8")

    cv2.imshow("f",img4)
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break


cap.release()
cv2.destroyAllWindows()
