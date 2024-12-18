# -*- coding: utf-8 -*-
"""
Created on Thu Oct  3 13:02:53 2024

@author: zjian4
"""

# NOTE 1
# If your power supply goes into an error state (i.e., the word
# error is printed on the front of the device), use this command
# power_supply.write("*CLS")
# to clear the error so that you can rerun your code. The supply
# typically beeps after an error has occured.

import pyvisa as visa # You should pip install pyvisa and restart the kernel.
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
import time
mpl.style.use('ggplot')



# import various libraries necessary to run your Python code
import sys,os    # system related library
ok_sdk_loc = "C:\\Program Files\\Opal Kelly\\FrontPanelUSB\\API\\Python\\x64"
ok_dll_loc = "C:\\Program Files\\Opal Kelly\\FrontPanelUSB\\API\\lib\\x64"

sys.path.append(ok_sdk_loc)   # add the path of the OK library
os.add_dll_directory(ok_dll_loc)

import ok     # OpalKelly libraryy



#%%
# Define FrontPanel device variable, open USB communication and
# load the bit file in the FPGA
dev = ok.okCFrontPanel(); # define a device for FrontPanel communication
SerialStatus=dev.OpenBySerial(""); # open USB communication with the OK board
ConfigStatus=dev.ConfigureFPGA("U:\Downloads\ECE437\lab5\Lab5\Lab5.runs\impl_1\JTEG_Test_File.bit"); # Configure the FPGA with this bit file
# Check if FrontPanel is initialized correctly and if the bit file is loaded.
# Otherwise terminate the program
print("----------------------------------------------------")
if SerialStatus == 0:
    print ("FrontPanel host interface was successfully initialized.");
else:
    print ("FrontPanel host interface not detected. The error code number is:" + str(int(SerialStatus)));
    print("Exiting the program.");
    sys.exit ();
if ConfigStatus == 0:
    print ("Your bit file is successfully loaded in the FPGA.");
else:
    print ("Your bit file did not load. The error code number is:" + str(int(ConfigStatus)));
    print ("Exiting the progam.");
    sys.exit ();
print("----------------------------------------------------")
print("----------------------------------------------------")

#%%

# This section of the code cycles through all USB connected devices to the computer.
# The code figures out the USB port number for each instrument.
# The port number for each instrument is stored in a variable named “instrument_id”
# If the instrument is turned off or if you are trying to connect to the
# keyboard or mouse, you will get a message that you cannot connect on that port.
device_manager = visa.ResourceManager()
devices = device_manager.list_resources()
number_of_device = len(devices)

power_s0upply_id = -1;
waveform_generator_id = -1;
digital_multimeter_id = -1;
oscilloscope_id = -1;

# assumes only the DC power supply is connected
for i in range (0, number_of_device):

# check that it is actually the power supply
    try:
        device_temp = device_manager.open_resource(devices[i])
        print("Instrument connect on USB port number [" + str(i) + "] is " + device_temp.query("*IDN?"))
        if (device_temp.query("*IDN?") == 'HEWLETT-PACKARD,E3631A,0,3.2-6.0-2.0\r\n'):
            power_supply_id = i        
        if (device_temp.query("*IDN?") == 'HEWLETT-PACKARD,E3631A,0,3.0-6.0-2.0\r\n'):
            #
            power_supply_id = i
           
        if (device_temp.query("*IDN?") == 'Agilent Technologies,33511B,MY52301259,\n'):
            #3.03-1.19-2.00-52-00
            waveform_generator_id = i
        if (device_temp.query("*IDN?") == 'Agilent Technologies,34461A,MY53208026,A.01.10-02.25-01.10-00.35-01-01\n'):
            #A.01.10-02.25-01.10-00.35-01-01
            digital_multimeter_id = i
        if (device_temp.query("*IDN?") == 'Keysight Technologies,34461A,MY53212931,\n'):
            #A.02.08-02.37-02.08-00.49-01-01
            digital_multimeter_id = i            
        if (device_temp.query("*IDN?") == 'KEYSIGHT TECHNOLOGIES,MSO-X 3024T,MY54440318,07.50.2021102830\n'):
            #,MY54440281X,MY54440281,07.10.2017042905\n
            oscilloscope_id = i                        
        device_temp.close()
    except:
        print("Instrument on USB port number [" + str(i) + "] cannot be connected. The instrument might be powered of or you are trying to connect to a mouse or keyboard.\n")
   

    #%%
    # Open the USB communication port with the power supply.
    # The power supply is connected on USB port number power_supply_id.
    # If the power supply ss not connected or turned off, the program will exit.
    # Otherwise, the power_supply variable is the handler to the power supply
       
