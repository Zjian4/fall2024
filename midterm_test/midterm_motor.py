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



import pyvisa as visa # You should pip install pyvisa and restart the kernel.
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt

mpl.style.use('ggplot')



# import various libraries necessary to run your Python c


#%%
# Define FrontPanel device variable, open USB communication and
# load the bit file in the FPGA
dev = ok.okCFrontPanel(); # define a device for FrontPanel communication
SerialStatus=dev.OpenBySerial(""); # open USB communication with the OK board
ConfigStatus=dev.ConfigureFPGA("U:\Downloads\ECE437\midterm\midterm\midterm.runs\impl_1\JTEG_Test_File.bit"); # Configure the FPGA with this bit file
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






#%% 
# Define the two variables that will send data to the FPGA
# We will use WireIn instructions to send data to the FPGA
output_voltage = np.arange(3, 5, 0.5)
print(power_supply.write("OUTPUT ON")) # power supply output is turned on

measured_accY=[]
measured_accZ=[]
measured_YZ =[]
ACCYm =[]
ACCZm =[]
ACCYZm=[]
for v in output_voltage:
    # apply the desired voltage on teh 6V power supply and limist the output current to 0.5A
  
    power_supply.write("APPLy P6V, %0.2f, 0.5" % v)
    
 #   print("Send GO signal to the FSM") 
    
    # pause 50ms to let things settle
    # measured_current=[]
    measured_voltage=[]
    # Temp=[]
    accelatration=[]
    for o in range (10):
        
        byte1=1
        dev.SetWireInValue(0x12, byte1)
        pause =0x01
        dev.SetWireInValue(0x13, pause)
        dev.UpdateWireIns()  # Update the WireIns
       
        PC_Control = 1; # send a "go" signal to the FSM
        dev.SetWireInValue(0x00, PC_Control) 
        # print("Send GO signal to the FSM")
        pause =5;
        dev.SetWireInValue(0x13, pause) 
        dev.UpdateWireIns()  # Update the WireIns
        
        Linear_acceleration=0x19
        #Megnetic = 0x1E;
        dev.SetWireInValue(0x03, Linear_acceleration) 
        address =0x20
        #meg_address=0x02;
        dev.SetWireInValue(0x02, address) 
        cnrl =0x77
        #meg_control=0x00;
        dev.SetWireInValue(0x01, cnrl)
        
        X_axis =0xA8
        #X_meg =0x83;
        dev.SetWireInValue(0x04, X_axis)
        
        dev.UpdateWireIns()  # Update the WireIns
        
        dev.UpdateWireOuts()
        go=dev.GetWireOutValue(0x27)
        time.sleep(0.1)
        
        

        
        while True:
            if (go==1):
                data_ready=1
                dev.SetWireInValue(0x11, data_ready) 
                dev.UpdateWireIns()  # Update the WireIns
                break
        # while True:
        
        #     dev.UpdateWireOuts()
        #     ack = dev.GetWireOutValue(0x22)  # Transfer the received data in result_sum variable
                    
        #     if (ack&1)==0:
                
        #         print("The SAD Write1 is acked ")
        #         if ((ack>>1)&1)==0:
                    
        #             print("The SUB is acked ")
        #             if ((ack>>2)&1)==0:
                        
        #                 print("The CNRL is acked ")
        #                 if ((ack>>3)&1)==0:
                             
        #                      print("The SAD Write2 is acked ")
        #                      if ((ack>>4)&1)==0:
                                  
        #                           print("The Address is acked ")
               
        #                           if ((ack>>5)&1)==0:
                                     
        #                              print("The SAD Read is acked ")
                
        #                              if ((ack>>6)&1)==0:
                                        
        #                                 print("The DATA 1 is acked ")
        #                                 if ((ack>>7)&1)==0:
        #                                     print("The DATA 2 is acked ")
        #                                     break
                                        
                                        
                                        
        PC_Control = 0; # send a "stop" signal to the FSM
        dev.SetWireInValue(0x00, PC_Control) 
        data_ready=0;
        dev.SetWireInValue(0x11, data_ready) 
        dev.UpdateWireIns()  # Update the WireIns
        time.sleep(1)  
        # print("Send STOP signal to the FSM")    
                                         
        dev.UpdateWireIns()  # Update the WireIns
        dev.UpdateWireOuts()
        SingleByteData1=dev.GetWireOutValue(0x21)
        dev.UpdateWireOuts()
        SingleByteData2=dev.GetWireOutValue(0x23)
        dev.UpdateWireOuts()
        SingleByteData3=dev.GetWireOutValue(0x24)                           
        
                                      
        
              
          
            
            
        # %% 
        # Since we are using a slow clock on the FPGA to compute the results
        # we need to wait for the result to be computed          
        
         
        
        PC_Control = 1; # send a "go" signal to the FSM
        dev.SetWireInValue(0x00, PC_Control) 
        dev.UpdateWireIns()  # Update the WireIns
        # print("Send GO signal to the FSM")
        
        Megnetic = 0x1E;
        dev.SetWireInValue(0x03, Megnetic) 
        
        meg_address=0x02;
        dev.SetWireInValue(0x02, meg_address) 
        
        meg_control=0x00;
        dev.SetWireInValue(0x01, meg_control)
        
        X_meg =0x83;
        dev.SetWireInValue(0x04, X_meg)
        byte1=0
        dev.SetWireInValue(0x12, byte1)
        dev.UpdateWireIns()  # Update the WireIns
        
        dev.UpdateWireOuts()
        go=dev.GetWireOutValue(0x27)
        time.sleep(0.1)
        
        
             
        
        while True:
            if (go==1):
                data_ready=1
                dev.SetWireInValue(0x11, data_ready) 
                dev.UpdateWireIns()  # Update the WireIns
                break
        # while True:
        
        #     dev.UpdateWireOuts()
        #     ack = dev.GetWireOutValue(0x22)  # Transfer the received data in result_sum variable
                    
        #     if (ack&1)==0:
                
        #         print("The SAD Write1 is acked ")
        #         if ((ack>>1)&1)==0:
                    
        #             print("The SUB is acked ")
        #             if ((ack>>2)&1)==0:
                        
        #                 print("The CNRL is acked ")
        #                 if ((ack>>3)&1)==0:
                             
        #                      print("The SAD Write2 is acked ")
        #                      if ((ack>>4)&1)==0:
                                  
        #                           print("The Address is acked ")
               
        #                           if ((ack>>5)&1)==0:
                                     
        #                              print("The SAD Read is acked ")
                
        #                              if ((ack>>6)&1)==0:
                                        
        #                                 print("The DATA 1 is acked ")
        #                                 if ((ack>>7)&1)==0:
        #                                     print("The DATA 2 is acked ")
        #                                     break
        PC_Control = 0; # send a "stop" signal to the FSM
        dev.SetWireInValue(0x00, PC_Control) 
        data_ready=0;
        dev.SetWireInValue(0x11, data_ready) 
        dev.UpdateWireIns()  # Update the WireIns
        # print("Send STOP signal to the FSM")
        time.sleep(1)                               
        
        dev.UpdateWireOuts()
        SingleByteData4=dev.GetWireOutValue(0x25)
        dev.UpdateWireOuts()
        SingleByteData5=dev.GetWireOutValue(0x26)
        dev.UpdateWireOuts()
        SingleByteData6=dev.GetWireOutValue(0x28)   
        #dev.UpdateWireOuts()
        #SingleByteData4=dev.GetWireOutValue(0x25)
        #dev.UpdateWireOuts()
        #SingleByteData5=dev.GetWireOutValue(0x26)
        time.sleep(0.1)
        #temp=SingleByteData/16
           
        def twos_comp(value):
            if value >= 0x8000:
                value-= 0x10000
            return value
        
        #for i in range(len(SingleByteData)):
         #   signed_value=twos_comp(SingleByteData[i])
        #    ACC_value[i]=signed_value/16000
        signed_valueX=twos_comp(SingleByteData1)
        ACC_valueX=signed_valueX/16000
        
        signed_valueY=twos_comp(SingleByteData2)
        ACC_valueY=signed_valueY/16000
        
        signed_valueZ=twos_comp(SingleByteData3)
        ACC_valueZ=signed_valueZ/16000
        
        signed_valueXX=twos_comp(SingleByteData4)
        ACC_valueXX=signed_valueXX/11000
        signed_valueYY=twos_comp(SingleByteData5)
        ACC_valueYY=signed_valueYY/11000
        
        signed_valueZZ=twos_comp(SingleByteData6)
        ACC_valueZZ=signed_valueZZ/9800
        
        
        # print("X_acc is "+ str(float(ACC_valueX)))
        print("Y_acc is "+ str(float(ACC_valueY)))
        print("Z_acc is "+ str(float(ACC_valueZ)))
        # print("X_meg is "+ str(float(ACC_valueXX)))
        # print("Y_meg is "+ str(float(ACC_valueYY)))
        # print("Z_meg is "+ str(float(ACC_valueZZ)))
        YZ = ACC_valueY*ACC_valueY+ACC_valueZ*ACC_valueZ
        # measured_voltage_tmp=oscilloscope.query("MEASure:VRMS? CHANnel2")
        # #measured_voltage_tmp = power_supply.query("MEASure:VOLTage:DC? P25V")
        measured_accY = np.append(measured_accY, abs(float(ACC_valueY)))
        measured_accZ = np.append(measured_accZ, abs(float(ACC_valueZ)))
        measured_YZ =np.append(measured_YZ, abs(float(YZ)))
        # # read the output current on the 6V power supply
        # measured_current_tmp = digital_multimeter.query("MEASure:CURRent:DC?")
        # # measured_current_tmp = power_supply.query("MEASure:CURRent:DC? P25V"
        # measured_current = np.append(measured_current, float(measured_current_tmp))
        # Pw=  measured_voltage*measured_current
        # time.sleep(0.5)     
    ACCYZm.append   ( np.mean(measured_YZ))     
    ACCYm.append( np.mean(measured_accY))
    ACCZm.append( np.mean(measured_accZ))   
