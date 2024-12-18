  # -*- coding: utf-8 -*-
"""
Created on Sun Nov 17 19:07:59 2024

@author: zjian4
"""

#%%
# import various libraries necessary to run your Python code
import time # time related library
import sys,os # system related library
ok_sdk_loc = "C:\\Program Files\\Opal Kelly\\FrontPanelUSB\\API\\Python\\x64"
ok_dll_loc = "C:\\Program Files\\Opal Kelly\\FrontPanelUSB\\API\\lib\\x64"
sys.path.append(ok_sdk_loc) # add the path of the OK library
os.add_dll_directory(ok_dll_loc)
import ok # OpalKelly library
# from PIL import Image
import numpy as np
import cv2
import matplotlib as mpl
import matplotlib.pyplot as plt

#%% 
# Define FrontPanel device variable, open USB communication and
# load the bit file in the FPGA
dev = ok.okCFrontPanel() # define a device for FrontPanel communication
SerialStatus=dev.OpenBySerial("") # open USB communication with the OK board
# We will NOT load the bit file because it will be loaded using JTAG interface from Vivado
# Check if FrontPanel is initialized correctly and if the bit file is loaded.
# Otherwise terminate the program
print("----------------------------------------------------")
if SerialStatus == 0:
 print ("FrontPanel host interface was successfully initialized.")
else: 
 print ("FrontPanel host interface not detected. The error code number is:" + 
str(int(SerialStatus)))
 print("Exiting the program.")
 sys.exit ()
# #%% 
# # Define the two variables that will send data to the FPGA
# # We will use WireIn instructions to send data to the FPGA
Add=  [42 ,43 ,44 ,57 , 58, 59 ,60 ,68,69 ,80, 83,97 ,98,100,101,102,103,106,107,108,109,110,117];
WR_V =[255, 2, 0 , 3 , 44,240 ,10 , 2,9  ,2 , 187,240,10,112,98 ,34 ,64 ,94 ,110,91 ,82 ,80 , 91];
for i in range (len(Add)):
    PC_Control = 1; # send a "go" signal to the FSM
    W_R=1;
    REG_ADD  =Add [i]; 
    REG_Value=WR_V[i];
    dev.SetWireInValue(0x03, PC_Control) 
    dev.SetWireInValue(0x04, W_R) 
    dev.SetWireInValue(0x02, REG_ADD) 
    dev.SetWireInValue(0x01, REG_Value) 
    dev.UpdateWireIns() # Update the WireIns
     
    # print("Send GO signal to the FSM") 
    # Since we are using a slow clock on the FPGA to compute the results
    # we need to wait for the result to be computed
     
    dev.UpdateWireOuts()
    readV=dev.GetWireOutValue(0x20)
    PC_Control = 0; # send a "stop" signal to the FSM
    dev.SetWireInValue(0x03, PC_Control) 
    dev.UpdateWireIns() # Update the WireIns
    # print("Send STOP signal to the FSM")
    
    print("ADDRESS: " + str(int(REG_ADD)) + " write data: " + str(int(REG_Value)))
    # print("Send STOP signal to the FSM")
     
    time.sleep(0.01)
   
 
 
 
 
 
 
 
 
 



#%% 
f=0
buf = bytearray(315392);

intensity_values = []
noise_list =[]
start_time = time.time();
for f in range(100):
    
    dev.SetWireInValue(0x05, 1); #Reset FIFOs and counter 
    dev.UpdateWireIns();  # Update the WireIns 
    # time.sleep(.01) 
  
    dev.SetWireInValue(0x05, 0); #Release reset signal 
    dev.UpdateWireIns();  # Update the WireIns 
   
    
      
    dev.ReadFromBlockPipeOut(0xa0, 1024, buf)
    
    im = np.array(buf, dtype = np.uint8)
    im = im[:-464]
    im = im.reshape((486,648))
    cv2.imshow('Pic', im)
    intensity = im[50, 50]  # Access pixel (50, 50)
    intensity_values.append(intensity)
    if(cv2.waitKey(1) & 0xFF == ord('p')):
        break
end_time= time .time();
cv2.destroyAllWindows()
time.sleep(.01)   

print("done") 
print('Time took: ', end_time-start_time)

    # new_image = Image.frombytes('L',(648,486), buf) 
    
    # new_image.show() 

# for n in range(len(f)):
#     noise_list[n]= float(intensity_values[n])
   
noise_list = [float(intensity) for intensity in intensity_values]

# Plot the intensity values over the frames
plt.plot(range(len(noise_list)), noise_list, marker='o')
plt.xlabel('Frame Number')
plt.ylabel('Pixel Intensity (50,50)')
plt.title('Intensity at Pixel (50,50) over Frames')
# plt.grid(True)
plt.show()
      
   

# f=f+1;


dev.Close