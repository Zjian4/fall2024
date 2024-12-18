# -*- coding: utf-8 -*-

#%%
# import various libraries necessary to run your Python code
import time   # time related library
import sys,os    # system related library
ok_sdk_loc = "C:\\Program Files\\Opal Kelly\\FrontPanelUSB\\API\\Python\\x64"
ok_dll_loc = "C:\\Program Files\\Opal Kelly\\FrontPanelUSB\\API\\lib\\x64"

sys.path.append(ok_sdk_loc)   # add the path of the OK library
os.add_dll_directory(ok_dll_loc)

import ok     # OpalKelly library
#%% 
# Define FrontPanel device variable, open USB communication and
# load the bit file in the FPGA
dev = ok.okCFrontPanel()  # define a device for FrontPanel communication
SerialStatus=dev.OpenBySerial("")      # open USB communication with the OK board
# We will NOT load the bit file because it will be loaded using JTAG interface from Vivado

# Check if FrontPanel is initialized correctly and if the bit file is loaded.
# Otherwise terminate the program
print("----------------------------------------------------")
if SerialStatus == 0:
    print ("FrontPanel host interface was successfully initialized.")
else:    
    print ("FrontPanel host interface not detected. The error code number is:" + str(int(SerialStatus)))
    print("Exiting the program.")
    sys.exit ()


# #%% 
# # Define the two variables that will send data to the FPGA
# # We will use WireIn instructions to send data to the FPGA
# Add= 0x00;
# for i in range (0, 57):
#     PC_Control = 1; # send a "go" signal to the FSM
#     W_R=1;
    
#     WR_V=0x11;
#     dev.SetWireInValue(0x03, PC_Control) 
#     dev.SetWireInValue(0x04, W_R) 
#     dev.SetWireInValue(0x02, Add) 
#     dev.SetWireInValue(0x01, WR_V) 
#     dev.UpdateWireIns()  # Update the WireIns
    
#     # print("Send GO signal to the FSM") 
#     # Since we are using a slow clock on the FPGA to compute the results
#     # we need to wait for the result to be computed
                   
#     dev.UpdateWireOuts()
#     readV=dev.GetWireOutValue(0x20)
#     PC_Control = 0; # send a "stop" signal to the FSM
#     dev.SetWireInValue(0x03, PC_Control) 
#     dev.UpdateWireIns()  # Update the WireIns
#     # print("Send STOP signal to the FSM")
#     print("ADDRESS: " + hex(Add) + " write data: " + bin(WR_V))
#     # print("Send STOP signal to the FSM")
    
#     time.sleep(0.2)
#     Add=Add+1
    
    
    
    
    
    
    
    
    
# #%% 

# PC_Control = 1; # send a "go" signal to the FSM
# W_R=1;
# Add= 0x57;
# WR_V=3;
# dev.SetWireInValue(0x03, PC_Control) 
# dev.SetWireInValue(0x04, W_R) 
# dev.SetWireInValue(0x02, Add) 
# dev.SetWireInValue(0x01, WR_V) 
# dev.UpdateWireIns()  # Update the WireIns
# # print("Send GO signal to the FSM") 

# # Since we are using a slow clock on the FPGA to compute the results
# # we need to wait for the result to be computed
# dev.UpdateWireOuts()
# readV=dev.GetWireOutValue(0x20)               

# PC_Control = 0; # send a "stop" signal to the FSM
# dev.SetWireInValue(0x03, PC_Control) 
# dev.UpdateWireIns()  # Update the WireIns
# # print("Send STOP signal to the FSM")
# print("ADDRESS: " + bin(Add) + " write data: " + bin(WR_V))


# time.sleep(0.2)




# #%% 

# PC_Control = 1; # send a "go" signal to the FSM
# W_R=1;
# Add= 0x58;
# WR_V=44;
# dev.SetWireInValue(0x03, PC_Control) 
# dev.SetWireInValue(0x04, W_R) 
# dev.SetWireInValue(0x02, Add) 
# dev.SetWireInValue(0x01, WR_V) 
# dev.UpdateWireIns()  # Update the WireIns
# # print("Send GO signal to the FSM") 

# # Since we are using a slow clock on the FPGA to compute the results
# # we need to wait for the result to be computed
# dev.UpdateWireOuts()
# readV=dev.GetWireOutValue(0x20)               

# PC_Control = 0; # send a "stop" signal to the FSM
# dev.SetWireInValue(0x03, PC_Control) 
# dev.UpdateWireIns()  # Update the WireIns
# # print("Send STOP signal to the FSM")
# print("ADDRESS: " + bin(Add) + " write data: " + bin(WR_V))


