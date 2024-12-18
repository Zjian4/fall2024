
# Page
# 1
# of 2
# This code reads data from the temperature sensor and outputs the results on the
# screen.
# The bit file programs OpalKelly's XEM7310 board with a finite state machine that
# implements
# I2C protocol. With this protocol, temperature data is received from the
# temperature sensor
# to the FPGA. Then the FPGA transfers the data from the two registers containing
# the temperature data to the PC using OKWireOut.
# import various libraries necessary to run your Python code
import time # time related library
import sys,os # system related library
ok_sdk_loc = "C:\\Program Files\\Opal Kelly\\FrontPanelUSB\\API\\Python\\x64"
ok_dll_loc = "C:\\Program Files\\Opal Kelly\\FrontPanelUSB\\API\\lib\\x64"
sys.path.append(ok_sdk_loc) # add the path of the OK library
os.add_dll_directory(ok_dll_loc)
import ok # OpalKelly libraryy
#%%
# Define FrontPanel device variable, open USB communication and
# load the bit file in the FPGA
dev = ok.okCFrontPanel(); # define a device for FrontPanel communication
SerialStatus=dev.OpenBySerial(""); # open USB communication with the OK board
# ConfigStatus=dev.ConfigureFPGA("I2C_Temperature.bit"); # Configure the FPGA with
# this bit file
# Check if FrontPanel is initialized correctly and if the bit file is loaded.
# Otherwise terminate the program
print("----------------------------------------------------")
if SerialStatus == 0:
    print ("FrontPanel host interface was successfully initialized.");
else:
    print ("FrontPanel host interface not detected. The error code number is:" + str(int(SerialStatus)));
    print("Exiting the program.");
    sys.exit ();
# if ConfigStatus == 0:
#     print ("Your bit file is successfully loaded in the FPGA.");
# else:
#     print ("Your bit file did not load. The error code number is:" + str(int(ConfigStatus)));
#     print ("Exiting the progam.");
# sys.exit ();
print("----------------------------------------------------")
print("----------------------------------------------------")
#%% Press control-C in the console window to stop the loop
try:
    while True:
        dev.SetWireInValue(0x00, 1); #Sending 1 at memory location 0x00 starts the FSM
        dev.UpdateWireIns(); # Update the WireIns
        dev.UpdateWireOuts() # Receive the temperature data
        temperature_msb = dev.GetWireOutValue(0x20) # MSB temperature register
        temperature_lsb = dev.GetWireOutValue(0x21) # LSB temperature register
        temperature = float(((temperature_msb<<8) + temperature_lsb))/8*0.0625;
         # Put the temperature data together
        time.sleep(0.5);
        print ("Temperature is:" + str((temperature))); # print the results
except KeyboardInterrupt:
        pass
