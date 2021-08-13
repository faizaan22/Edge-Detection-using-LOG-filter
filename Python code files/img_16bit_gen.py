import numpy as np
import cv2
from PIL import Image

img = Image.open("F:\python_projects\python essentials\edge_detection_project_log\sample_image2_100x100.jpg")
img = np.array(img)
print(img.shape)
#img1 = cv2.cvtColor(img, cv2.COLOR_RGB2GRAY)

cv2.imshow("f", cv2.resize(img, (600,600)))

f = open("img_16bit_100s.txt","w")

############################################
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

#######################################################
    
for e in range(img.shape[0]):
    for l in range(img.shape[1]):
        f.write('"'+gen_floating(img[e,l])+'", ')

f.close()
