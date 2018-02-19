var Zone;

var GROUP_MODE_MAPPING = {
	"combatMode": [
		[ "Blue (Never fire)", 'BLUE'],
		[ "Green", 'GREEN'],
		[ "White", 'WHITE'],
		[ "Yellow", 'YELLOW'],
		[ "Red", 'RED']
	]
	,"speedMode": [
		[ "Full", 'FULL' ],
		[ "Normal", 'NORMAL' ],
		[ "Limited", 'LIMITED' ]
	]
	,"formationMode": [
		[ "Wedge", 'WEDGE' ],
		[ "Column", 'COLUMN' ],
		[ "Staggered Column", 'STAG COLUMN' ],
		[ "Echelon Left", 'ECH LEFT' ],
		[ "Echelon Right", 'ECH RIGHT' ],
		[ "Vee", 'VEE' ],
		[ "Line", 'LINE' ],
		[ "Delta", 'DIAMOND' ],
		[ "Column (compact)", 'FILE' ]
	]
	,"behaviourMode": [
		[ "Careless", 'CARELESS' ],
		[ "Safe", 'SAFE' ],
		[ "Aware", 'AWARE' ],
		[ "Combat", 'COMBAT' ],
		[ "Stealth", 'STEALTH' ]
	]
};

var VEHICLE_BEHAVIOUR = [
	["Patrol", '"Vehicle Patrol"']
	, ["Hold", '"Vehicle Hold"']
	, ["Hold (Front)", '"Vehicle Frontal Hold"']
	, ["Advance", '"Vehicle Advance"']
	, ["Road Patrol", '"Vehicle Road Patrol"']
	, ["Road Hold", '"Vehicle Road Hold"']
	, ["Road Hold (Front)", '"Vehicle Road Frontal Hold"']
];

/*
 *	Zone
 *
 */
