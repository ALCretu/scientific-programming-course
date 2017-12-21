# scientific-programming-course
Individual Project for the 'Scientific Programming for Neuroeconomic course' 

#### Disclaimer: this is not an valid scientific task. It was just created for the purpose of this course to illustrate different concepts learned in the practical lessons ####

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

 Analysing this design from a bayesian perspective allows us to classify the colored cues as 'priors' while the blurred pictures represent the 'likelihood'. Therefore, in order to take a decision regarding the correct grasp type, participants combine these two sources of information. When a blue or a white cue appears, this is considered to be an informative prior because it allows the participant to predict the upcoming grasp type with a high accuracy. In exchange, grey cues are completely uninformative therefore, participants should pay more attention to the actual picture.

In conclusion, we expect the following results:
1. RT of error trials should be shorter than correct trials.We expect participants to be faster when they commit an error because, according to the experimental manipulations, they will commit errors mainly when a blue or white cue precedes the grasp type. They 'trust' these informative priors and don't pay close attention to the actual picture. 

2. Neutral cue trials have the have the longest and least variable RT because participants have to pay close attention to the picture and cannot use any prior knowledge
