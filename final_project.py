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
WR_V =[255,0, 0 , 3 , 44,240 ,10 , 2,9  ,2 , 187,240,10,112,98 ,34 ,64 ,94 ,110,91 ,82 ,80 , 91];
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
   
 
 
 
 
 # if 
 # motor_line = 0; # send a "stop" signal to the FSM
 # dev.SetWireInValue(0x00, motor_line) 
 # dev.UpdateWireIns() # Update the WireIns
 
 
 
 



#%% 

# buf = bytearray(315392);

# intensity_values = []
# noise_list =[]
# start_time = time.time();
# for f in range(1000):
#     dev.SetWireInValue(0x05, 1)  # Reset FIFOs and counter
#     dev.UpdateWireIns()
    
#     dev.SetWireInValue(0x05, 0)  # Release reset signal
#     dev.UpdateWireIns()

#     # Read the frame data from the FPGA
#     dev.ReadFromBlockPipeOut(0xa0, 1024, buf)
    
#     im = np.array(buf, dtype=np.uint8)
#     im = im[:-(464+648*10)]  # Adjust frame size
#     im = im.reshape((476, 648))  # Reshape to the correct image dimensions
    
#     # Find the brightest pixel
#     min_val, max_val, min_loc, max_loc = cv2.minMaxLoc(im)
    
#     intensity = im[50, 50]  # Access pixel (50, 50)
#     intensity_values.append(intensity)
    
#     # Draw a square around the brightest pixel
#     square_size = 40  # Size of the square to draw around the brightest pixel
#     top_left = (max_loc[0] - square_size //2 , max_loc[1] - square_size //2 )
#     bottom_right = (max_loc[0] + square_size //2, max_loc[1] + square_size //2)
    
#     # Ensure the square stays within image boundaries
#     top_left = (max(0, top_left[0]), max(0, top_left[1]))
#     bottom_right = (min(im.shape[1] - 1, bottom_right[0]), min(im.shape[0] - 1, bottom_right[1]))
    
#     # Draw the square around the brightest pixel
#     cv2.rectangle(im, top_left, bottom_right, (256, 256, 256 ), 2) 
    
#     center_right = 5* im.shape[1] // 9
#     center_left =  4*im.shape[1] // 9
#    # Check if the brightest pixel is to the left or right of the center
#     if (center_left< max_loc[0]):
#            motor_line = 2  # Left of the cente
#     if ( max_loc[0] < center_right):
#            motor_line = 1  # Right of the cente
           
#     if ( center_left< max_loc[0] < center_right):
#           motor_line = 0  # Right of the center
   
#     dev.SetWireInValue(0x00, motor_line) 
#     dev.UpdateWireIns() # Update the WireIns
#    # Show the motor signal
#     cv2.putText(im, f'Motor Line: {motor_line}', (50, 100), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 2)

    
#     # Display the brightest pixel coordinates
#     cv2.putText(im, f'Brightest Pixel: {max_loc}', (50, 50), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 2)
    
#     # Show the current frame
#     cv2.imshow('Brightest Spot Tracking', im)
    
#     # Exit if 'p' is pressed
#     if cv2.waitKey(1) & 0xFF == ord(' '):
#         break

# motor_line = 0  # Right of the center
# dev.SetWireInValue(0x00, motor_line) 
# dev.UpdateWireIns() # Update the WireIns
# end_time = time.time()
# cv2.destroyAllWindows()
# print(f"Tracking finished. Time took: {end_time - start_time:.2f} seconds")
      
   
# noise_list = [float(intensity) for intensity in intensity_values]

# # Plot the intensity values over the frames
# plt.plot(range(len(noise_list)), noise_list, marker='o')
# plt.xlabel('Frame Number')
# plt.ylabel('Pixel Intensity (50,50)')
# plt.title('Intensity at Pixel (50,50) over Frames')
# # plt.grid(True)
# plt.show()


buf = bytearray(315392)
intensity_values = []
noise_list = []
frame_differences = []  # To store frame-to-frame differences
start_time = time.time()

previous_frame = None  # Store the previous frame for temporal analysis

