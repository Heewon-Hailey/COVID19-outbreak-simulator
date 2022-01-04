globals [

  total_infected       ; cumulated number of infected cases (total size)
  daily_infected       ; number of infected cases at the current tick
  max_infected         ; number of infected cases at the peak (the peak size)
  max_infected_time    ; time of the peak
]

turtles-own
[
  dead?               ; If true, the person is dead
  susceptible?        ; If true, can be infected
  exposed?            ; If true, exposed(infected) but not isolated
  isolated?           ; If true, infected and isolated so no more infection
  immune?             ; If true, immuned through a recovery or vaccination.
                      ; It becomes susceptible after its immunity period (They can be re-infected)
  day_count           ; count day(s) since a phase changes

  exposed_to_infected_time  ; time the person takes to be infected(isolated) since exposed
  isolated/recovered_time   ; time the person takes to be recovered since isolated (death chance after this time)
  immune_time               ; time the person takes to lose his/her immunity since immuned
]


;;; SETUP PROCEDURES

to setup
  clear-all
  ask patches [set pcolor white]
  setup-people
  clear_global_variables
  reset-ticks

end


to setup-people
  ;; Initialise the susceptible population
  create-turtles Initial_population [
    setxy random-xcor random-ycor
    set size 1.0
    set shape "person"

    set immune? false
    set exposed? false
    set isolated? false
    set susceptible? true
    set dead? false

    ;; Set the exposure/ isolation(recovery)/ longevity of immunity time for each agent to fall on a
    ;; normal distribution around each average time
    set exposed_to_infected_time random-normal average_exposed_to_infected_time (average_exposed_to_infected_time / 2 )
    ;; assume it lies between 0 and 2x average-exposed-time
    if exposed_to_infected_time < 0 [ set exposed_to_infected_time 0 ]
    if exposed_to_infected_time > ( average_exposed_to_infected_time * 2 )[
      set exposed_to_infected_time ( average_exposed_to_infected_time * 2 )]

    set isolated/recovered_time random-normal average_isolated/recovered_time (average_isolated/recovered_time / 2 )
    ;; assume it lies between 0 and 2x average-recovery-time
    if isolated/recovered_time < 0 [ set isolated/recovered_time 0 ]
    if isolated/recovered_time > (average_isolated/recovered_time * 2) [
      set isolated/recovered_time ( average_isolated/recovered_time * 2) ]

    ;; assume it lies greater than 0
    set immune_time random-normal average_immune_time ( average_immune_time / 5 )
    if immune_time < 0 [ set immune_time 0 ]

    ;; colour the agents to visualise their states
    assign-colour
  ]

  ;; Initialise the infected population as much as 5% of the totial initial population
  ask n-of (initial_population * 0.05) turtles[
    set exposed? true
    set susceptible? false
    ; reset the day count
    clear_day

    assign-colour
  ]

   ;; Initialise the vaccinated people
  ask n-of ( initial_population * (vaccinated_population / 100)) turtles with [not exposed?][
    set immune? true
    set susceptible? false
    clear_day

    set daily_infected ( initial_population * (vaccinated_population / 100))
    set total_infected ( initial_population * (vaccinated_population / 100))

    assign-colour
    ]
end


; People are displayed in 4 different colors depending on their current disease phase
to assign-colour  ; turtle procedure
  if susceptible? [ set color green ]     ; Green represents a susceptible person
  if exposed?     [ set color orange ]    ; Orange - exposed
  if isolated?    [ set color grey ]      ; Grey - isolated
  if immune?      [ set color pink ]      ; Pink - immuned through an infection or vaccination
  if dead?        [ set color black ]     ; Black - dead
end


; reset the day
to clear_day
  set day_count 0
end


; reset all global variables
to clear_global_variables
  set total_infected 0
  set daily_infected 0
  set max_infected 0
  set max_infected_time 0
end

;;; PROCEDURES

to go
  tick

  set daily_infected 0     ; reset the number of daily infected cases

  ; export the results before stop the procedure to analyse
  if ticks >= 100
   [
;      print ( "total_infected : " )
;      print (  total_infected )
;      print ( "max_infected : " )
;      print ( max_infected )
;      print ( "max_infected_time : " )
;      print ( max_infected_time )

      stop ]

  ; move mobile agents and increase day by 1
  ask turtles [
    if (not isolated? and not dead?) [ move ]
    set day_count day_count + 1 ]

  ; decide if immune agents lose immunity
  ask turtles with [ immune? ]
     [ lose_immunity ]

  ; decide if immune agents end isolation
  ask turtles with [ isolated? ]
     [ recover_or_die ]

  ; spread virus and decide if exposed agents need to be isolated
  ask turtles with [ exposed? ]
     [  spread_virus
        get_isolated ]

  ask turtles
    [ assign-colour ]

  set daily_infected count(turtles with [ exposed? or isolated? ])
  if (daily_infected > max_infected) [
    set max_infected daily_infected
    set max_infected_time ticks
  ]

end


; move agents 1 step
to move
  rt random-float 360
  fd 1.0
end


; decide if immune agents lose immunity
to lose_immunity
  if day_count > immune_time [
    set immune? false
    set susceptible? true
    clear_day
  ]
end