# time.sleep(0.2)




# #%% 

# PC_Control = 1; # send a "go" signal to the FSM
# W_R=1;
# Add= 0x59;
# WR_V=240;
# dev.SetWireInValue(0x03, PC_Control) 
# dev.SetWireInValue(0x04, W_R) 
# dev.SetWireInValue(0x02, Add) 
# dev.SetWireInValue(0x01, WR_V) 
# dev.UpdateWireIns()  # Update the WireIns
# # print("Send GO signal to the FSM") 

# # Since we are using a slow clock on the FPGA to compute the results
# # we need to wait for the result to be computed
# dev.UpdateWireOuts()
# readV=dev.GetWireOutValue(0x20)               

# PC_Control = 0; # send a "stop" signal to the FSM
# dev.SetWireInValue(0x03, PC_Control) 
# dev.UpdateWireIns()  # Update the WireIns
# # print("Send STOP signal to the FSM")
# print("ADDRESS: " + bin(Add) + " write data: " + bin(WR_V))


# time.sleep(0.2)



# #%% 

# PC_Control = 1; # send a "go" signal to the FSM
# W_R=1;
# Add= 0x60;
# WR_V=10;
# dev.SetWireInValue(0x03, PC_Control) 
# dev.SetWireInValue(0x04, W_R) 
# dev.SetWireInValue(0x02, Add) 
# dev.SetWireInValue(0x01, WR_V) 
# dev.UpdateWireIns()  # Update the WireIns
# # print("Send GO signal to the FSM") 

# # Since we are using a slow clock on the FPGA to compute the results
# # we need to wait for the result to be computed
# dev.UpdateWireOuts()
# readV=dev.GetWireOutValue(0x20)               

# PC_Control = 0; # send a "stop" signal to the FSM
# dev.SetWireInValue(0x03, PC_Control) 
# dev.UpdateWireIns()  # Update the WireIns
# # print("Send STOP signal to the FSM")
# print("ADDRESS: " + bin(Add) + " write data: " + bin(WR_V))


# time.sleep(0.2)

# #%% 

# PC_Control = 1; # send a "go" signal to the FSM
# W_R=1;
# Add= 0x61;
# WR_V=44;
# dev.SetWireInValue(0x03, PC_Control) 
# dev.SetWireInValue(0x04, W_R) 
# dev.SetWireInValue(0x02, Add) 
# dev.SetWireInValue(0x01, WR_V) 
# dev.UpdateWireIns()  # Update the WireIns
# # print("Send GO signal to the FSM") 

# # Since we are using a slow clock on the FPGA to compute the results
# # we need to wait for the result to be computed
# dev.UpdateWireOuts()
# readV=dev.GetWireOutValue(0x20)               

# PC_Control = 0; # send a "stop" signal to the FSM
# dev.SetWireInValue(0x03, PC_Control) 
# dev.UpdateWireIns()  # Update the WireIns
# # print("Send STOP signal to the FSM")
# print("ADDRESS: " + bin(Add) + " write data: " + bin(WR_V))


# time.sleep(0.2)





# #%% 

# PC_Control = 1; # send a "go" signal to the FSM
# W_R=1;
# Add= 0x62;
# WR_V=44;
# dev.SetWireInValue(0x03, PC_Control) 
# dev.SetWireInValue(0x04, W_R) 
# dev.SetWireInValue(0x02, Add) 
# dev.SetWireInValue(0x01, WR_V) 
# dev.UpdateWireIns()  # Update the WireIns
# # print("Send GO signal to the FSM") 

# # Since we are using a slow clock on the FPGA to compute the results
# # we need to wait for the result to be computed
# dev.UpdateWireOuts()
# readV=dev.GetWireOutValue(0x20)               

# PC_Control = 0; # send a "stop" signal to the FSM
# dev.SetWireInValue(0x03, PC_Control) 
# dev.UpdateWireIns()  # Update the WireIns
# # print("Send STOP signal to the FSM")
# print("ADDRESS: " + bin(Add) + " write data: " + bin(WR_V))


# time.sleep(0.2)




# #%% 

# PC_Control = 1; # send a "go" signal to the FSM
# W_R=1;
# Add= 0x68;
# WR_V=44;
# dev.SetWireInValue(0x03, PC_Control) 
# dev.SetWireInValue(0x04, W_R) 
# dev.SetWireInValue(0x02, Add) 
# dev.SetWireInValue(0x01, WR_V) 
# dev.UpdateWireIns()  # Update the WireIns
# # print("Send GO signal to the FSM") 

