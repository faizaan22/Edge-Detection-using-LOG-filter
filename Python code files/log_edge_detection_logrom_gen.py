import numpy as np
from scipy import signal

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
                    #gaussian = gaussian.astype('float16')
    return gaussian

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
    
g = gaussian(5,30)
g = g/np.sum(g)
log = log_filter1(g, 'pos')
log = log.astype("float16")
print(log)
f = open("log_rom.txt",'w')

i,j = log.shape

for a in range(i):
    for b in range(j):
        f.write('"' + gen_floating(log[a,b]) + '", ')


f.close()
