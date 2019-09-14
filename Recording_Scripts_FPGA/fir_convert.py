from scipy.io.wavfile import write
import numpy as np
import matplotlib.pyplot as plt
from scipy import signal
from scipy.io import wavfile

def volumeControl(x):
    numerator = x / 20
    return 10**numerator

####################################################################################################
print("Converting Raw microphone data to WAV files...")
F = open("MIC_1_LEFT.dat", "r")

data_l = []

for line in F:
    data_l.append(int(line));

F.close()

data_l = np.asarray(data_l, dtype=np.int16)

F = open("MIC_1_RIGHT.dat", "r")

data_r = []

for line in F:
    data_r.append(int(line));

F.close()

data_r = np.asarray(data_r, dtype=np.int16)

#print(data_l.shape)
#print(data_r.shape)

data = np.stack((data_l, data_r))
data = np.transpose(data)
#print(data.shape)

print("Writing mic_pair_1.wav")
write('mic_pair_1.wav', 48000, data)

####################################################################################################

F = open("MIC_2_LEFT.dat", "r")

data_l = []

for line in F:
    data_l.append(int(line));

F.close()

data_l = np.asarray(data_l, dtype=np.int16)

F = open("MIC_2_RIGHT.dat", "r")

data_r = []

for line in F:
    data_r.append(int(line));

F.close()

data_r = np.asarray(data_r, dtype=np.int16)

#print(data_l.shape)
#print(data_r.shape)

data = np.stack((data_l, data_r))
data = np.transpose(data)
#print(data.shape)

print("Writing mic_pair_2.wav")
write('mic_pair_2.wav', 48000, data)

####################################################################################################

F = open("MIC_3_LEFT.dat", "r")

data_l = []

for line in F:
    data_l.append(int(line));

F.close()

data_l = np.asarray(data_l, dtype=np.int16)

F = open("MIC_3_RIGHT.dat", "r")

data_r = []

for line in F:
    data_r.append(int(line));

F.close()

data_r = np.asarray(data_r, dtype=np.int16)

#print(data_l.shape)
#print(data_r.shape)

data = np.stack((data_l, data_r))
data = np.transpose(data)
#print(data.shape)

print("Writing mic_pair_3.wav")
write('mic_pair_3.wav', 48000, data)

####################################################################################################
F = open("MIC_4_LEFT.dat", "r")

data_l = []

for line in F:
    data_l.append(int(line));

F.close()

data_l = np.asarray(data_l, dtype=np.int16)

F = open("MIC_4_RIGHT.dat", "r")

data_r = []

for line in F:
    data_r.append(int(line));

F.close()

data_r = np.asarray(data_r, dtype=np.int16)

#print(data_l.shape)
#print(data_r.shape)

data = np.stack((data_l, data_r))
data = np.transpose(data)
#print(data.shape)

print("Writing mic_pair_4.wav")
write('mic_pair_4.wav', 48000, data)

####################################################################################################

F = open("LINE_IN_LEFT.dat", "r")

data_l = []

for line in F:
    data_l.append(int(line));

F.close()

data_l = np.asarray(data_l, dtype=np.int16)

F = open("LINE_IN_RIGHT.dat", "r")

data_r = []

for line in F:
    data_r.append(int(line));

F.close()

data_r = np.asarray(data_r, dtype=np.int16)

#print(data_l.shape)
#print(data_r.shape)

data = np.stack((data_l, data_r))
data = np.transpose(data)
#print(data.shape)

print("Writing line_in_output.wav")
write('line_in_output.wav', 48000, data)

print("Data successfully converted!")
####################################################################################################