for f in range(1000):
    dev.SetWireInValue(0x05, 1)  # Reset FIFOs and counter
    dev.UpdateWireIns()
    
    dev.SetWireInValue(0x05, 0)  # Release reset signal
    dev.UpdateWireIns()

    # Read the frame data from the FPGA
    dev.ReadFromBlockPipeOut(0xa0, 1024, buf)
    
    im = np.array(buf, dtype=np.uint8)
    im = im[:-(464 + 648*10)]  # Adjust frame size
    im = im.reshape((476, 648))  # Reshape to the correct image dimensions
    
    # Find the brightest pixel
    min_val, max_val, min_loc, max_loc = cv2.minMaxLoc(im)
    
    # Track intensity at pixel (50, 50)
    intensity = im[50, 50]  # Access pixel (50, 50)
    intensity_values.append(intensity)
    
    # Detect spatial noise: Local variance around the brightest pixel
    square_size = 40  # Size of the square to check for variance
    top_left = (max_loc[0] - square_size // 2, max_loc[1] - square_size // 2)
    bottom_right = (max_loc[0] + square_size // 2, max_loc[1] + square_size // 2)
    top_left = (max(0, top_left[0]), max(0, top_left[1]))
    bottom_right = (min(im.shape[1] - 1, bottom_right[0]), min(im.shape[0] - 1, bottom_right[1]))
    
    region = im[top_left[1]:bottom_right[1], top_left[0]:bottom_right[0]]
    region_variance = np.var(region)  # Variance in pixel intensity in the region
    noise_list.append(region_variance)  # Store the local variance as noise estimate
    
    # Draw a square around the brightest pixel
    cv2.rectangle(im, top_left, bottom_right, (256, 256, 256), 2)
    
    center_right = 5 * im.shape[1] // 9
    center_left = 4 * im.shape[1] // 9
    
    # Check if the brightest pixel is to the left or right of the center
    if center_left < max_loc[0]:
        motor_line = 2  # Left of the center
    if max_loc[0] < center_right:
        motor_line = 1  # Right of the center
    if center_left < max_loc[0] < center_right:
        motor_line = 0  # Center
    
    # Send motor line signal
    dev.SetWireInValue(0x00, motor_line)
    dev.UpdateWireIns()
    
    # Display the motor line on the image
    cv2.putText(im, f'Motor Line: {motor_line}', (50, 100), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 2)
    
    # Display the brightest pixel coordinates
    cv2.putText(im, f'Brightest Pixel: {max_loc}', (50, 50), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 2)
    
    # Show the current frame
    cv2.imshow('Brightest Spot Tracking', im)
    
    # Exit if 'p' is pressed
    if cv2.waitKey(1) & 0xFF == ord(' '):
        break
    
    # Temporal noise detection: Frame-to-frame differences
    if previous_frame is not None:
        # Calculate difference between the current and previous frame
        frame_diff = cv2.absdiff(im, previous_frame)
        frame_diff_sum = np.sum(frame_diff)  # Sum of absolute differences
        frame_differences.append(frame_diff_sum)  # Store the difference for later analysis
    
    # Update the previous frame for next iteration
    previous_frame = im.copy()

# Final motor line reset
motor_line = 0  # Center
dev.SetWireInValue(0x00, motor_line)
dev.UpdateWireIns()
end_time = time.time()
cv2.destroyAllWindows()
print(f"Tracking finished. Time took: {end_time - start_time:.2f} seconds")

# Plot intensity values at (50, 50) over the frames (Temporal Noise)
plt.figure(figsize=(12, 6))
plt.subplot(1, 2, 1)
plt.plot(range(len(intensity_values)), intensity_values, marker='o')
plt.xlabel('Frame Number')
plt.ylabel('Pixel Intensity (50,50)')
plt.title('Intensity at Pixel (50,50) over Frames')

# Plot the variance (spatial noise) over the frames
plt.subplot(1, 2, 2)
plt.plot(range(len(noise_list)), noise_list, marker='o')
plt.xlabel('Frame Number')
plt.ylabel('Local Variance (Spatial Noise)')
plt.title('Spatial Noise Variance over Frames')

plt.tight_layout()
plt.show()

# Plot the frame-to-frame difference (Temporal Noise)
plt.figure(figsize=(6, 6))
plt.plot(range(len(frame_differences)), frame_differences, marker='x')
plt.xlabel('Frame Number')
plt.ylabel('Frame Difference Sum (Temporal Noise)')
plt.title('Frame-to-Frame Differences (Temporal Noise)')
plt.show()

dev.Close