var ZoneItem = function () {
	this.name =  "Zone";
	this.id = "zone";
	this.active = true;
	this.side = "west";
	this.condition = "true";
	this.groupMode = {
		"behaviourMode": 	"SAFE"
		,"formationMode": 	"WEDGE"
		,"combatMode": 	"YELLOW"
		,"speedMode": 	"LIMITED"
	};
	this.groups = [];
	this.groupCounter =	0;

	this.generateOptions = function (mode) {
		var list = GROUP_MODE_MAPPING[mode];
		var result = "";
		for (var i=0; i< list.length; i++) {
			result = result + '<option>' + list[i][0] + '</option>';
		};
		return result
	};

	this.$form = $(
		'<div class="zone-item"><div class="zone-form"><ul>'
		+ 	'<li><div class="col-4">Name</div><div class="col-4"><input class="zone-name zone-name-input"></input></div></li>'
		+ 	'<li><div class="col-4">Side</div><div class="col-2 side-toggle">'
		+ 	'<div class="side-switch-on zone-side-option" value="west">WEST</div>'
		+ 	'<div class="side-switch-off zone-side-option" value="east">EAST</div>'
		+ 	'<div class="side-switch-off zone-side-option" value="resistance">INDEP</div>'
		+ 	'<div class="side-switch-off zone-side-option" value="civilian">CIV</div>'
		+ 	'</div></li>'		
		+ 	'<li><div class="col-4">Activate on start</div><div class="col-4"><div class="toggle-switch zone-active-toggle">'
		+	'<span class="toggle-switch-on">|</span><label>YES</label></div></div><div class="col-4"><input title="Activation condition" style="display:none" class="zone-condition-input"></input></div></li>'
		
		+ 	'<hr /><div> Groups Behaviour </div>'
		+ 	'<li><div class="col-4-inline">Speed mode</div><div class="col-4-inline"><select class="zone-speedmode">'
		+	this.generateOptions("speedMode") + '</select></div>'
		+	'<div class="col-4-inline">Formation</div><div class="col-4-inline"><select class="zone-formationmode">'
		+ 	this.generateOptions("formationMode") + '</select></div></li>'
		+ 	'<li><div class="col-4-inline">Combat mode</div><div class="col-4-inline"><select class="zone-combatmode">'
		+ 	this.generateOptions("combatMode") + '</select></div>'
		+ 	'<div class="col-4-inline">Behaviour</div><div class="col-4-inline"><select  class="zone-behaviourmode">'
		+ 	this.generateOptions("behaviourMode") + '</select></div></li>'
		+ 	'<hr /><br /><div class="col-4"> Group Templates </div>'
		+ 	'<li><div class="group-wrapper"></div><br /><div class="btn zone-add-group">Add Group</div></li></ul></div></div>'
	);

	this.init = function () {
		this.draw();
		this.initEvents();

		console.log("Zone Generated");
	};
	this.setName = function () {
		var newName = $(this.$form).find('.zone-name').val();
		if (newName != "") {
			this.name = newName;
			$(this.$form).find('.zone-header').find('span').html(newName);
		};
		$(this.$form).find('.zone-name').val(this.name);
	};
	this.setSide = function (side) {
		this.side = side;
		$(this.$form).find('.side-toggle').find('.side-switch-on').removeClass('side-switch-on').addClass('side-switch-off');
		$(this.$form).find('.side-toggle').find('div[value="' + side + '"]').removeClass( "side-switch-off" ).addClass( "side-switch-on" );
	};
	this.toggleActive = function () {
		if (this.active) {
			this.active = false;
			$(this.$form).find('.toggle-switch').find('.toggle-switch-on').css( "float", "right" );
			$(this.$form).find('.toggle-switch').find('label').html('NO');
			$(this.$form).find('.toggle-switch').css('background-color','#CECECE');
			$(this.$form).find('.zone-condition-input').css('display','block');
		} else {
			this.active = true;
			$(this.$form).find('.toggle-switch').find('.toggle-switch-on').css( "float", "left" );
			$(this.$form).find('.toggle-switch').find('label').html('YES');
			$(this.$form).find('.toggle-switch').css('background-color','rgb(177, 230, 89)');
			$(this.$form).find('.zone-condition-input').css('display','none');
		}
	};
	this.setCondition = function () {
		var newCond = $(this.$form).find('.zone-condition-input').val();
		if (newCond != "") {
			this.condition = newCond;
		};
		$(this.$form).find('.condition-string').val(this.newCond);
	};
	this.setGroupMode = function(type) {
		var typeClass, typeItem;
		switch (type) {
			case "speedMode": 		typeClass = ".zone-speedmode"; typeItem = "speedMode";	break;
			case "formationMode":	typeClass = ".zone-formationmode"; typeItem = "formationMode";	break;
			case "combatMode":		typeClass = ".zone-combatmode"; typeItem = "combatMode";	break;
			case "behaviourMode":	typeClass = ".zone-behaviourmode"; typeItem = "behaviourMode";	break;
		};
		var name = $( this.$form ).find( typeClass ).val();
		var mode = (GROUP_MODE_MAPPING[typeItem]).filter(function (c) { if (c[0] == name) { return c } })[0][1];
		this.groupMode[typeItem] = mode;
	};
	this.addGroup = function () {
		var group = new Group(this.groupCounter);
		console.log("Group Added");
		this.groups.push(group);
		this.groupCounter = this.groupCounter + 1;
	};
	this.removeGroup = function (id) {
		var index = -1;
  		for (var i=0; i<this.groups.length; i++) {
  			if (this.groups[i].id == id) {
  				index = i;
  			};
  		};

  		this.groups.splice(index, 1);
	};
	this.getGroupById = function (id) {
    	var grp = {};
    	for (var i = 0; i < Zone.groups.length; i++) {
    		if (Zone.groups[i].id == id) { grp = Zone.groups[i]; break; }
    	};
    	return grp
    };

	this.reset = function () {
		this.name = "Zone";
		$(this.$form).find('.zone-name').val(this.name);
		this.active = false;
		this.toggleActive();
		this.setSide("west");

		var groupModeSettings = [
       	    [".zone-speedmode", "SAFE"]
       	    , [".zone-formationmode", "WEDGE"]
       	    , [".zone-combatmode", "YELLOW"]
       	    , [".zone-behaviourmode", "LIMITED"]
       	];
		this.groupMode = {
       		"behaviourMode": 	groupModeSettings[0][1]
       		,"formationMode": 	groupModeSettings[1][1]
       		,"combatMode": 	    groupModeSettings[2][1]
	        ,"speedMode":   	groupModeSettings[3][1]
       	};
		groupModeSettings.forEach(function(item) {
			$( this.$form ).find( item[0] ).val( item[1] );
		});

		while (this.groups.length > 0) {
			this.groups[0].remove();
		};

		this.groupCounter =	0;
		this.draw();
	};
	this.initEvents = function () {
		$(this.$form).find('.zone-name-input').on('blur', function () {
			Zone.setName();
		});
		$(this.$form).find('.zone-side-option').on('click', function () {
			Zone.setSide( $(this).attr("value") );
		});
		$(this.$form).find('.zone-active-toggle').on('click', function () {
			Zone.toggleActive();
		});
		$(this.$form).find('.zone-condition-input').on('blur', function () {
			Zone.setCondition();
		});
		$(this.$form).find('.zone-speedmode').on('blur', function () {
			Zone.setGroupMode("speedMode");
		});
		$(this.$form).find('.zone-formationmode').on('blur', function () {
			Zone.setGroupMode("formationMode");
		});
		$(this.$form).find('.zone-combatmode').on('blur', function () {
			Zone.setGroupMode("combatMode");
		});
		$(this.$form).find('.zone-behaviourmode').on('blur', function () {
			Zone.setGroupMode("behaviourMode");
		});
		$(this.$form).find('.zone-add-group').on('click', function () {
			Zone.addGroup();
		});
	};
	this.draw = function () {
		$( "#zones-wrapper" ).append( this.$form );
		$(this.$form).attr("id", this.id);

		// Set default name
		$(this.$form).find('.zone-name').val(this.name);

		// Set defailt Group Behaviour
		var speed = this.groupMode.speedMode;
		var combat = this.groupMode.combatMode;
		var behaviour = this.groupMode.behaviourMode;
		var form = this.groupMode.formationMode;
		$(this.$form).find( '.zone-speedmode' ).val(
			GROUP_MODE_MAPPING.speedMode.filter(function (c) { if (c[1] == speed) { return c } })[0][0]
		);
		$(this.$form).find( '.zone-combatmode' ).val(
			GROUP_MODE_MAPPING.combatMode.filter(function (c) { if (c[1] == combat) { return c } })[0][0]
		);
		$(this.$form).find( '.zone-behaviourmode' ).val(
			GROUP_MODE_MAPPING.behaviourMode.filter(function (c) { if (c[1] == behaviour) { return c } })[0][0]
		);
		$(this.$form).find( '.zone-formationmode' ).val(
			GROUP_MODE_MAPPING.formationMode.filter(function (c) { if (c[1] == form) { return c } })[0][0]
		);

		document.getElementById( this.id ).scrollIntoView();
	};

	
	this.getUnitMode = function (unit, modeName) {
		var mode = '[]';
		
		if (unit.type == "Infantry") {
			switch (modeName) {
				case "Indoors":
					if (unit.restrictedHouses == "") {
						mode = '["indoors"]';
					} else {
						mode = '["indoors", [' + unit.restrictedHouses + ']]';
					};
					break;
				case "In vehicle":
					mode = '[' + unit.vehicleId + ',"' + unit.vehicleRole + '"]';
					break;
			};
		} else {
			for (var i = 0; i < VEHICLE_BEHAVIOUR.length; i++) {				
				if (modeName == VEHICLE_BEHAVIOUR[i][0]) {				
					mode = VEHICLE_BEHAVIOUR[i][1];
					break;
				};
			};
		}
		
		return mode;
	};
	
	this.getConfig = function () {
		var spc = "	";

		var behavior = '<br />' + spc + '/* Behavior: Speed, Behavior, Combat mode, Formation */'
			+ '<br />' + spc
			+ ',["' + this.groupMode.speedMode + '",'
			+ '"' + this.groupMode.behaviourMode + '",'
			+ '"' + this.groupMode.combatMode + '",'
			+ '"' + this.groupMode.formationMode + '"]';

		var groups = "";
		for (var i = 0; i < this.groups.length; i++ ) {
			var separatorPerGroup = (i > 0) ? "," : "";
			var grp = this.groups[i];

			var units = '';
			for (var j = 0; j < grp.units.length; j++) {
				var separatorPerUnit = (j > 0) ? "," : "";
				var unit = grp.units[j];

				unitOptions = this.getUnitMode(unit, unit.mode);

				units = units
					+ '<br />' + spc + spc + spc + spc + separatorPerUnit
					+ '["' 	+ unit.classname + '", '
					+ unitOptions + ', '
					+ '"' + unit.kit + '"]';
			};

			groups = groups
				+ '<br />' + spc + spc + separatorPerGroup + '['
				+ '<br />' + spc + spc + spc + grp.number + ', /* Groups quantity */'
				+ '<br />' + spc + spc + spc + '/* Units */'
				+ '<br />' + spc + spc + spc + '['
				+ units
				+ '<br />' + spc + spc + spc + ']'
				+ '<br />' + spc + spc + ']';
		};

		var cond = "";
		if (!this.active) {
			cond = '<br />' + spc + ' /* (OPTIONAL) Activation condition */<br />' + spc + ',{ ' + this.condition + ' }';			
		}
		var configLine = '[<br />' + spc + '"' + this.name + '" /* Zone Name */'
			+ '<br />' + spc + ',"' + this.side.toUpperCase() + '",' + this.active + ", /* Side, is Active */ [],[]"
			+ '<br />' + spc + '/* Groups: */'
            + '<br />' + spc + ',['
            + groups
			+ '<br />' + spc + ']'
			+ behavior
			+ cond		
			+ '<br />]';

        return configLine;
	};

	this.init();
};

