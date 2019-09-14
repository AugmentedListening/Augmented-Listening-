import ftplib
import sys
 
def getFile(ftp, filename):
    try:
        ftp.retrbinary("RETR " + filename ,open(filename, 'wb').write)
    except:
        print("Error")
 
print("Connecting to FPGA@192.168.137.123") 
ftp = ftplib.FTP("192.168.137.123")
ftp.login("root", "password")
print("Retrieving microphone data...")
ftp.cwd('/home/root/dma/')         # change directory to /pub/
getFile(ftp,'LINE_IN_LEFT.dat')
getFile(ftp,'LINE_IN_RIGHT.dat')
getFile(ftp,'MIC_1_LEFT.dat')
getFile(ftp,'MIC_1_RIGHT.dat')
getFile(ftp,'MIC_2_LEFT.dat')
getFile(ftp,'MIC_2_RIGHT.dat')
getFile(ftp,'MIC_3_LEFT.dat')
getFile(ftp,'MIC_3_RIGHT.dat')
getFile(ftp,'MIC_4_LEFT.dat')
getFile(ftp,'MIC_4_RIGHT.dat')

print("Successfully retrieved data!")
 
ftp.quit()
