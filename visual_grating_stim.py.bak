# Import necessary packages
from psychopy import visual, core
from psychopy import visual, monitors
from psychopy import tools as tls
import numpy as np
import pandas as pd
import time as tm
import sys
import math

# Display visual grating
def run_visual_grating(filename,x_coord,y_coord):

    def find_stim_details(stim_types,stim_oris,num_repeats):
        num_trials = num_repeats*len(stim_types)*len(stim_oris)
        stim_details = np.zeros([num_trials,4])
        ID = 1
        for repeat in range(0,num_repeats):
            cond = 1
            for t in range(0,len(stim_types)):
                for o in range(0,len(stim_oris)):
                    stim_details[ID-1,] = [ID,cond,stim_types[t],stim_oris[o]]
                    cond = cond+1
                    ID = ID+1
        stim_details = stim_details.astype(int)
        return(stim_details)

    def choose_stim(win,stim_type,stim_ori,screen_size,cicle_size,spat_freq,circle_pos):
        if (stim_type==1):
            stim = visual.GratingStim(win, tex='sin', mask='circle', units='deg',size=circle_size, sf=spat_freq,
            name='gabor', autoLog=False, ori = stim_ori, pos=circle_pos) # classic stimulus
        elif (stim_type==2):
            stim = visual.GratingStim(win, tex='sin', units='deg',size=screen_size*2, sf=spat_freq,
                name='gabor', autoLog=False, ori = stim_ori) # inverse stimulus
        elif (stim_type==3):
            stim = visual.GratingStim(win, tex='sin', units='deg',size=screen_size*2, sf=spat_freq,
                name='gabor', autoLog=False, ori = stim_ori) # fullfield stimulus
        return(stim)


    # Set monitor details
    screen_size = np.array([1280,1024]) # size in pixels of screen
    monitor_name = 'Prolite' 
    monitor_width = 37.5 # screen width in cm
    view_dist = 15 # viewing distance in cm
    mon = monitors.Monitor(monitor_name,width=monitor_width,distance=view_dist)
    mon.setSizePix(screen_size)

    # Set experimental parameters
    trial_IDs_filepath = 'X:/cortical_dynamics/User/ms1121/Code/Psychopy/trial_IDs_' + filename + '.csv'
    stim_details_filepath = 'X:/cortical_dynamics/User/ms1121/Code/Psychopy/stim_details_' + filename +'.csv'
    stim_length = 1 # time of stimuli in seconds
    gap_length = 1.5 # gap time between stimuli in seconds
    spat_freq = 0.04 # spatial frequency of grating (cycles per degree)
    circle_size = 15 # angular diameter of circle stimuli (grating or grey)
    num_repeats = 10 # number of trials per condition
    use_new_IDorder = True
    stim_types = np.array([1,2,3]) # classical, inverse, or fullfield
    stim_oris = np.array([0,45,90,135,180,225,270,315]) # degree orientation of grating drift
    #stim_oris = np.array([0,0,0,0,0,0,0,0])
    
    # Convert given parameters into necessary units for psychopy
    circle_size = ((2*view_dist)*math.tan((circle_size/2)*(math.pi/180)))/2 # conversion of diameter degree to radius cm
    x_coord = x_coord*(monitor_width/screen_size[0]) # conversion of pix to cm
    x_coord = 2*(math.atan(x_coord/(2*view_dist))*(180/math.pi)) # conversion of cm to deg
    y_coord = y_coord*(monitor_width/screen_size[0]) # conversion of pix to cm
    y_coord = 2*(math.atan(y_coord/(2*view_dist))*(180/math.pi)) # conversion of cm to deg
    circle_pos = [x_coord, y_coord] # coordinate position of circle stimuli (input to function)

    # Set up stimulus
    win = visual.Window(monitor=mon,size=screen_size,screen=1)
    circle_size = tls.monitorunittools.deg2pix(circle_size,mon,correctFlat=False)
    grey_circ = visual.GratingStim(win,color=0,tex=None,mask='circle',units='deg',size=circle_size,pos=circle_pos)
    white_rec = visual.GratingStim(win,color=1,tex=None,units='pix',size=[300,250],pos=(0.5*screen_size[0],-0.5*screen_size[1])) # light stim for photodiode
    black_rec = visual.GratingStim(win,color=-1,tex=None,units='pix',size=[300,250],pos=(0.5*screen_size[0],-0.5*screen_size[1])) # dark stim for photodiode
    num_trials = num_repeats*len(stim_types)*len(stim_oris)
    stim_length = np.array(60*stim_length,dtype=int)
    gap_length = np.array(60*gap_length,dtype=int)
    trial_length = stim_length + gap_length 
    
    # Create matrix of details of each stimulus
        # Column 0 = signature ID number for each trial
        # Column 1 = condition number for each trial (16 possibilities)
        # Column 2 = stimulus type (classical (1), inverse (2), or fullfield (3))
        # Column 3 = stimulus orientation (8 possibilities)
    stim_details = find_stim_details(stim_types,stim_oris,num_repeats) 

    # Create and save, or load order for stimulus trials
    if (use_new_IDorder==True):
        print("NOTE: Using new stimulus order.")
        trial_IDs = np.array(stim_details[:,0]) # signature ID number for each trial
        np.random.shuffle(trial_IDs) # shuffle ID numbers into random order
        np.savetxt(trial_IDs_filepath,trial_IDs,delimiter=",") # save order of ID numbers
        np.savetxt(stim_details_filepath,stim_details,delimiter=",") # save stim details
    else:
        print("NOTE: Using saved stimulus order.")
        trial_IDs = pd.read_csv(trial_IDs_filepath, header=None) # load existing ID order
        trial_IDs = np.array(trial_IDs,dtype=int) # convert into usable data type

    # Run visual stimulation
    input("Press enter to run visual stimulation") # checkpoint for user input to continue
    trial_start = 1
    trial_end = trial_start+trial_length-1
    t2 = tm.time()
    for trial in range(0,num_trials): # for each trial
        #t1 = tm.time() # get start time
        ID = trial_IDs[trial] # find corresponding stim details 
        stim_type = stim_details[ID-1,2] # column 2 is stim type
        stim_ori = stim_details[ID-1,3] # column 3 is orientation angle
        stim = choose_stim(win,stim_type,stim_ori,screen_size,circle_size,spat_freq,circle_pos) # select appropriate stimulus
        for frame in range(trial_start,trial_end): # for each frame of that trial
            if (trial_start+(gap_length/2)) <= frame < (trial_start+stim_length+(gap_length/2)): # if between stimulus frames
                stim.phase += 0.03 # 3/10 waves per frame at 60FPS = 2Hz 
                stim.draw() # present stimulus
                white_rec.draw() # present white photodiode rectangle
                if (stim_type==2):
                    grey_circ.draw() # if inverse condition present grey circle over stimulus background
            else:
                black_rec.draw() # if gap frame then present black photodiode rectangle
            win.flip()
        trial_start = trial_end+1
        trial_end = trial_start+trial_length-1
        #elapsed = tm.time() - t1 # find time elapsed for that trial
        #print('Elapsed: %s' % elapsed)
    elapsed = tm.time() - t2
    print('Elapsed: %s' % elapsed)
    
    
# run function from command line with variable inputs
def main():
    function = sys.argv[1]
    if function == "run_visual_grating":
        filename = sys.argv[2]
        #animal = sys.argv[2]
        #date = sys.argv[3]
        #presentation = sys.argv[4]
        x_coord = int(sys.argv[3])
        y_coord = int(sys.argv[4])
        run_visual_grating(filename,x_coord,y_coord)

if(__name__=='__main__'):
    main()