/*
 * Group
 *
 */
var Group = function (id) {
	this.desc = "Empty group";
	this.id = id;
	this.number = 1;
	this.units = [];
	this.$form = $(
		'<div class="group-item" style="border: 1px solid black;">'
		+ '<div class="group-left">' + (id+1) + '</div>'
		+ '<div class="group-right"><div class="col-2 col-inline-block">Number of groups</div>'
		+ '<div class="col-6 col-inline-block"><input class="input-short"></input></div>'
		+ '<div class="btn group-edit-btn">✎</div><div class="btn group-remove-btn">✖</div></div>'
		+ '<div class="group-right-desc"><b>' + this.desc + '</b><br /></div></div>'
	);

	this.remove = function () {
		$(this.$form).find('.group-remove-btn').off();
		$(this.$form).find('.group-edit-btn').off();
		$(this.$form).find('input').off();
		Zone.removeGroup(this.id);
		(this.$form).remove();
	};

	this.edit = function () {

		GroupEditWindow.open(this);
	};

	this.setCount = function () {
		var num = $(this.$form).find('input').val();
		if (+num < 1) {
			$(this.$form).find('input').val( this.number );
		} else {
			this.number = +($(this.$form).find('input').val());
		}
	};
	this.setDesc = function () {
		if (this.units.length == 0) {
    		this.desc = "Empty group";
    		$(this.$form).find('.group-right-desc').find('b').html(this.desc);
			return;
		};

		var infCount = 0;
		var vehCount = 0;
		for (var i = 0; i < this.units.length; i++) {
			if (this.units[i].type == "Infantry") {
				infCount++;
			} else {
				vehCount++;
			};
		};

		var description;
		if (infCount > 0) {
			description = "" + infCount + "x Infantry";
		};

		if (vehCount > 0) {
			description = (infCount > 0) ? description + ", " + vehCount + "x Vehicle" : "" + vehCount + "x Vehicle";
		};

		this.desc = description;
		$(this.$form).find('.group-right-desc').find('b').html(this.desc);
	};

	this.initEvents = function () {
		$(this.$form).find('.group-remove-btn').on('click', function () {
			var self = Zone.getGroupById( $($(this).parents()[1]).attr("id") );
			self.remove();
		});
		$(this.$form).find('.group-edit-btn').on('click', function () {
			var self = Zone.getGroupById( $($(this).parents()[1]).attr("id") );
			self.edit();
		});
		$(this.$form).find('input').on('blur', function () {
			var self = Zone.getGroupById( $($(this).parents()[2]).attr("id") );
			self.setCount();
		});
	};
	this.draw = function () {
		var self = Zone;

		$(self.$form).find( '.group-wrapper' ).append( this.$form );
		$(this.$form).attr("id", this.id);
	};

	this.init = function () {
		this.draw();
		this.initEvents();
		this.setCount();
		this.setDesc();
	};

	this.init();
};

