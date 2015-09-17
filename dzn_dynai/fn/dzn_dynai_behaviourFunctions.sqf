dzn_fnc_dynai_waitToDeleteSquadLogic = {
	// _this spawn dzn_fnc_dynai_waitToDeleteSquadLogic
	waitUntil {
		sleep 30; 
		{alive _x} count (synchronizedObjects (_this)) < 1
	};
	deleteVehicle (_this);
};

dzn_fnc_dynai_x = {};