; decide if immune agents end isolation and get immunity or die w.r.t death rate
to recover_or_die
  if day_count > isolated/recovered_time [
    ifelse random 100 < death_rate [
      set isolated? false
      set dead? true

      clear_day ]
    [
      set isolated? false
      set immune? true
      clear_day
    ]
  ]
end


; spread virus by searching neighbour susceptible agents w.r.t virus_spreding_rate
to spread_virus
   let nearby-susceptible (other turtles) in-radius 0.5 ;nearby-susceptible (turtles-on neighbors)
     with [ susceptible? ]
     if nearby-susceptible != nobody [
       ask nearby-susceptible [
         if random-float 100 < virus_spreading_rate [
           set susceptible? false
           set exposed? true
           clear_day

           set total_infected total_infected + 1
       ]
      ]
     ]
end

; decide if exposed agents need to be isolated
to get_isolated
  if day_count > exposed_to_infected_time[
      set exposed? false
      set isolated? true
      clear_day
    ]
end
@#$#@#$#@
GRAPHICS-WINDOW
645
12
1118
486
-1
-1
15.0
1
10
1
1
1
0
1
1
1
-15
15
-15
15
1
1
1
days
30.0

BUTTON
384
156
467
189
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
507
158
590
191
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
46
14
315
47
initial_population
initial_population
0
1000
1000.0
5
1
Persons
HORIZONTAL

PLOT
12
421
618
582
Populations
days
# of people
0.0
100.0
0.0
10.0
true
true
"" ""
PENS
"Infected" 1.0 0 -2674135 true "" "plot count turtles with [ exposed? or isolated? ]"
"Not Infected" 1.0 0 -13345367 true "" "plot count turtles with [ not (exposed? or isolated?)]"

PLOT
12
208
618
414
Cumulative Results
days
% of population
0.0
100.0
0.0
100.0
false
true
"" ""
PENS
" exposed" 1.0 0 -955883 true "" "plot ((count turtles with [ exposed?])/ initial_population * 100)"
" immune" 1.0 0 -2064490 true "" "plot (count turtles with [ immune? ] / initial_population * 100)\n"
" suceptible" 1.0 0 -10899396 true "" "plot (count turtles with [ susceptible? ] / initial_population * 100)"
" isolated" 1.0 0 -7500403 true "" "plot (count turtles with [ isolated?] / initial_population * 100) "
"dead" 1.0 0 -16777216 true "" "plot (count turtles with [ dead? ] / initial_population * 100) "
"total_infect" 1.0 0 -2674135 true "" "plot (count turtles with [ isolated? or exposed?] / initial_population * 100)"

SLIDER
338
15
605
48
average_exposed_to_infected_time
average_exposed_to_infected_time
0
14
5.8
0.1
1
day(s)
HORIZONTAL

SLIDER
45
58
316
91
vaccinated_population
vaccinated_population
0
100
80.0
5
1
%
HORIZONTAL

SLIDER
336
58
606
91
average_isolated/recovered_time
average_isolated/recovered_time
0
42
14.0
1
1
day(s)
HORIZONTAL

SLIDER
337
104
606
137
average_immune_time
average_immune_time
0
100
90.0
5
1
day(s)
HORIZONTAL

SLIDER
44
112
315
145
virus_spreading_rate
virus_spreading_rate
0
100
90.0
5
1
%
HORIZONTAL

SLIDER
44
157
316
190
death_rate
death_rate
0
100
3.5
0.1
1
%
HORIZONTAL

TEXTBOX
270
584
420
609
Result Plots
20
0.0
1

MONITOR
667
534
733
579
The dead
count turtles with [dead?]
17
1
11

MONITOR
764
534
830
579
The alive
count turtles with [not dead?]
17
1
11

@#$#@#$#@
## AUTHOR

Hailey Kim


## PURPOSE

This model simulates the spread of an infectious disease (COVID-19) in a closed population to address author's question - How do the outbreak characteristics change with respect to vaccinated population under the two different conditions (short and long longevity of immunity)? 

Parameters are implemented adjustable to explore this model in-depth. 
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

person lefty
false
0
Circle -7500403 true true 170 5 80
Polygon -7500403 true true 165 90 180 195 150 285 165 300 195 300 210 225 225 300 255 300 270 285 240 195 255 90
Rectangle -7500403 true true 187 79 232 94
Polygon -7500403 true true 255 90 300 150 285 180 225 105
Polygon -7500403 true true 165 90 120 150 135 180 195 105

person righty
false
0
Circle -7500403 true true 50 5 80
Polygon -7500403 true true 45 90 60 195 30 285 45 300 75 300 90 225 105 300 135 300 150 285 120 195 135 90
Rectangle -7500403 true true 67 79 112 94
Polygon -7500403 true true 135 90 180 150 165 180 105 105
Polygon -7500403 true true 45 90 0 150 15 180 75 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="ass1_results" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>total_infected</metric>
    <metric>max_infected</metric>
    <metric>max_infected_time</metric>
    <enumeratedValueSet variable="vaccinated_population">
      <value value="0"/>
      <value value="50"/>
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average_immune_time">
      <value value="30"/>
      <value value="90"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="virus_spreading_rate">
      <value value="90"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average_isolated/recovered_time">
      <value value="14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="death_rate">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial_population">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average_exposed_to_infected_time">
      <value value="5.8"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
