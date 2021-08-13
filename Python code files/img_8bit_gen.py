import numpy as np
import cv2

img1 = []
cap = cv2.VideoCapture(0)

while True:
    ret, frame = cap.read()
    img1 = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    img1 = cv2.resize(img1, (100,100), interpolation=cv2.INTER_NEAREST)

    cv2.imshow("img", img1)

    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

f = open("img_8bit.txt","w")

for e in range(img1.shape[0]):
    for l in range(img1.shape[1]):
        f.write(format(img1[e,l], "08b") + '\n')

f.close()
cap.release()
cv2.destroyAllWindows()
