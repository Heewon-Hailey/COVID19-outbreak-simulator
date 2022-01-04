# COVID19-outbreak-simulator


## About the project 

COVID-19 outbreak modelling and simulation with respect to the
longevity of antibody and vaccination strategy - ODD Description

Purpose and patterns
The model was designed to simulate virtual virus spreading scenarios to address
questions about COVID-19. In particular, how can vaccination strategy and duration of
valid immunity affect the pattern of the outbreak? how different are the final size and the
peak size of the outbreak? how could the epidemic be controlled? The model was
simplified and generalized in terms of demographic and geographic features. To represent
the characteristics of the specific pathogen, meanwhile, a modified SEIR was implemented
based on experimental parameters from previous researches.


Background
 Researchers and scientists across the world have been developing vaccines against the novel
coronavirus (COVID-19) amid the unprecedented pandemic since late 2019. As of August
2020, some candidate vaccines are in phase 3 clinical trials - tests for efficacy and safety on
human beings. However, some scientists raise concern over how long the immunity to COVID19 may last. According to a recent study [1], patients start losing existing antibody responses
within months which is a considerably short period compared to other viruses such as
chickenpox and measles - their immunity could last for more than half-century [2]. If it is true,
the pattern of virus transmission may significantly vary depending on vaccination strategy and
duration of antibody responses. In this report, we implement an agent-based model in NetLogo
to simulate virtual scenarios based on a modified SEIR model and address our questions.
Question
 How does the epidemic curve change with respect to vaccinated populations under the two
different conditions (short and long longevity of immunity)? How could we prevent and control
onset outbreaks?


Transmission process: It is modified from the basic SEIR model to reflect asymptomatic
infected patients. (a) Initially, people have one of the disease phases (susceptible, exposed
and immune through vaccination); (b) Once a susceptible person is exposed by the virus,
(s)he is infectious with mild symptoms; (c) After an asymptomatic period, we assume the
person is officially diagnosed with the virus and isolated immediately. The isolation
effectiveness is 100 % (no further virus spreading); (d) The person dies or recovers with
immunity in an isolation time. (e) After a valid time of immunity, people can be reinfected.


![alt text](https://github.com/Heewon-Hailey/COVID19-outbreak-simulator/edit/main/README.md/blob/[branch]/image.jpg?raw=true)



## How to run
You should either download NetLogo or use web version NetLogo at https://ccl.northwestern.edu/netlogo/. For a brief look, I suggest to use the web version NetLogo by uploading the file. 