/*
 * Group Edit
 *
 */
var GroupEdit = function () {
	this.group = {};
	this.editedUnits = [];
	this.editedUnitsCounter = 0;
	this.$form;

	this.open = function (group) {
		this.group = group;
		this.editedUnits = [];
        this.editedUnitsCounter = 0;

		$('.unit-wrapper').html("");

		this.display();
		this.populateForm();
	};
	this.display = function () {
		this.$form = '<div class="group-popup">'
                     		+ '<div class="xpopup-header"><span style="padding: 2px 20px">Edit Group</span></div>'
                     		+ '<div class="unit-wrapper"></div>'
                     		+ '<div class="xpopup-wrapper">'
                     		+ '<select class="input-select group-unit-type">'
                     		+ '<option>Infantry</option>'
                     		+ '<option>Vehicle</option>'
                     		+ '</select>'
                     		+ '<div class="btn-short inline group-add-unit">+</div>'
                     		+ '<span  style="float:right">'
                     		+ '<div class="btn inline group-save">✓ OK</div>'
                     		+ '<div class="btn inline group-cancel">CANCEL</div>'
                     		+ '</span>'
                     		+ '</div>'
                     		+ '</div>';

         $( '.edit-group-wrapper' ).append( this.$form );
		$( '.group-popup' ).css('top', 100 +window.pageYOffset + 'px');
		$( '.splash' ).css('display', 'inline');
		this.initEvents();
	};
	this.hide = function () {
		$('.splash').css('display', 'none');
		$( '.edit-group-wrapper' ).children().remove();
	};
	this.initEvents = function () {
    	$('.group-cancel').on('click', function () {
    		GroupEditWindow.cancel();
    	});
    	$('.group-save').on('click', function () {
    		GroupEditWindow.save();
    	});
    	$('.group-add-unit').on('click', function () {
    	    GroupEditWindow.addEntity();
    	});
    };
   	this.scrollDown = function () {
		document.getElementsByClassName('group-unit')[
			(document.getElementsByClassName('group-unit')).length - 1
		].scrollIntoView();
	};

	this.populateForm = function () {
    		// units = [
    		//	{ "type":"unit", "classname":"", "kit":"", "behavior":"", "setting":["vehicleId", "vehicleRole"]/["restricted"] }
    		//	{ "type":""vehicle", "classname":"", "kit":"", "type":""}
    		// ]
		if (this.group.units.length == 0) { console.log('EDIT GROUP: No units to populate'); return; };
		console.log('EDIT GROUP: Populating form');
		for (var i=0; i < this.group.units.length; i++) {
			var unitSettings = this.group.units[i];

			this.createEntity(
				unitSettings.type
				, unitSettings.id
				, unitSettings.classname
				, unitSettings.kit
				, unitSettings.mode
				, unitSettings.restrictedHouses
				, unitSettings.vehicleId
				, unitSettings.vehicleRole
			);
    	};
    };
	this.save = function () {
		var unitsList = [];
		for (var i=0; i<this.editedUnits.length; i++) {
			unitsList.push( this.editedUnits[i].getSettings() );
		};

		this.group.units = unitsList;
		this.hide();
		this.group.setDesc();

		console.log("EDIT GROUP: Saved!");
	};
	this.cancel = function () {
		console.log("EDIT GROUP: Canceled");
		this.hide();
	};

	this.getUnitById = function (id) {
		var unit;
		for (var i=0;i<this.editedUnits.length;i++) {
			if (this.editedUnits[i].id == id) {
				return (this.editedUnits[i]);
			};
		};

		return unit;
	};
	this.removeUnit = function (id) {
		var index = -1;
		for (var i=0; i<this.editedUnits.length; i++) {
			if (this.editedUnits[i].id == id) {
				index = i;
			};
		};

		this.editedUnits.splice(index, 1);
		for (var i=index; i<this.editedUnits.length; i++) {
			this.editedUnits[i].changeId(i);
		};

		this.editedUnitsCounter--;
	};

	this.addEntity = function () {
		var type = $('.group-unit-type').val();

		var id = this.editedUnitsCounter;

		var unit = (type == "Infantry") ? new UnitItem( this.editedUnitsCounter ) : new VehicleItem( this.editedUnitsCounter );
		this.editedUnits.push(unit);
		this.editedUnitsCounter++;
	};

	this.createEntity = function (type, id, classname, kit, mode, restrictedHouses, vehicleId, vehicleRole) {
		var unit;
		if (type == "Infantry")  {
			unit = new UnitItem(
				id
				, classname
				, kit
				, mode
				, restrictedHouses
				, vehicleId
				, vehicleRole
			);
		} else {
			unit = new VehicleItem(
				id
				, classname
				, kit
				, mode
			);
		};

		this.editedUnits.push(unit);
		this.editedUnitsCounter++;
	};
};