# # Since we are using a slow clock on the FPGA to compute the results
# # we need to wait for the result to be computed
# dev.UpdateWireOuts()
# readV=dev.GetWireOutValue(0x20)               

# PC_Control = 0; # send a "stop" signal to the FSM
# dev.SetWireInValue(0x03, PC_Control) 
# dev.UpdateWireIns()  # Update the WireIns
# # print("Send STOP signal to the FSM")
# print("ADDRESS: " + bin(Add) + " write data: " + bin(WR_V))


# time.sleep(0.2)



# #%% 

# PC_Control = 1; # send a "go" signal to the FSM
# W_R=1;
# Add= 0x69;
# WR_V=9;
# dev.SetWireInValue(0x03, PC_Control) 
# dev.SetWireInValue(0x04, W_R) 
# dev.SetWireInValue(0x02, Add) 
# dev.SetWireInValue(0x01, WR_V) 
# dev.UpdateWireIns()  # Update the WireIns
# # print("Send GO signal to the FSM") 

# # Since we are using a slow clock on the FPGA to compute the results
# # we need to wait for the result to be computed
# dev.UpdateWireOuts()
# readV=dev.GetWireOutValue(0x20)               

# PC_Control = 0; # send a "stop" signal to the FSM
# dev.SetWireInValue(0x03, PC_Control) 
# dev.UpdateWireIns()  # Update the WireIns
# # print("Send STOP signal to the FSM")
# print("ADDRESS: " + bin(Add) + " write data: " + bin(WR_V))


# time.sleep(0.2)








# #%% 

# PC_Control = 1; # send a "go" signal to the FSM
# W_R=1;
# Add= 0x58;
# WR_V=44;
# dev.SetWireInValue(0x03, PC_Control) 
# dev.SetWireInValue(0x04, W_R) 
# dev.SetWireInValue(0x02, Add) 
# dev.SetWireInValue(0x01, WR_V) 
# dev.UpdateWireIns()  # Update the WireIns
# # print("Send GO signal to the FSM") 

# # Since we are using a slow clock on the FPGA to compute the results
# # we need to wait for the result to be computed
# dev.UpdateWireOuts()
# readV=dev.GetWireOutValue(0x20)               

# PC_Control = 0; # send a "stop" signal to the FSM
# dev.SetWireInValue(0x03, PC_Control) 
# dev.UpdateWireIns()  # Update the WireIns
# # print("Send STOP signal to the FSM")
# print("ADDRESS: " + bin(Add) + " write data: " + bin(WR_V))


# time.sleep(0.2)







# #%% 




# PC_Control = 1; # send a "go" signal to the FSM
# W_R=0;
# Add= 0x03;
# # WR_V=0x11;
# dev.SetWireInValue(0x03, PC_Control) 
# dev.SetWireInValue(0x04, W_R) 
# dev.SetWireInValue(0x02, Add) 
# # dev.SetWireInValue(0x01, WR_V) 
# dev.UpdateWireIns()  # Update the WireIns

# # print("Send GO signal to the FSM") 

# # Since we are using a slow clock on the FPGA to compute the results
# # we need to wait for the result to be compute
# time.sleep(0.1)

# dev.UpdateWireOuts()
# readV=dev.GetWireOutValue(0x20)

# PC_Control = 0; # send a "stop" signal to the FSM
# dev.SetWireInValue(0x03, PC_Control) 
# dev.UpdateWireIns()  # Update the WireIns
# print("ADDRESS: " + bin(Add) + " data: " + bin(readV))
# # print("Send STOP signal to the FSM")




# time.sleep(0.2)


#%% 


PC_Control = 1; # send a "go" signal to the FSM
W_R=0;
Add= 0x01;
# WR_V=0x11;
dev.SetWireInValue(0x03, PC_Control) 
dev.SetWireInValue(0x04, W_R) 
dev.SetWireInValue(0x02, Add) 
# dev.SetWireInValue(0x01, WR_V) 
dev.UpdateWireIns()  # Update the WireIns

# print("Send GO signal to the FSM") 

# Since we are using a slow clock on the FPGA to compute the results
# we need to wait for the result to be compute
time.sleep(0.1)

dev.UpdateWireOuts()
readV=dev.GetWireOutValue(0x20)

PC_Control = 0; # send a "stop" signal to the FSM
dev.SetWireInValue(0x03, PC_Control) 
dev.UpdateWireIns()  # Update the WireIns
print("ADDRESS: " + hex(Add) + " data: " + hex(readV))
# print("Send STOP signal to the FSM")



dev.Close
    
#%%