print(power_supply.write("OUTPUT OFF"))
     
  #  print(Cm)
  #  print(Pw)
  
# close the power supply USB handler.
# Otherwise you cannot connect to it in the future
power_supply.close()

ACCYZm_list=np.zeros(np.size(output_voltage))
ACCYm_list=np.zeros(np.size(output_voltage))
ACCZm_list=np.zeros(np.size(output_voltage))

for n in range(len(output_voltage)):
    ACCYm_list[n]= float(ACCYm[n])
    ACCZm_list[n]= float(ACCZm[n])
    ACCYZm_list[n]= float(ACCYZm[n])
plt.figure()
plt.plot(output_voltage, ACCYm_list)
plt.title("Applied Volts vs. Measn of Measured Y acc")
plt.xlabel("Applied Volts [V]")
plt.ylabel("mean of Y ACC ")
plt.draw()
# plot results (measured voltage vs measured supplied current)

plt.figure()
plt.plot( output_voltage, ACCZm_list)
plt.title("Applied Volts vs. Measn of Measured Y acc")
plt.xlabel("Applied Volts [V]")
plt.ylabel("mean of Z ACC")
plt.draw()

plt.figure()
plt.plot( output_voltage, ACCYZm_list)
plt.title("Applied Volts vs. Measn of Measured YZ acc")
plt.xlabel("Applied Volts [V]")
plt.ylabel("mean of Z ACC")
plt.draw()

