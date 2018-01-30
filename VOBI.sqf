
dzn_fn_getTgtInfo = {
	format (["Known: %1 / %2
		\nLast time: %3 / %4
		\nTgt side: %5
		\nPosition: %8 (%6)"] 
		+ _this)
};

[] spawn {
	while { true } do {
		sleep 1;
		hintSilent format [
			"V1\n%1\n\nV2\n%2"
			, (V1 targetKnowledge P1) call dzn_fn_getTgtInfo
			, (V2 targetKnowledge P1) call dzn_fn_getTgtInfo
		];
	};
};


dzn_VOBI_TgtPool = [];

dzn_VOBI_reportTargets = {
	private _unit = _this;
	private _pos = getPos _unit;
	
	// Output in format: [ @Target, @KnowledgeLevel, @ReporterPosition ]
	private _tgts = (_unit targets [true, 0]) apply {
		[_x, _unit knowsAbout _x, _pos]	
	};
	
	_unit setVariable ["dzn_VOBI_Targets", _tgts];
	_tgts
};

dzn_VOBI_addTargetsToPool = {
	// Input in format: [ @Target, @KnowledgeLevel, @ReporterPosition ]
	{
		_x params ["_tgt","_knw","_pos"];
		
		private _targetInPool = dzn_VOBI_TgtPool select { _x select 0 == _tgt };
		
		if (_targetInPool isEqualTo []) then {
			// New target added as is
			dzn_VOBI_TgtPool pushBack _x;
		} else {
			// Target already known and new Knowledege > than saved -- update knowledge and reporter position
			if (_knw > (_targetInPool select 0) select 1) then {
				(_targetInPool select 0) set [1, _knw];
				(_targetInPool select 0) set [2, _pos];
			};
		};
	} forEach _this;
};

dzn_VOBI_getTargetsFromPool = {
	private _unit = _this;
	private _unitPos = getPos _unit;
	private _knownTgts = _unit getVariable "dzn_VOBI_Targets";

	{
		_x params ["_tgt","_knw","_pos"];
		
		private _knownTgt = _knownTgts select { _x select 0 == _tgt };
		private _knownLevel = if (_knownTgt isEqualTo []) then { 0 } else { (_knownTgt select 0) select 1 };
		
		systemChat format ["VOBI: Current: %4 | KTGT: %1 [Known Level: %2 vs %3] ", _knownTgt, _knownLevel, _knw, _x];
		
		// If KnownLevel > retrieved - no need to update anything
		if (_knownLevel < _knw) then {
			systemChat "VOBI: Target should be revealed!";
			private _d = _pos distance2d _unitPos;
			private _newKnownLevel = _knw * (switch (true) do {
				case (_d <= 100): { 1 };
				case (_d <= 250): { 0.75 };
				case (_d <= 500): { 0.5 };
				case (_d <= 750): { 0.25 };
				default { 0 };
			});
			
			systemChat format ["VOBI: Calculations: %1 x %2 = %3 vs %4", _knw, switch (true) do {
				case (_d <= 100): { 1 };
				case (_d <= 250): { 0.75 };
				case (_d <= 500): { 0.5 };
				case (_d <= 750): { 0.25 };
				default { 0 };
			}, _newKnownLevel, _knownLevel];
			
			
			// If calculated new known level > current - reveal
			if (_knownLevel < _newKnownLevel) then {
				systemChat "VOBI: REVEALED!";
				_unit reveal [_tgt, _newKnownLevel];
			};			
		};
	} forEach dzn_VOBI_TgtPool;
};


[] spawn {
	while { true } do {
		sleep 3;
		
		{
			if (side _x == EAST) then {
			
				(_x call dzn_VOBI_reportTargets) call dzn_VOBI_addTargetsToPool;
				sleep 0.5;
				_x call dzn_VOBI_getTargetsFromPool;
			};
		} forEach (allUnits + vehicles);
	};
};

/*
	tgts = V2 call dzn_VOBI_reportTargets;
	tgts call dzn_VOBI_addTargetsToPool;
	
	V1 call dzn_VOBI_getTargetsFromPool
[	
	[V2,4,[2484.14,685.072,2.55666]]
	,[P1,4,[3305.72,1406.23,-0.090457]]
	,[V1,0.277312,[2680.25,1030.57,2.75843]]
]
*/
