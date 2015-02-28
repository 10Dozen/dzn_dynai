Initialize Dynai -> [ZONES]                                     <br>
| waitUntil { time > DYNAI_CONFIG.activationDelay }             <br>
| forEach [ZONES] -> [ZONE]                                     <br>
|| [ZONE] spawn                                                 <br>
||| waitUntil { ZONE.isActive }                                 <br>