if (power_supply_id == -1):
    print("Power supply instrument is not powered on or connected to the PC.")    
else:
    print("Power supply is connected to the PC.")
    power_supply = device_manager.open_resource(devices[power_supply_id])
   
if (oscilloscope_id == -1):
    print("Oscilloscope instrument is not powered on or connected to the PC.")    
else:
    print("Oscilloscope is connected to the PC.")
    oscilloscope = device_manager.open_resource(devices[oscilloscope_id])
   
if (digital_multimeter_id == -1):
        print("Multimeter instrument is not powered on or connected to the PC.")    
else:
    print("Multimeter is connected to the PC.")
    digital_multimeter = device_manager.open_resource(devices[digital_multimeter_id])
    
        
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


   #%% 
   # Define the two variables that will send data to the FPGA
   # We will use WireIn instructions to send data to the FPGA

#%%
# The power supply output voltage will be swept from 0 to 1.5V in steps of 0.05V.
# This voltage will be applied on the 6V output ports.
# For each voltage applied on the 6V power supply, we will measure the actual
# voltage and current supplied by the power supply.
# If your circuit operates correctly, the applied and measured voltage will be the same.
# If the power supply reaches its maximum allowed current,
# then the applied voltage will not be the same as the measured voltage.

output_voltage = np.arange(0, 4.81, 0.3)
#measured_voltage = np.array([]) # create an empty list to hold our values
#measured_current = np.array([]) # create an empty list to hold our values


Vm=[]
Im=[]
Vsd=[]
Isd=[]
Pwsd=[]
Pwm=[]
Tempm=[]
Tempsd=[]
print(power_supply.write("OUTPUT ON")) # power supply output is turned on

# loop through the different voltages we will apply to the power supply
# For each voltage applied on the power supply,
# measure the voltage and current supplied by the 6V power supply
for v in output_voltage:
    # apply the desired voltage on teh 6V power supply and limist the output current to 0.5A
  
    power_supply.write("APPLy P25V, %0.2f, 0.5" % v)
    
 #   print("Send GO signal to the FSM") 
    
    # pause 50ms to let things settle
    measured_current=[]
    measured_voltage=[]
    Temp=[]
    Pw=[]
    for n in range (20):
        
        PC_Control = 1; # send a "go" signal to the FSM
         
        dev.SetWireInValue(0x00, PC_Control) 
         
        dev.UpdateWireIns()  # Update the WireIns
        # read the output voltage on the 6V power supply
       
        measured_voltage_tmp=oscilloscope.query("MEASure:VRMS? CHANnel2")
        #measured_voltage_tmp = power_supply.query("MEASure:VOLTage:DC? P25V")
        measured_voltage = np.append(measured_voltage, float(measured_voltage_tmp))
        
        # read the output current on the 6V power supply
        measured_current_tmp = digital_multimeter.query("MEASure:CURRent:DC?")
        # measured_current_tmp = power_supply.query("MEASure:CURRent:DC? P25V"
        measured_current = np.append(measured_current, float(measured_current_tmp))
        Pw=  measured_voltage*measured_current
        time.sleep(0.5)                 

        PC_Control = 0; # send a "stop" signal to the FSM
        dev.SetWireInValue(0x00, PC_Control) 
        dev.UpdateWireIns()
        dev.UpdateWireOuts()
        SingleByteData=dev.GetWireOutValue(0x20)
        Temp= np.append(Temp,float(SingleByteData/16))
        print(Temp)
    # power supply output is turned off


   # print("Send STOP signal to the FSM")
    Vm.append( np.mean(measured_voltage))
    Im.append( np.mean(measured_current))
    Vsd.append(np.std(measured_voltage))
    Isd.append( np.std(measured_current))
    Pwm.append(np.mean(Pw))
    Pwsd.append(np.std(Pw))
    Tempm.append(np.mean(Temp))
    Tempsd.append(np.std(Temp))
    print(f"The means is {Tempsd}")
   
   # Temp.append(SingleByteData/16)
    #print (Temp)
  #  print("Temperature value is "+  str(int(Temp[v])))