var UnitItem = function (id, classname, kit, mode, restrictedHouses, vehicleId, vehicleRole) {
	this.id = id;
	this.type = "Infantry";
	this.classname = (classname == undefined) ? DefaultsSettings.getInfantryClassname() : classname;
	this.kit = (kit == undefined) ? DefaultsSettings.unitKit : kit;
	this.mode = (mode == undefined) ? "Patrol" : mode;

	this.restrictedHouses = (restrictedHouses == undefined) ? "" : restrictedHouses;
	this.vehicleId = (vehicleId == undefined) ? "" : vehicleId;
	this.vehicleRole = (vehicleRole == undefined) ? "Driver" : vehicleRole;

	this.additionalFieldsOn = false;
	this.lastSelectedMode = "Patrol";

	this.$form = $('<div class="xpopup-wrapper group-unit"  id="group-units-' + this.id
		+ '" unitId="' + this.id + '"><div class="col-4">Infantry #' + this.id + '</div>'
		+ '<div class="col-4"><input class="unit-classname" placeholder="Classname" value="' + this.classname + '"/></div>'
		+ '<div class="col-4"><input class="unit-kit" placeholder="Kit name"  value="' + this.kit + '"/></div>'
		+ '<select class="input-select unit-mode">'
			+ '<option>Patrol</option>'
			+ '<option>Indoors</option>'
			+ '<option>In vehicle</option>'
		+ '</select><div class="btn-short inline remove-unit" title="Remove unit">✖</div>'
		+ '<div class="btn-short inline copy-unit" title="Copy unit">C</div></div>'
	);

	this.switchMode = function (mode) {
		var unitMode;
		if (mode == undefined) {
			unitMode = $('#group-units-' + this.id).find('select').val();
		} else {
			unitMode = mode;
			$('#group-units-' + this.id).find('select').val(mode);
		};

		if (this.lastSelectedMode == unitMode) { return; };
		this.lastSelectedMode = unitMode;
		if (this.additionalFieldsOn) {
			$('#group-units-' + this.id).find('.unit-additional-fields').remove();
		};

		switch (unitMode) {
			case "Patrol":
				break;
			case "Indoors":
				var classHTML = "unit-restricted-houses";
				var elementHTML = '<div class="unit-additional-fields '
					+ classHTML + '"><br /><div class="col-4"></div>'
					+ '<div class="col-4"><input class="unit-houses" placeholder="(optional) Restricted houses" value="'
					+ this.restrictedHouses + '" title="in format \'House_1_EP1\',\'House_2_EP1\'"/></div></div>';

				$(this.$form).append(elementHTML);
				this.additionalFieldsOn = true;
                break;
			case "In vehicle":
				var classHTML = "unit-invehicle-fields";
                var elementHTML = '<div class="unit-additional-fields '
                    + classHTML + '"><br /><div class="col-4"></div>'
                    + '<div class="col-4"><input class="unit-vehicle-id" placeholder="Vehicle Id" value="'
                    + this.vehicleId + '"/></div>'
                    + '<select class="input-select unit-vehicle-role">'
						+ '<option>Driver</option>'
						+ '<option>Gunner</option>'
						+ '<option>Commander</option>'
						+ '<option>Cargo</option>'
					+'</select></div>';

				$(this.$form).append(elementHTML);

				if (this.vehicleRole != "") {
					$('#group-units-' + this.id).find('.unit-vehicle-role').val(this.vehicleRole);
				};

				this.additionalFieldsOn = true;
                break;
		};
	};

	this.getSettings = function () {
		this.classname =  $('#group-units-' + this.id).find('.unit-classname').val();
		this.kit = $('#group-units-' + this.id).find('.unit-kit').val();
		this.mode = $('#group-units-' + this.id).find('.unit-mode').val();

		this.restrictedHouses = null;
		this.vehicleId = null;
		this.vehicleRole = null;

		if (this.additionalFieldsOn) {
			switch (this.mode) {
				case "Indoors":
					this.restrictedHouses = ( $('#group-units-' + this.id).find('.unit-houses').val() ).replace(/"/g, "'");
					break;
				case "In vehicle":
					this.vehicleId = $('#group-units-' + this.id).find('.unit-vehicle-id').val();
					this.vehicleRole = $('#group-units-' + this.id).find('.unit-vehicle-role').val();
					break;
			};
		};

		return {
			"id": this.id
			,"type": this.type
			,"classname": this.classname
			,"kit": this.kit
			,"mode": this.mode
			,"restrictedHouses": this.restrictedHouses
			,"vehicleId": this.vehicleId
			,"vehicleRole": this.vehicleRole
		}
	};

	this.copyUnit = function () {
		this.getSettings();
		GroupEditWindow.createEntity(
			this.type
			, GroupEditWindow.editedUnitsCounter
			, this.classname
			, this.kit
			, this.mode
			, this.restrictedHouses
			, this.vehicleId
			, this.vehicleRole
		);
	};
	this.hide = function () {
		$('#group-units-' + this.id).find('select').off();
		$('#group-units-' + this.id).find('.btn-short').off();
		$(this.$form).remove();
	};
	this.changeId = function (newId) {
		var oldId = this.id;
		this.id = newId;

		$(this.$form).attr("unitId", newId);
		$(this.$form).attr("id","group-units-" + newId);
		$( $(this.$form).find('.col-4')[0] ).html("Infantry #" + newId);

	};
	this.initEvents = function () {
		$('#group-units-' + this.id).find('select').on('blur', function () {
			var unit = GroupEditWindow.getUnitById( parseInt( $(this).parent().attr('unitId') ) );
			unit.switchMode();
		});

		$('#group-units-' + this.id).find('.remove-unit').on('click', function () {
			console.log('Unit removed');
			var id = parseInt( $(this).parent().attr('unitId') );
			var unit = GroupEditWindow.getUnitById(id);
			unit.hide();
			GroupEditWindow.removeUnit(id);
		});

		$('#group-units-' + this.id).find('.copy-unit').on('click', function () {
			console.log('Unit copied');
			var id = parseInt( $(this).parent().attr('unitId') );
			var unit = GroupEditWindow.getUnitById(id).copyUnit();
		});
	};
	this.init = function () {
		$('.unit-wrapper').append(this.$form);
		this.initEvents();
		this.switchMode(this.mode);
	};

	this.init();
};

var VehicleItem = function (id, classname, kit, mode) {
	this.id = id;
	this.type = "Vehicle";
	this.classname = (classname == undefined) ? DefaultsSettings.vehicle : classname;
	this.kit = (kit == undefined) ? DefaultsSettings.vehicleKit : kit;
	this.mode = (mode == undefined) ? "Patrol" : mode;

	this.generateOptions = function () {
		var list = VEHICLE_BEHAVIOUR;
		var result = "";
		for (var i=0; i< list.length; i++) {
			result = result + '<option>' + list[i][0] + '</option>';
		};
		return result
	};
	
	this.$form = $('<div class="xpopup-wrapper group-unit" id="group-units-' + this.id
		+ '" unitId="' + this.id
		+ '"><div class="col-4">Vehicle #' + this.id + '</div>'
        + '<div class="col-4"><input placeholder="Classname" class="unit-classname" value="' + this.classname + '"/></div>'
        + '<div class="col-4"><input placeholder="Kit name" class="unit-kit" value="' + this.kit + '"/></div>'
        + '<select class="input-select unit-mode">'
			+ this.generateOptions()
		+ '</select><div class="btn-short inline remove-unit" title="Remove vehicle">✖</div>'
        + '<div class="btn-short inline copy-unit" title="Copy vehicle">C</div></div>'
	);

	this.switchMode = function (mode) {
		var unitMode;
		if (mode == undefined) {
			unitMode = $('#group-units-' + this.id).find('select').val();
		} else {
			unitMode = mode;
			$('#group-units-' + this.id).find('select').val(mode);
		};

		this.lastSelectedMode = unitMode;
	};
	this.getSettings = function () {
		this.classname = $('#group-units-' + this.id).find('.unit-classname').val();
		this.kit = $('#group-units-' + this.id).find('.unit-kit').val();
		this.mode = $('#group-units-' + this.id).find('.unit-mode').val();

		return {
			"id": this.id
			,"type": this.type
			,"classname": this.classname
			,"kit": this.kit
			,"mode": this.mode
		}
	};
	this.copyUnit = function () {
    		this.getSettings();
    		GroupEditWindow.createEntity(
    			this.type
    			, GroupEditWindow.editedUnitsCounter
    			, this.classname
    			, this.kit
    			, this.mode
    		);
    	};
	this.hide = function () {
		$('#group-units-' + this.id).find('select').off();
		$('#group-units-' + this.id).find('.btn-short').off();
		$(this.$form).remove();
	};
	this.changeId = function (newId) {
		var oldId = this.id;
        this.id = newId;

		$(this.$form).attr("unitId", newId);
		$(this.$form).attr("id","group-units-" + newId);
		$( $(this.$form).find('.col-4')[0] ).html("Vehicle #" + newId);
	};
	this.initEvents = function () {
		$('#group-units-' + this.id).find('select').on('blur', function () {
			var veh = GroupEditWindow.getUnitById( parseInt( $(this).parent().attr('unitId') ) );
			veh.switchMode();
		});

		$('#group-units-' + this.id).find('.remove-unit').on('click', function () {
			console.log('Vehicle removed');
			var id = parseInt( $(this).parent().attr('unitId') );
			var veh = GroupEditWindow.getUnitById(id);
			veh.hide();
			GroupEditWindow.removeUnit(id);
		});

		$('#group-units-' + this.id).find('.copy-unit').on('click', function () {
			console.log('Vehicle copied');
			var id = parseInt( $(this).parent().attr('unitId') );
			var unit = GroupEditWindow.getUnitById(id).copyUnit();
		});
	};
	this.init = function () {
		$('.unit-wrapper').append(this.$form);
        this.initEvents();
        this.switchMode(this.mode);
	};

	this.init();
};

/*
 * Defaults Edit
 *
 */
var Defaults = function () {
	this.unit = "";
	this.unitKit = "";
	this.vehicle = "";
	this.vehicleKit = "";

	this.$form = $("<div class='defaults-popup'>"
		+ '<div class="xpopup-header"><span style="padding: 2px 20px">Defaults</span></div>'

		+ '<div class="xpopup-line defaults-unit-classname">'
		+ '<div class="col-4">Unit classname</div>'
		+ '<div class="col-4" title="Classname that will be used for all added infantry units"><input /></div>'
		+ '</div>'

		+ '<div class="xpopup-line defaults-unit-kit">'
		+ '<div class="col-4">Unit Kit</div>'
		+ '<div class="col-4" title="dzn_gear kit that will be used for all added infantry units"><input /></div>'
		+ '</div>'

		+ '<div class="xpopup-line defaults-vehicle-classname">'
		+ '<div class="col-4">Vehicle classname</div>'
		+ '<div class="col-4" title="Classname that will be used for all added vehicles"><input /></div>'
		+ '</div>'

		+ '<div class="xpopup-line defaults-vehicle-kit">'
		+ '<div class="col-4">Vehicle Kit</div>'
		+ '<div class="col-4" title="dzn_gear kit that will be used for all added vehicles"><input /></div>'
		+ '</div>'

		+ '<div class="xpopup-wrapper">'
		+ '<span  style="float:right"><div class="btn inline defaults-save">✓ OK</div>'
		+ '<div class="btn inline defaults-cancel">CANCEL</div></span>'
		+ '</div>'
	);

	this.display = function () {
		$( '.defaults-wrapper' ).append( this.$form );
		$( '.defaults-popup' ).css('top', 100 +window.pageYOffset + 'px');
		$( '.splash' ).css('display', 'inline');
		this.initEvents();
		this.restore();
	};
	this.restore = function () {
		$('.defaults-unit-classname > div > input').val( this.unit );
		$('.defaults-unit-kit > div > input').val( this.unitKit );
		$('.defaults-vehicle-classname > div > input').val( this.vehicle );
		$('.defaults-vehicle-kit > div > input').val( this.vehicleKit );
	};
	this.save = function () {
		this.unit = $('.defaults-unit-classname > div > input').val();
		this.unitKit = $('.defaults-unit-kit > div > input').val();
		this.vehicle = $('.defaults-vehicle-classname > div > input').val();
		this.vehicleKit = $('.defaults-vehicle-kit > div > input').val();
	};
	this.hide = function () {
		$('.splash').css('display', 'none');
		$('.defaults-cancel').off();
		$('.defaults-save').off();
		$( '.defaults-wrapper' ).children().remove();
	};
	this.initEvents = function () {
		$('.defaults-cancel').on('click', function () {
			DefaultsSettings.restore();
			DefaultsSettings.hide();
		});
		$('.defaults-save').on('click', function () {
			DefaultsSettings.save();
			DefaultsSettings.hide();
		});
	};

	this.getInfantryClassname = function () {
		var classname = this.unit;
		if (this.unit == "") {
			switch (Zone.side) {
				case "west":
					classname = "B_Soldier_F";
					break;
				case "east":
					classname = "O_Soldier_F";
					break;
				case "resistance":
					classname = "I_soldier_F";
					break;
				case "civilian":
					classname = "C_man_1";
					break;
			};
		};

		return classname;
	};
};

var Export = function () {
	this.$form = $("<div class='defaults-popup'>"
		+ '<div class="xpopup-header"><span style="padding: 2px 20px">Dynai Zone Config (SQF)</span></div>'
		+ '<div class="xpopup-line config-line"></div>'
		+ '<div class="xpopup-wrapper">'
		+ '<span  style="float:right"><div class="btn inline defaults-save">✓ OK</div></span>'
		+ '</div>'
	);
	this.display = function () {
		$( '.defaults-wrapper' ).append( this.$form );
		$( '.defaults-popup' ).css('top', 100 +window.pageYOffset + 'px');
		$( '.splash' ).css('display', 'inline');
		this.initEvents();
		this.showConfig();
	};
	this.hide = function () {
		$('.splash').css('display', 'none');
		$('.defaults-save').off();
		$('.defaults-wrapper' ).children().remove();
		console.log("Export: Closed")
	};
	this.initEvents = function () {
		$('.defaults-save').on('click', function () {
			ExportPopup.hide();
		});
	};
	this.showConfig = function () {
		var config = Zone.getConfig();

		$('.xpopup-line').html(config);
	};


};

var DefaultsSettings = new Defaults();
var GroupEditWindow = new GroupEdit();
var ExportPopup = new Export();

$(document).ready(function () {
	Zone = new ZoneItem();
	
	$('.btn-show-defaults').on('click', function () {
		DefaultsSettings.display();
	});

	$('.btn-get-sqf').on('click', function () {
		ExportPopup.display();
	});

	$('.btn-clear-form').on('click', function () {
		Zone.reset();
	});
	
	$( '.splash' ).css('display', 'none');

	DefaultsSettings.display();
	// DefaultsSettings.init();
	// GroupEditWindow.init();
});
