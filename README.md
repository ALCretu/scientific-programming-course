# scientific-programming-course
Individual project using Psychtoolbox

Project for the 'Scientific Programming for Neuroeconomic course' 

Simple task investigating the influence of contextual cues on reaction time 

Participants observe blurred grasping pictures preceded by colored cues and have to decide which grasp type is being showed. They are instructed to respond as FAST AS POSSIBLE and they receive feedback in each trial, as soon as they press a button. The feedback consists of an emoticon appearing in the left side of the screen ':)' -> correct and ':(' -> error.

Information regarding the stimuli:
Grasps: precision grip (PG) or whole-hand grip (WHG)
Cues: white, blue and grey squares

Participants are instructed that two of the colors are associated with a specific grasp type:
while -> PG
blue -> WHG
They can use this information to respond faster (or, for the purpose of this experiment, we can at least hope they do use this information)

In reality, this is cue-grasp type association is valid in only 50% of the trials. In the other half, participants either observe these blue and white cues preceding the incorrect grasp type (25% of all trials: white -> WHG and blue -> PG) or grey cues which are neutral and are not associated with a specific grasp (25% of all trials). 

In the end we plot the percentage of correct, error and missed trials in a pie chart. Additionally, we calculate the average RT for the different types of trials and responses.

