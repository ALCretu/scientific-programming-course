%% 15/12/2017 Andreea Loredana Cretu with inspiration from http://peterscarfe.com/fadingtexturedemo.html :)
%%% Individual Project for Scientific programming course %%%
%%% Participants have to observe two types of blurred grasping picture stimuli preceded by
%%% colored cues and to decide which grasp type is being showed

%%% YOU CAN EXIT THE EXPERIMENT AT ANY TIME BY PRESSING 'ESC'
sca;
clc

try
    A = input('UserName (1 = ALCretu; 2 = Guest): ');
    switch(A) %% use this when you want to have different situations; for example: testing the code in the behav lab, fMRI or personal computer
        case 1
            disp ('AL Cretu running the code');
            pname = '/Users/acretu/Documents/PhD/Courses/Scientific programming/Scientific-Programming/';
        case 2
            disp ('Guest running the code')
            [fname,pname] = uigetfile('*.png','Select the two pictures ', 'MultiSelect', 'on'); %uigetfile will open dialogue box entitled 'Select Excel files' and displays only .xlsx files
            cd(pname);
        otherwise
            disp ('Unknown user')
    end
    
    %% some variables
    test = input('Screen size (1 = small; 2 = fullscreen): '); %% this just indicates which screen size to use: test=1 ->> small screen size used for testing; test=2 ->> normal size screen
    Trials = 32; %% to make things easier, we predefine the nr of Trialss
    %% seed random number generator
    rng('shuffle');
    %% Enter partipant number %%%
    fail1 = 'Program aborted. Participant number not entered'; % error message which is printed to command window
    prompt = {'Enter participant number:'};
    dlg_title = 'New Participant';
    num_lines = 1;
    def = {'0'};
    answer = inputdlg(prompt,dlg_title,num_lines,def); %presents box to enter data into
    switch isempty(answer)
        case 1 %deals with both cancel and X presses
            or(fail1)
        case 0
            thissub=(answer{1});
    end  
    
    %% make filenames and individual directories
    results = ['IndivProject_sub_' thissub '_T_' num2str(Trials) '.dat' ];
    results2 = ['IndivProject_sub_' thissub '_T_' num2str(Trials) '.mat' ];
    Data.SessionInfo = ['Sub:' thissub '/Trials:' num2str(Trials) '-Date:' datestr(now)]; %% extra information about the experiment
    indiv_folder = ['Results Sub' thissub];
    mkdir(indiv_folder); %make directory for each subject
    
    %% psychtoolbox setup
    % Here we call some default settings for setting up Psychtoolbox
    Screen('Preference', 'SkipSyncTests', 1);
    % Give Matlab high priority
    Priority(2); 
    %Make sure keys are recognized across different operating systems
    KbName('UnifyKeyNames'); 
    % Get the screen numbers
    screens = Screen('Screens');
    % Draw to the external screen if avaliable
    screenNumber = max(screens);
    % Define black and white
    black = BlackIndex(screenNumber);  
    
    %% Open a screen window and get some info about its size and flip time
    %Define some variables which deal with the location of the elements on the screen (to make sure that all elements are visible when we use the small window)
    if test == 1
        SmallWindow  = [0, 0, 600, 600];
        [win, windowRect] = PsychImaging('OpenWindow', screenNumber, black, SmallWindow );
        feedback_X = 400;
        feedback_Y = 100;
    elseif test ==2
        [win, windowRect] = PsychImaging('OpenWindow', screenNumber, black);
        feedback_X = 600;
        feedback_Y = 150;
    end
    % Get the size of the on screen window
    CompScreen = get(0,'ScreenSize'); % Find out the size of this computer screen
    % Query the frame duration
    ifi = Screen('GetFlipInterval', win); 
    % Set up alpha-blending for smooth (anti-aliased) lines
    Screen('BlendFunction', win, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    % Sync us and get a time stamp
    vbl = Screen('Flip', win);
    waitframes = 1;
    % Get the centre coordinate of the window
    [centreX, centreY] = RectCenter(windowRect);  
    
    %% define order of the picture stimuli
    order = [1*ones((Trials/4),1); 2*ones((Trials/4),1);3*ones((Trials/8),1); 4*ones((Trials/8),1); 5*ones((Trials/8),1); 6*ones((Trials/8),1)]; %% PG
    pictureOrder = order(randperm(length(order)));
    %%%% Conditions %%%
    %     1 = PG correct: white cue
    %     2 = WHG correct: blue cue
    %     3 = WHG error: white cue
    %     4 = PG error: blue cue
    %     5 = PG neutral: gray cue
    %     6 = WHG neutral: gray cue
    %% define colors and color cue order
    white = WhiteIndex(win);
    gray =GrayIndex(win);
    blue = [15 75 256];
    colors = {white;blue;white;blue;gray;gray}; %following the order of moviename from below; with red in between: this is just because I didn't want to use conditions 1,2,3,4.. and preferred to have 1,2 = correct and 10,20=error
    centeredRect = CenterRectOnPointd([0 0 536 576], centreX, centreY);%% size of the colored cue
    RectFeedback= CenterRectOnPointd([0 0 200 200], centreX-feedback_X, feedback_Y); %size of feedback: thumbs up/down
    RectFeedback= CenterRectOnPointd([0 0 200 200], centreX-600, 150); %size of feedback: thumbs up/down
    
    %% Fixation cross info
    % Here we set the size of the arms of our fixation cross
    fixCrossDimPix = 40;
    % Now we set the coordinates (these are all relative to zero we will let
    % the drawing routine center the cross in the center of our monitor for us)
    xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
    yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
    allCoords = [xCoords; yCoords];
    % Set the line width for our fixation cross
    lineWidthPix = 4;
    
    %% jitters: we use a random duration for the cue and fixation cross so that participants don't anticipate when the picture will appear =>> they should not prepare an answer
    jitterBreak_vector=[1.5*ones(length(pictureOrder)/4,1);2*ones(length(pictureOrder)/4,1); 2.5*ones(length(pictureOrder)/4,1); 3*ones(length(pictureOrder)/4,1)]'; %%time in seconds: between 1.5-3 with a mean of 2.25
    jitterCue_vector=[0.75*ones(length(pictureOrder)/4,1);1*ones(length(pictureOrder)/4,1); 1.25*ones(length(pictureOrder)/4,1); 1.5*ones(length(pictureOrder)/4,1)]'; %%time in seconds: between 0.75-1.5 with a mean of 1.125
    
    jitterBreak=jitterBreak_vector(randperm(length(jitterBreak_vector)));
    jitterCue=jitterCue_vector(randperm(length(jitterCue_vector)));  
    
    %% all the picture stimuli used in the experiment
    Stim_pic{1,1}= imread([pname 'PG_end.png']);
    Stim_pic{2,1}= imread([pname 'WHG_end.png']);
    Stim_pic{3,1}= imread([pname 'WHG_end.png']);
    Stim_pic{4,1}= imread([pname 'PG_end.png']);
    Stim_pic{5,1}= imread([pname 'PG_end.png']);
    Stim_pic{6,1}= imread([pname 'WHG_end.png']);
    Response_correct=imread([pname 'Correct.png']);
    Response_error=imread([ pname 'Error.png']);
    instruction= imread([pname 'Instruction.png']);
    Tips= imread([pname 'TIP.png']);
    ButtonPress= imread([pname 'Key_press.png']);
    
    %% Save some vectors which do not change during the experiment: we don't use these for analysis but it's good to have them :)
    Data.pictureOrder=pictureOrder';
    Data.BreakOrder=jitterBreak;
    Data.CueOrder=jitterCue;
    
    %% Open Screen
    Screen('FillRect', win, black);
    HideCursor;
    %set default screen font and size for written messages
    Screen('TextSize', win, 24);
    Screen('TextFont', win, 'Calibri');
    % Maximum priority level
    topPriorityLevel = MaxPriority(win);
    Priority(topPriorityLevel); 
    
    %% % instruction screen
    Texture_i = Screen('MakeTexture', win, instruction);
    Screen('DrawTextures', win, Texture_i, [],[], 0);
    DrawFormattedText( win, '< Press any key to continue >','center', centreY+450, [100, 130, 150]);
    Screen(win, 'Flip'); % present to the screen. This is the command to actually present whatever you have made 'win'
    WaitSecs(.5); % this avoids participants accidently pressing too quickly and moving the experiment on
    KbWait;
    WaitSecs(.5);
    
    %% % tips screen
    Texture_t = Screen('MakeTexture', win, Tips);
    Screen('DrawTextures', win, Texture_t, [],[], 0);
    DrawFormattedText( win, '< Press any key to continue >','center', centreY+450, [100, 130, 150]);
    Screen(win, 'Flip'); % present to the screen. This is the command to actually present whatever you have made 'win'
    WaitSecs(.5); % this avoids participants accidently pressing too quickly and moving the experiment on
    KbWait;
    WaitSecs(.5);
    
    %% % button press screen
    Texture_b = Screen('MakeTexture', win, ButtonPress);
    Screen('DrawTextures', win, Texture_b, [],[], 0);
    DrawFormattedText( win, '< Press any key to continue >','center', centreY+450, [100, 130, 150]);
    Screen(win, 'Flip'); % present to the screen. This is the command to actually present whatever you have made 'win'
    WaitSecs(.5); % this avoids participants accidently pressing too quickly and moving the experiment on
    KbWait;
    WaitSecs(.5);
     
    %*************************************************************************
    %Setup KbQueue and KbKeys
    %*************************************************************************
    PGKey = KbName('LeftArrow');
    WHGKey = KbName('RightArrow');
    escapeKey = KbName('ESCAPE');
    KbQueueCreate();	% New queue
    %% start experiment
    exitExperiment = 0;
    TrialState = 1; %%1=fixation cross start exp; 2=cue; 3=picture; 4=break; 5 =final fixation
    TrialNr = 0;
    D = [];
    ii = 0;
    %%open data file for writting data
    cd(indiv_folder)
    dataFilePointer = fopen(results,'wt'); % open ASCII file for writing
    %%get current time and start delivering keyboard events
    experimentStartTime = GetSecs();
    KbQueueStart;
    %% start experiment
    while 1
        TrialStartTime = GetSecs();
        answer=0;
        response = false;
        if TrialState ~= 1
            TrialNr = TrialNr + 1; %% we record this trial number and we want it to start at 1 when the first cue appears on screen
            ii = ii + 1;
        end  
        %% code regarding the fading of the picture
        % picture will fade in and out with a sine wave function
        amplitude = 0.5;
        frequency = 0.1;
        angFreq = 2 * pi * frequency;
        startPhase = 5;
        time=0;
        while 1 %% we first define different states which put the different parts of the experiment (cue, pictures...) in memory 
            % we only use Screen('Flip') once at the end 
            % this loop will run at the frequency of the refresh rate so it should accurately record button presses
            if ii > length(pictureOrder) %% if ii > maximum number of trials go directly to state 5 (which is our final fixation cross)
                TrialState = 5;
            end
            
            % Check the keyboard to see if a button has been pressed
            [pressed, keyCode] = KbQueueCheck;
            % check for exit request
            if keyCode(escapeKey)
                exitExperiment = true;
                break
            end
            
            % check for response to question
            if TrialState==3 && response==false
                if keyCode(PGKey) && (pictureOrder(ii)==1 || pictureOrder(ii)==4 || pictureOrder(ii)==5)
                    answer = 1;  % record response in .dat file : 1=correct; 2=error
                    response = true;
                elseif keyCode(WHGKey) && (pictureOrder(ii)==2 || pictureOrder(ii)==3 || pictureOrder(ii)==6)
                    answer = 1;
                    response = true;
                elseif keyCode(WHGKey) || keyCode(PGKey)
                    answer = 2;
                    response = true;
                end
            end
            
            %% Determine Trials state
            if TrialState == 1 %% start of the experiment
                Screen('DrawLines', win, allCoords,lineWidthPix, white, [centreX centreY], 2);
                DrawFormattedText( win, 'Experiment Starting Soon...','center', 250, [100, 130, 150]);
                DrawFormattedText( win, 'GET READY!','center', 450, [100, 130, 150]);
            elseif TrialState == 2 %% cue presentation
                color=colors{pictureOrder(ii),1};
                Screen('FillRect', win, color, centeredRect)
            elseif TrialState ==3 %% picture presentation
                Texture_final = Screen('MakeTexture', win, Stim_pic{pictureOrder(ii)});
                thisContrast = amplitude * sin(angFreq * time + startPhase) + amplitude;
                Screen('DrawTextures', win, Texture_final, [],[],0,[],thisContrast)
                time = time + ifi; 
                
                if response == true && answer ==1%% show 'correct' feedback
                    Texture_resp = Screen('MakeTexture', win, Response_correct);
                    Screen('DrawTextures', win, Texture_resp, [],RectFeedback)
                elseif response == true && answer ==2%% show 'error' feedback
                    Texture_resp = Screen('MakeTexture', win, Response_error);
                    Screen('DrawTextures', win, Texture_resp, [],RectFeedback)
                end
                
            elseif TrialState == 4 %% fixation cross
                Screen('DrawLines', win, allCoords,lineWidthPix, white, [centreX centreY], 2);
            elseif TrialState==5
                Screen('DrawLines', win, allCoords,lineWidthPix, white, [centreX centreY], 2);
                DrawFormattedText( win, '< End of Experiment >','center', 250, [100, 130, 150]);
            end
            
            %% start of timing part
            if TrialState == 1 && (GetSecs()-TrialStartTime>3)%% only show the initial fixation cross on the screen for 3 seconds: allow the participant to get read
                startnewTrials=GetSecs();
                TrialState = 2;
                break;
            elseif TrialState == 2 && (GetSecs()-startnewTrials>jitterCue(ii))%%show the cue on the screen for a jittered duration previously defined
                CueTime = GetSecs();
                TrialState = 3;
            elseif TrialState == 3  && GetSecs() - CueTime >3 %%show the picture on the screen for 3 seconds
                ResponseStartTime = GetSecs();
                TrialState = 4;
            elseif TrialState == 4 && (GetSecs()-ResponseStartTime>jitterBreak(ii))%%show the fixation cross on the screen for a jittered duration previously defined
                startnewTrials=GetSecs();
                TrialState = 2;
                break;
            elseif TrialState==5 && (GetSecs()-experimentStartTime >200) %%total duration of the experiment
                exitExperiment = true;
                break;
            end
            
            %% finally flip the screen 
            vbl  = Screen('Flip', win, vbl + (waitframes - 0.5) * ifi);
            
            %%  write data in the file
            if TrialNr < 1 || TrialState==1 || TrialState==5
                writeData = [vbl, TrialNr, TrialState, answer, 0]';
            else
                writeData = [vbl, TrialNr, TrialState, answer, pictureOrder(ii)]';
            end
            fprintf(dataFilePointer, '%6.2f %i %i %i %i\n', writeData);
        end
        %% record time at the end of the experiment (or if experiment is exited prematurely)
        if exitExperiment == true;
            expEndTime=GetSecs();
            break
        end
        
    end
    % display total duration
    Data.TotalDuration=expEndTime - experimentStartTime; %% this should be 200s -- but it allows us to see possible delays (it's probably useless)
    KbQueueRelease;
    sca;
    % clean up
    ShowCursor;
    Priority(0);
    sca;
    fclose('all');
    close all;
    %% Create results file
    Data.Sub_Trials=[str2double(thissub) str2double(Trials)];
    disp(['Data for subject ' num2str(thissub) 'saved'])
    cd([pname indiv_folder])
    save(results2, '-struct', 'Data');
catch err
    ShowCursor;
    Priority(0);
    sca;
    fclose('all');
    close all;
    rethrow(err);
end
if TrialNr >= Trials %% only run the following part if the whole experiment was executed
analysis = input('Analyse data and plot some results? (1=YES): '); %% this just indicates which screen size to use: test=1 ->> small screen size used for testing; test=2 ->> normal size screen
if analysis==1
    
    %% Analysis part
    cd([pname indiv_folder])
    data = load(results);
    timestamp = data(:,1)-data(1,1); %% we do this subtraction so that the timestamps start at 0
    trialNr = data(:,2); % from 1-32
    trialState = data(:,3); % 1=fixation cross at star of experiment, 2=cue, 3=fading picture / keypress, 4=break, 5=final fixation cross
    answer = data(:,4); %% 1= correct; 2= error
    picture = data(:,5); %% Conditions below:
    %     1 = PG correct: white cue
    %     2 = WHG correct: blue cue
    %     3 = WHG error: white cue
    %     4 = PG error: blue cue
    %     5 = PG neutral: gray cue
    %     6 = WHG neutral: gray cue
    
    Given_RespTime = nan(max(trialNr),1); %% we build some matrices and then just add elements to them
    Missed_RespTime = nan(max(trialNr),1); %% we build some matrices and then just add elements to them
    Response_option = nan(max(trialNr),1);
    flipResp = nan(max(trialNr),1); %% this matrix will contain the time when the picture appeared on the screen
    RT = nan(max(trialNr),1); %% we have in total 32 trials but the first and last are just the 'start Experiment' and 'end Experiment' so don't need them
    Picture_option = nan(max(trialNr),1);
    
    for trial_id = 1:max(trialNr)                                                 % find(..., 1) 1 steht f?r wie viele werde es aus der m?glichen liste nimmt, hier also nur den ersten.
        flipResp(trial_id,1) = timestamp(find(trialNr == trial_id & trialState == 3,1)); %% we write 'trialNr == trial_id+1' because we want to start from trialNr=2 but we need index 1 for each matrix (for example, 'flipResp(trial_id,1)', cannot start at 2)
        if timestamp(find(trialNr == trial_id & trialState == 3 & answer,1))
            Given_RespTime(trial_id,1) = timestamp(find(trialNr == trial_id & trialState == 3 & answer, 1)); %value von timestamp (Zeit) wenn trialNr gleich trial_id ist und trialState gleich 5-> response und jemand dr?ckt answer?0
            RT(trial_id,1) = Given_RespTime(trial_id,1) - flipResp(trial_id,1);
            Response_option(trial_id,1) = answer(find(trialNr == trial_id & trialState == 3 & answer, 1));
            Picture_option(trial_id,1) = picture(find(trialNr == trial_id & trialState == 3 & answer, 1));
        else
            Missed_RespTime(trial_id,1) = timestamp(find(trialNr == trial_id & trialState == 3 & answer==0, 1)); %value von timestamp (Zeit) wenn trialNr gleich trial_id ist und trialState gleich 5-> response und jemand dr?ckt answer?0
        end
    end
    
    Performance.MissedResp = length(find(~isnan(Missed_RespTime)));
    Performance.GivenResp = max(trialNr)-Performance.MissedResp;
    Performance.CorrectResp = length(find(Response_option==1));
    Performance.ErrorResp = length(find(Response_option==2));
    Performance.AccuracyPercentage = (Performance.CorrectResp *100)/max(trialNr);
    
    %% Plot number of trials, RTs of error and correct trials and RTs of trials preceded by correct cue, by error cue or neutral cue
    figure;
    my_cols = [0 0.4980 0; 1 1 0; 0.8 0 0]; %% specific colors for each part of the pie chart
    subplot(2,3,1);p = pie([Performance.CorrectResp,Performance.MissedResp, Performance.ErrorResp]);  title('% of Trials'); legend({'Correct','Missed','Error'},'Location','southoutside','Orientation','horizontal')
    p(1).FaceColor = my_cols(1,:);
    p(3).FaceColor = my_cols(2,:);
    p(5).FaceColor = my_cols(3,:);
    subplot(2,3,2); boxplot(RT(Response_option==1)); title('All correct trials');ylim([0 3])
    subplot(2,3,3); boxplot(RT(Response_option==2)); title('All error trials');ylim([0 3])
    subplot(2,3,4); boxplot(RT(Picture_option==1 | Picture_option==2)); title('Cued correct trials');ylim([0 3])
    subplot(2,3,5); boxplot(RT(Picture_option==3 | Picture_option==4)); title('Cued error trials');ylim([0 3])
    subplot(2,3,6); boxplot(RT(Picture_option==5 | Response_option==6)); title('Neutral trials');ylim([0 3])
else
    disp('End of experiment. Goodbye! ');  
end
end