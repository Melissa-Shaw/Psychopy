# Import necessary packages
from psychopy import visual, core
from psychopy import visual, monitors
import numpy as np
import pandas as pd
import time as tm
import sys

def run_receptive_mapping(filename):

    def find_stim_positions(screen_size,stim_size,change_axis,num_strips): 
        if (change_axis=='y'):
            ax = 2 # x position stays constant, change y position
        elif(change_axis=='x'):
            ax = 1 # y position stays constant, change x position
        coord_pos_1 = np.zeros([num_strips,3])
        coord_pos_1[:,0] = ax
        coord_pos_2 = np.zeros([num_strips,3])
        coord_pos_2[:,0] = ax
        pos = 0
        stripe_1 = 0.5*screen_size[ax-1] - 0.5*stim_size[ax-1]
        for strip in range(0,num_strips):
                coord_pos_1[pos,ax] = stripe_1
                stripe_2 = stripe_1 - stim_size[ax-1]
                coord_pos_2[pos,ax] = stripe_2
                stripe_1 = stripe_1 - 2*stim_size[ax-1]
                pos = pos + 1
        return(coord_pos_1,coord_pos_2)

    # Set experimental parameters
    stimID_filepath = 'X:/cortical_dynamics/User/ms1121/Code/Psychopy/rec_map_stimID_' + filename + '.csv'
    stim_details_filepath = 'X:/cortical_dynamics/User/ms1121/Code/Psychopy/rec_map_stim_details_' + filename + '.csv'
    trial_length = 1 # trial length in seconds
    gap_length = 1.5 # gap length between stimuli in seconds
    switch_freq = 4 # frequency of alternating tile colours (Hz)
    stim_types = np.array([1,2],dtype=int) # white on left + black on right, white on right + black on left
    grid_dim = np.array([5,5],dtype=int) # row and column grid dimensions (e.g. [4,4] = 4x4 grid  = 16 positions)
    num_strips = 5
    num_repeats = 15 # number of repeats of all stimuli
    use_new_IDorder = True

    # Set monitor details
    screen_size = np.array([1280,1024]) # x,y size in pixels of screen
    monitor_name = 'Prolite' 
    monitor_width = 37 # screen width in cm
    view_dist = 15 # viewing distance in cm
    mon = monitors.Monitor(monitor_name,width=monitor_width,distance=view_dist)
    mon.setSizePix(screen_size)

    # Set up stimulus
    win = visual.Window(monitor=mon,size=screen_size,screen=1)
    total_strips = np.array(2*num_strips)
    hz_stim_size =  np.array([screen_size[0],screen_size[1]/total_strips],dtype=int) # size of stim to fit strip position (y_size/total_num_strips)
    vt_stim_size = np.array([screen_size[0]/total_strips,screen_size[0]],dtype=int) # size of stim to fit strip position (x_size/total_num_strips)
    num_pos = np.array(2*num_strips*num_repeats)
    num_switches = np.array(switch_freq*trial_length,dtype=int)
    switch_length = np.array(60/switch_freq,dtype=int)
    half_gap_length = np.array(0.5*60*gap_length,dtype=int)
    white_rec = visual.GratingStim(win,color=1,tex=None,units='pix',size=[300,250],pos=(0.5*screen_size[0],-0.5*screen_size[1])) # light stim for photodiode
    black_rec = visual.GratingStim(win,color=-1,tex=None,units='pix',size=[300,250],pos=(0.5*screen_size[0],-0.5*screen_size[1])) # dark stim for photodiode

    [hz_coord_1,hz_coord_2] = find_stim_positions(screen_size,hz_stim_size,'y',num_strips)
    [vt_coord_1,vt_coord_2] = find_stim_positions(screen_size,vt_stim_size,'x',num_strips)
    coord_1 = np.vstack((hz_coord_1,vt_coord_1))
    coord_2 = np.vstack((hz_coord_2,vt_coord_2))

    # Create and save, or load order for stimulus trials
    if (use_new_IDorder==True):
        print("NOTE: Using new stimulus order.")
        stim_details = np.hstack((coord_1,coord_2))
        stimID_short = np.arange(1,len(stim_details)+1)
        stimID_short = stimID_short.reshape(len(stim_details),1) # change to vertical array
        stim_details = np.append(stimID_short,stim_details,axis=1) # make stim_details matrix of [ID,stim_type_1,x_coord_1,y_coord_1,stim_type_2,x_coord_2,y_coord_2] 
        stimID = stimID_short
        for rep in range(1,num_repeats):
            stimID = np.append(stimID,stimID_short)
        print(len(stimID))
        np.random.shuffle(stimID)
        np.savetxt(stimID_filepath,stimID,delimiter=",") # save randomised order of ID numbers
        np.savetxt(stim_details_filepath,stim_details,delimiter=",") # save stim details
    elif (use_new_IDorder==False):
        print("NOTE: Using saved stimulus order.")
        stimID = pd.read_csv(stimID_filepath, header=None) # load existing ID order
        stimID = np.array(stimID,dtype=int) # convert into usable data type
        stim_details = pd.read_csv(stim_details_filepath, header=None) # load existing ID order
        stim_details = np.array(stim_details,dtype=int) # convert into usable data type

    # Run visual stimulation
    input("Press enter to run receptive mapping stimulation") # checkpoint for user input to continue
    t2 = tm.time()
    for pos in range(0,num_pos):
        #t1 = tm.time()
        ID = stimID[pos]
        stim_type = stim_details[ID-1,1]
        if (stim_type==2):
            stim_size = hz_stim_size
        elif (stim_type==1):
            stim_size = vt_stim_size
        for frame in range(0,half_gap_length):
            black_rec.draw() # black photodiode signal
            win.flip()
        for switch in range(0,num_switches):
            if (switch%2 == 0): # if switch is even
                colour_1 = 1 # white
                colour_2 = -1 # black
            else: # if switch is odd
                colour_1 = -1 # black
                colour_2 = 1 # white
            rec_1 = visual.GratingStim(win,color=colour_1,tex=None,units='pix',size=stim_size,pos=stim_details[ID-1,(2,3)]) 
            rec_2 = visual.GratingStim(win,color=colour_2,tex=None,units='pix',size=stim_size,pos=stim_details[ID-1,(5,6)])
            for frame in range(0,switch_length):
                rec_1.draw() 
                rec_2.draw()
                white_rec.draw() # white photodiode signal
                win.flip()
        for frame in range(0,half_gap_length):
            black_rec.draw() # black photodiode signal
            win.flip()
        #elapsed = tm.time() - t1 # find time elapsed for that trial
        #print('Elapsed: %s' % elapsed)
    elapsed = tm.time() - t2 # find time elapsed for full stimulus presentation
    print('Elapsed: %s' % elapsed)


# run function from command line with variable inputs
def main():
    function = sys.argv[1]
    if function == "run_receptive_mapping":
        filename = sys.argv[2]
        #date = sys.argv[3]
        run_receptive_mapping(filename)

if(__name__=='__main__'):
    main()