print(power_supply.write("OUTPUT OFF"))
     
  #  print(Cm)
  #  print(Pw)
  

  



# close the power supply USB handler.
# Otherwise you cannot connect to it in the future
power_supply.close()
   
#%% Plot measured data. First convert the data from strings to numbers (ie floats)
voltagem_list=np.zeros(np.size(output_voltage))
currentm_list=np.zeros(np.size(output_voltage))
powerm_list=np.zeros(np.size(output_voltage))
Tempm_list=np.zeros(np.size(output_voltage))

voltagesd_list=np.zeros(np.size(output_voltage))
currentsd_list=np.zeros(np.size(output_voltage))
powersd_list=np.zeros(np.size(output_voltage))
Tempsd_list=np.zeros(np.size(output_voltage))

for i in range(len(output_voltage)):
    voltagem_list[i]= float(Vm[i])
    currentm_list[i]= float(Im[i])
    powerm_list[i]=float(Pwm[i])
    Tempm_list[i]=float(Tempm[i])
    
    voltagesd_list[i]= float(Vsd[i])
    currentsd_list[i]= float(Isd[i])
    powersd_list[i]=float(Pwsd[i])
    Tempsd_list[i]=float(Tempsd[i])
   
# plot results (applied voltage vs measured supplied current)
plt.figure()
plt.plot(output_voltage, currentm_list)
plt.title("Applied Volts vs. Measn of Measured Supplied Current for Diode")
plt.xlabel("Applied Volts [V]")
plt.ylabel("mean of Measured Current [A]")
plt.draw()
# plot results (measured voltage vs measured supplied current)

plt.figure()
plt.plot( output_voltage, currentsd_list)
plt.title("Applied Volts vs. Standard Deviation of Measured Supplied Current for Diode")
plt.xlabel("Applied Volts [V]")
plt.ylabel("SD of Measured Current [A]")
plt.draw()

plt.figure()
plt.plot(output_voltage, voltagem_list)
plt.title("Applied Volts vs. Measn of Measured Supplied Voltage for Diode")
plt.xlabel("Applied Volts [V]")
plt.ylabel("mean of Measured Voltage [V]")
plt.draw()
# plot results (measured voltage vs measured supplied current)

plt.figure()
plt.plot( output_voltage, voltagesd_list)
plt.title("Applied Volts vs. Standard Deviation of Measured Supplied Voltage for Diode")
plt.xlabel("Applied Volts [V]")
plt.ylabel("SD of Measured Voltage [V]")
plt.draw()


plt.figure()
plt.plot(output_voltage, powerm_list)
plt.title("Applied Volts vs. Measn of Measured Supplied Power for Diode")
plt.xlabel("Applied Volts [V]")
plt.ylabel("mean of Measured Power [W]")
plt.draw()
# plot results (measured voltage vs measured supplied current)

plt.figure()
plt.plot( output_voltage, powersd_list)
plt.title("Applied Volts vs. Standard Deviation of Measured Supplied Power for Diode")
plt.xlabel("Applied Volts [V]")
plt.ylabel("SD of Measured Power [W]")
plt.draw()

plt.figure()
plt.plot(output_voltage, Tempm_list)
plt.title("Applied Volts vs. Mean of Measured Supplied Temperature for Diode")
plt.xlabel("Applied Volts [V]")
plt.ylabel("mean of Measured Temp [C]")
plt.draw()
# plot results (measured voltage vs measured supplied current)

plt.figure()
plt.plot( output_voltage, Tempsd_list)
plt.title("Applied Volts vs. Standard Deviation of Measured Supplied Temperature for Diode")
plt.xlabel("Applied Volts [V]")
plt.ylabel("SD of Measured Temp [C]")
plt.draw()

# Since we are using a slow clock on the FPGA to compute the results
# we need to wait for the result to be computed

dev.Close
    

  # This code reads data from the temperature sensor and outputs the results on the screen.
  # The bit file programs OpalKelly's XEM7310 board with a finite state machine that implements 
  # I2C protocol. With this protocol, temperature data is received from the temperature sensor
  # to the FPGA. Then the FPGA transfers the data from the two registers containing 
  # the temperature data to the PC using OKWireOut.

  
