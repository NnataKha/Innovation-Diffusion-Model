globals [number1 number2 show1 show2]
turtles-own [
  status
  choice
  priority
]

to setup
  clear-all
  initialize
  set number1 (list count turtles with [priority = 1])
  set number2 (list count turtles with [priority = 2])
  reset-ticks
end


to go
  ask turtles
  [ let neighborhood turtle-set turtles-on (turtles-on neighbors)
    let neighbor one-of neighborhood
    interact-with neighbor
    do-coloring
    ]
  tick
  let n1 count turtles with [priority = 1]
  let n2 count turtles with [priority = 2]
  set number1 lput n1 number1
  set number2 lput n2 number2
  set show1 (item ticks number1) - (item (ticks - 1) number1)
  set show2 (item ticks number2) - (item (ticks - 1) number2)
end

to initialize
  set-default-shape turtles "turtle"
  cro number-of-agents
  [ setxy random-xcor random-ycor]
 ask turtles [
   set status "customer"
   set choice n-values number-of-features [random 30]
   set priority position (max choice) choice
  ]


   let m 0
 while [m < number-of-ads-2]
   [
     ask turtle (number-of-agents - m - 1) [
     set status "ad"
     set shape "circle"
     let r 2;(random number-of-features)
     set choice n-values number-of-features [0]
     set choice replace-item r choice 30
     set priority 2
   ]
     set m m + 1]

 let n 0
 while [n < number-of-ads-1]
   [
     ask turtle n [
     set status "ad"
     set shape "circle"
     let r 1;(random number-of-features)
     set choice n-values number-of-features [0]
     set choice replace-item r choice 30
     set priority 1
   ]
     set n n + 1]


 let s 0
 ask turtles [
   set s sum choice
   let i 0
   let c []
   while [i < number-of-features]
   [set c lput (item i choice / s) c
     set i i + 1]
   set choice c
   do-coloring
  ]

end

to do-coloring
      let mc priority
      let mcol 8
      if (mc < 0.4) and (mc >= 0.2) [set mcol 7]
      if (mc < 0.6) and (mc >= 0.4) [set mcol 6]
      if (mc < 0.8) and (mc >= 0.6) [set mcol 5]
      if (mc >= 0.8) [set mcol 4]
      set color int(20 * priority + mcol + 20)
end

to interact-with [neighbor] ;; patch procedure
  if neighbor != nobody
  [
    let choice1 [choice] of self
    let choice2 [choice] of neighbor
    let theta 0
    let tau_max []
    let tau_min []
    let i 0
    while [i < number-of-features]
    [ set theta theta + (item i choice1) * (item i choice2)
      set tau_min lput min (list (item i choice1) (item i choice2)) tau_min
      set tau_max lput max (list (item i choice1) (item i choice2)) tau_max
      set i (i + 1)
    ]
    let w_max sum tau_max
    let w_min sum tau_min
    let c1 []
    let c2 []
    let th (1 + cos (ticks))
        ;print th
        ifelse difference-between self neighbor > threshold
        [ set i 0
          while [i < number-of-features]
          [
            set c1 lput ((1 + theta)*(item i choice1) - 0.9 * (item i tau_min)) c1
            set c2 lput ((1 + theta)*(item i choice2) - 0.9 * (item i tau_min)) c2
            set i (i + 1)
          ]
        ]
        [ set i 0
          while [i < number-of-features]
          [
            set c1 lput ((1 + theta)*(item i choice1) + 0.5 * (item i tau_max)) c1
            set c2 lput ((1 + theta)*(item i choice2) + 0.5 * (item i tau_max)) c2
            set i (i + 1)
          ]
        ]
        ask self [
          if status = "customer" [
          let s sum c1
          set i 0
          let c []
          while [i < number-of-features]
          [set c lput (item i c1 / s) c
            set i i + 1]
          set choice c
          set priority position (max choice) choice
          if (sum choice) > 1.001 [print who print "sum after conflict" print sum choice]
        ]]
        ask neighbor [
          if status = "customer" [
          let s sum c2
          set i 0
          let c []
          while [i < number-of-features]
          [set c lput (item i c2 / s) c
            set i i + 1]
          set choice c
          set priority position (max choice) choice
          if (sum choice) > 1.001 [print who print "sum after conflict " print sum choice]
          ]]

  ]
end

to-report difference-between [turtle1 turtle2]
  let choice1 [choice] of turtle1
  let choice2 [choice] of turtle2
  let values 0
  ;; if the two lists contain the same traits, increase similarity
  foreach n-values number-of-features [?]
  [
    set values (values + abs(item ? choice1 - item ? choice2))
  ]
  report (values)
end
@#$#@#$#@
GRAPHICS-WINDOW
416
22
855
482
16
16
13.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
12
13
75
46
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
13
57
76
90
go
go
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
13
103
76
136
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
1

SLIDER
112
16
284
49
number-of-agents
number-of-agents
0
5000
5000
1
1
NIL
HORIZONTAL

SLIDER
113
61
285
94
number-of-features
number-of-features
0
30
19
1
1
NIL
HORIZONTAL

SLIDER
15
163
204
196
number-of-ads-1
number-of-ads-1
0
number-of-agents * 0.1
0
1
1
NIL
HORIZONTAL

PLOT
14
288
335
487
Number of agents with the same priority
time
number of agents
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -1069655 true "" "plot count turtles with [priority = 0]"
"pen-1" 1.0 0 -4079321 true "" "plot count turtles with [priority = 1]"
"pen-2" 1.0 0 -14439633 true "" "plot count turtles with [priority = 2]"
"pen-3" 1.0 0 -12345184 true "" "plot count turtles with [priority = 3]"
"pen-4" 1.0 0 -14070903 true "" "plot count turtles with [priority = 4]"
"pen-5" 1.0 0 -10022847 true "" "plot count turtles with [priority = 5]"

SLIDER
113
105
285
138
threshold
threshold
0
2
2
0.1
1
NIL
HORIZONTAL

SLIDER
15
206
197
239
number-of-ads-2
number-of-ads-2
0
number-of-agents * 0.1
0
1
1
NIL
HORIZONTAL

PLOT
881
78
1355
393
plot 1
time
new adopters
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -4079321 true "" "plot show1"
"pen-1" 1.0 0 -15040220 true "" "plot show2"

@#$#@#$#@
## WHAT IS IT?

Information diffusion model

## HOW IT WORKS

Agent attributes:
  status "customer" if the agent's choice may be changed
	 "ad"  if the agent's choice may not be changed
  choice — stochastic vector of length = “number-of-features”
  priority — position of the maximal value in the vector culture (turtles are shown in different colors depending on their priority value, if it is 0, then the turtle is light-pink, for 1 – yellow, 2 – green, 3 – light-blue, 4 – blue, 5 – magenta).


Interaction:
Agents are located randomly on a field of 10x10 patches.
For an agent the set of his neighbors is the set of all agents from his patch and the agents from 8 neighboring patches.
Each agent is picked randomly and interacts with a random agent from the set of his neighbors.
For a pair of agents we calculate “difference-between” which equals to the l_1 distance between their vectors culture, i. e. if culture_1 =(c1_1, c1_2, c1_n), culture_2 =(c2_1, c2_2, c2_n) then  “difference-between” = |c1_1 – c2_1| + |c1_2 – c2_2| + … +|c1_n – c2_n|.

The nature of the interaction depends on the value of the parameter “threshold” which is within the interval [0,2].

If the “difference-between” > “threshold” then it is the repulsive interaction (with a coefficient at the tau) and in the other way it is the attractive interaction.

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

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

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.3
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
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
