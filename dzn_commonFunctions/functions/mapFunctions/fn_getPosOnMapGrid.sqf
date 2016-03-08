/*
	@Pos3d = @MapGrid(String) call dzn_fnc_getPosOnMapGrid	
	
	Parse Map Grid (XXXX YYYY) to Pos 3d
	OUTPUT: Pos 3d ATL on 0 height
*/

[
	parseNumber (_this select [0,4]) * 10
	, parseNumber (_this select [5,4]) * 10
	, 0
]