#SingleByteData=[0]*3;
#ACC_value=[0]*3;
# byte1=1
# dev.SetWireInValue(0x12, byte1)
# pause =0x02
# dev.SetWireInValue(0x13, pause)
# dev.UpdateWireIns()  # Update the WireIns
# while True:
   
#     PC_Control = 1; # send a "go" signal to the FSM
#     dev.SetWireInValue(0x00, PC_Control) 
#     # print("Send GO signal to the FSM")
#     pause =5;
#     dev.SetWireInValue(0x13, pause) 
#     dev.UpdateWireIns()  # Update the WireIns
    
#     Linear_acceleration=0x19
#     #Megnetic = 0x1E;
#     dev.SetWireInValue(0x03, Linear_acceleration) 
#     address =0x20
#     #meg_address=0x02;
#     dev.SetWireInValue(0x02, address) 
#     cnrl =0x77
#     #meg_control=0x00;
#     dev.SetWireInValue(0x01, cnrl)
    
#     X_axis =0xA8
#     #X_meg =0x83;
#     dev.SetWireInValue(0x04, X_axis)
    
#     dev.UpdateWireIns()  # Update the WireIns
    
#     dev.UpdateWireOuts()
#     go=dev.GetWireOutValue(0x27)
#     time.sleep(0.1)
    
    
    
    
         
    
#     while True:
#         if (go==1):
#             data_ready=1
#             dev.SetWireInValue(0x11, data_ready) 
#             dev.UpdateWireIns()  # Update the WireIns
#             break
#     # while True:
    
