import numpy as np

f1 = open("test_mac_m1.txt","w")
f2 = open("test_mac_m2.txt","w")

row, col = 100,100
m,n = 5,5
m_cap, n_cap = m//2, n//2

m1 = np.zeros((row + (2*m_cap), col + (2*n_cap)))
m2 = np.random.rand(m,n).astype("float16")
m1[:m,:n] = (np.random.rand(m,n)*20)
m1 = m1.astype("uint8")

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

for a in range(m1.shape[0]):
    for b in range(m1.shape[1]):
        f1.write('"' + format(m1[a,b], "08b") + '", ')

for a in range(m2.shape[0]):
    for b in range(m2.shape[1]):
        f2.write('"' + gen_floating(m2[a,b]) + '", ')

a = np.sum(m1[:m,:n]*m2)
print(a)
a = gen_floating(a)
print(a)
sign = int(a[0])
b = (2**(int(a[1:6], base=2)-15))
c = ((-1)**sign)*b
d = format(np.array(c).astype("uint8"), "08b")
print(c,d)

f1.close()
f2.close()
