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
ConfigStatus=dev.ConfigureFPGA("U:\Downloads\ECE437\lab2\lab2\lab2.runs\impl_1\lab2_example.bit"); # Configure the FPGA with this bit file

# Check if FrontPanel is initialized correctly and if the bit file is loaded.
# Otherwise terminate the program
print("----------------------------------------------------")
if SerialStatus == 0:
    print ("FrontPanel host interface was successfully initialized.")
else:    
    print ("FrontPanel host interface not detected. The error code number is:" + str(int(SerialStatus)))
    print("Exiting the program.")
    sys.exit ()

if ConfigStatus == 0:
    print ("Your bit file is successfully loaded in the FPGA.")
else:
    print ("Your bit file did not load. The error code number is:" + str(int(ConfigStatus)))
    print ("Exiting the progam.")
    sys.exit ()
print("----------------------------------------------------")
print("----------------------------------------------------")

#%% 
# Define the two variables that will send data to the FPGA
# We will use WireIn instructions to send data to the FPGA
variable_1 = 2; # variable_1 is initialized to digital number 50
variable_2 = 5; # # variable_2 is initialized to digital number 14
variable_3 = 100;
print("Variable 1 is initialized to " + str(int(variable_1)))
print("Frequency is initialized to " + str(int(variable_2)))
print("Reset is initialized to " + str(int(variable_3)))

dev.SetWireInValue(0x00, variable_1) #Input data for Variable 1 using memory space 0x00
dev.SetWireInValue(0x01, variable_2) #Input data for Variable 2 using memory space 0x01
dev.SetWireInValue(0x02, variable_3) #Input data for Variable 2 using memory space 0x01
dev.UpdateWireIns()  # Update the WireIns

#%% 
# We will read data from the FPGA in two different variables
# Since we are using a slow clock on the FPGA to compute the results
# we need to wait for the result to be computed
time.sleep(0.5)                 

# First receive data from the FPGA by using UpdateWireOuts
while(True ):
    time.sleep(0.15)
    dev.UpdateWireOuts()
    result_sum = dev.GetWireOutValue(0x20)  # Transfer the received data in result_sum variable
    result_difference = dev.GetWireOutValue(0x21)  # Transfer the received data in result_difference variable
    control = dev.GetWireOutValue(0x22)
    #print("The sum of the two numbers is " + str(int(result_sum)))
    #print("The difference between the two numbers is " + str(int(result_difference)))
    print("Count number is "+ str(int(control)))

dev.Close
    
#%%