#     #     dev.UpdateWireOuts()
#     #     ack = dev.GetWireOutValue(0x22)  # Transfer the received data in result_sum variable
                
#     #     if (ack&1)==0:
            
#     #         print("The SAD Write1 is acked ")
#     #         if ((ack>>1)&1)==0:
                
#     #             print("The SUB is acked ")
#     #             if ((ack>>2)&1)==0:
                    
#     #                 print("The CNRL is acked ")
#     #                 if ((ack>>3)&1)==0:
                         
#     #                      print("The SAD Write2 is acked ")
#     #                      if ((ack>>4)&1)==0:
                              
#     #                           print("The Address is acked ")
           
#     #                           if ((ack>>5)&1)==0:
                                 
#     #                              print("The SAD Read is acked ")
            
#     #                              if ((ack>>6)&1)==0:
                                    
#     #                                 print("The DATA 1 is acked ")
#     #                                 if ((ack>>7)&1)==0:
#     #                                     print("The DATA 2 is acked ")
#     #                                     break
                                    
                                    
                                    
#     PC_Control = 0; # send a "stop" signal to the FSM
#     dev.SetWireInValue(0x00, PC_Control) 
#     data_ready=0;
#     dev.SetWireInValue(0x11, data_ready) 
#     dev.UpdateWireIns()  # Update the WireIns
#     time.sleep(1)  
#     # print("Send STOP signal to the FSM")    
                                     
#     dev.UpdateWireIns()  # Update the WireIns
#     dev.UpdateWireOuts()
#     SingleByteData1=dev.GetWireOutValue(0x21)
#     dev.UpdateWireOuts()
#     SingleByteData2=dev.GetWireOutValue(0x23)
#     dev.UpdateWireOuts()
#     SingleByteData3=dev.GetWireOutValue(0x24)                           
    
                                  
    
          
      
        
        
#     # %% 
#     # Since we are using a slow clock on the FPGA to compute the results
#     # we need to wait for the result to be computed          
    
     
    
#     PC_Control = 1; # send a "go" signal to the FSM
#     dev.SetWireInValue(0x00, PC_Control) 
#     dev.UpdateWireIns()  # Update the WireIns
#     # print("Send GO signal to the FSM")
    
#     Megnetic = 0x1E;
#     dev.SetWireInValue(0x03, Megnetic) 
    
#     meg_address=0x02;
#     dev.SetWireInValue(0x02, meg_address) 
    
#     meg_control=0x00;
#     dev.SetWireInValue(0x01, meg_control)
    
#     X_meg =0x83;
#     dev.SetWireInValue(0x04, X_meg)
#     byte1=0
#     dev.SetWireInValue(0x12, byte1)
#     dev.UpdateWireIns()  # Update the WireIns
    
