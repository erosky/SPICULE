# T_L = lifting condensation level temperature (attained if lifted adiabatically to its condensation level.)
# T_D = dew point temperature
# T_K = absolute temperature

import numpy as np
import matplotlib.pyplot as plt


# convert C to K
def CtoK(C):
	return C+273.15
	
def KtoC(K):
	return K-273.15
	
def sec2UTC(seconds):
	utc_string=time.strftime('%H:%M:%S', time.gmtime(seconds))
	return utc_string

f = open("test_18-50.txt", "r")

inputraw=f.read()
lines = inputraw.split('\n')
	
data_array = []
for line in lines:
	data_entry = []
	columns = line.split('\t')
	data_array.append(columns)
	
np_array = np.array(data_array, dtype=object)

time = []
utc = []
DPXC = []
ATX = []
LCL = []

for item in np_array:
	if (len(item)>1):
		time.append(float(item[0]))
		utc.append(str(item[1]))
		DPXC.append(float(item[2]))
		ATX.append(float(item[3]))


option = input("write to file (y/n)?: ")
if (option=='y'):
	output = input("Enter output filename (including extension): ")
	o = open(output, "w")

for i,T in enumerate(ATX):
	T_D = CtoK(DPXC[i])
	T_K = CtoK(T)
	T_L = 1/((1/(T_D-56))+(np.log(T_K/T_D)/800)) + 56
	LCL.append(KtoC(T_L))
	
	if (option=='y'):
		o.write(str(time[i]) + '\t' + str(T) + '\t' + str(DPXC[i]) + '\t' + str(KtoC(T_L)) + '\n')
	
if (option=='y'): 
	o.close()


plt.title('Lifting condensation level')
plt.xlabel('Time (seconds)')
plt.ylabel(r'Temperature C')


plt.plot(time, ATX, label=r'Temperature')
plt.plot(time, DPXC, label=r'Dew point')
plt.plot(time, LCL, label=r'lifting condensation level')

plt.ylim(20, -30)
plt.legend(loc='lower right')
plt.grid(color='#d4d4d4', linestyle='--', linewidth=1)

plt.tight_layout()
plt.savefig('Tclc_plot_xvl.png', dpi=300)



