#%%
# import various libraries necessary to run your Python code
import time # time related library
import sys,os # system related library
ok_sdk_loc = "C:\\Program Files\\Opal Kelly\\FrontPanelUSB\\API\\Python\\x64"
ok_dll_loc = "C:\\Program Files\\Opal Kelly\\FrontPanelUSB\\API\\lib\\x64"
sys.path.append(ok_sdk_loc) # add the path of the OK library
os.add_dll_directory(ok_dll_loc)
import ok # OpalKelly library
from PIL import Image
import numpy as np
import cv2
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
Add=  [42 ,43 ,44 ,57 , 58, 59 ,60 ,68,69 ,80,83  ,97 ,98,100,101,102,103,106,107,108,109,110,117];
WR_V =[255, 9 , 0 , 3 , 44,240 ,10 , 2,9  ,2 , 187,240,10,112,98 ,34 ,64 ,94 ,110,91 ,82 ,80 , 91];
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


dev.SetWireInValue(0x05, 1); #Reset FIFOs and counter 
dev.UpdateWireIns();  # Update the WireIns 
# time.sleep(.01) 
  
dev.SetWireInValue(0x05, 0); #Release reset signal 
dev.UpdateWireIns();  # Update the WireIns 
   

  
dev.ReadFromBlockPipeOut(0xa0, 1024, buf)

  

print("done") 

new_image = Image.frombytes('L',(648,486), buf) 

new_image.show() 

  
   



dev.Close