#     dev.UpdateWireOuts()
#     go=dev.GetWireOutValue(0x27)
#     time.sleep(0.1)
    
    
         
    
#     while True:
#         if (go==1):
#             data_ready=1
#             dev.SetWireInValue(0x11, data_ready) 
#             dev.UpdateWireIns()  # Update the WireIns
#             break
#     # while True:
    
#     #     dev.UpdateWireOuts()
#     #     ack = dev.GetWireOutValue(0x22)  # Transfer the received data in result_sum variable
                
#     #     if (ack&1)==0:
            
#     #         print("The SAD Write1 is acked ")
#     #         if ((ack>>1)&1)==0:
                
#     #             print("The SUB is acked ")
#     #             if ((ack>>2)&1)==0:
                    
#     #                 print("The CNRL is acked ")
#     #                 if ((ack>>3)&1)==0:
                         
#     #                      print("The SAD Write2 is acked ")
#     #                      if ((ack>>4)&1)==0:
                              
#     #                           print("The Address is acked ")
           
#     #                           if ((ack>>5)&1)==0:
                                 
#     #                              print("The SAD Read is acked ")
            
#     #                              if ((ack>>6)&1)==0:
                                    
#     #                                 print("The DATA 1 is acked ")
#     #                                 if ((ack>>7)&1)==0:
#     #                                     print("The DATA 2 is acked ")
#     #                                     break
#     PC_Control = 0; # send a "stop" signal to the FSM
#     dev.SetWireInValue(0x00, PC_Control) 
#     data_ready=0;
#     dev.SetWireInValue(0x11, data_ready) 
#     dev.UpdateWireIns()  # Update the WireIns
#     # print("Send STOP signal to the FSM")
#     time.sleep(1)                               
    
#     dev.UpdateWireOuts()
#     SingleByteData4=dev.GetWireOutValue(0x25)
#     dev.UpdateWireOuts()
#     SingleByteData5=dev.GetWireOutValue(0x26)
#     dev.UpdateWireOuts()
#     SingleByteData6=dev.GetWireOutValue(0x28)   
#     #dev.UpdateWireOuts()
#     #SingleByteData4=dev.GetWireOutValue(0x25)
#     #dev.UpdateWireOuts()
#     #SingleByteData5=dev.GetWireOutValue(0x26)
#     time.sleep(0.1)
#     #temp=SingleByteData/16
       
#     def twos_comp(value):
#         if value >= 0x8000:
#             value-= 0x10000
#         return value
    
#     #for i in range(len(SingleByteData)):
#      #   signed_value=twos_comp(SingleByteData[i])
#     #    ACC_value[i]=signed_value/16000
#     signed_valueX=twos_comp(SingleByteData1)
#     ACC_valueX=signed_valueX/16000
    
#     signed_valueY=twos_comp(SingleByteData2)
#     ACC_valueY=signed_valueY/16000
    
#     signed_valueZ=twos_comp(SingleByteData3)
#     ACC_valueZ=signed_valueZ/16000
    
#     signed_valueXX=twos_comp(SingleByteData4)
#     ACC_valueXX=signed_valueXX/11000
#     signed_valueYY=twos_comp(SingleByteData5)
#     ACC_valueYY=signed_valueYY/11000
    
#     signed_valueZZ=twos_comp(SingleByteData6)
#     ACC_valueZZ=signed_valueZZ/9800
    
    
#     # print("X_acc is "+ str(float(ACC_valueX)))
#     print("Y_acc is "+ str(float(ACC_valueY)))
#     print("Z_acc is "+ str(float(ACC_valueZ)))
#     # print("X_meg is "+ str(float(ACC_valueXX)))
#     # print("Y_meg is "+ str(float(ACC_valueYY)))
#     # print("Z_meg is "+ str(float(ACC_valueZZ)))
    
    


dev.Close()
    
#%%